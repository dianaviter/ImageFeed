//
//  ViewController.swift
//  ImageFeed
//
//  Created by Diana Viter on 02.11.2024.
//

import UIKit

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private var tableView: UITableView!
    private let imagesListService = ImagesListService()
    var photos: [Photo] = []
    var tokenStorage = OAuth2TokenStorage()
    
    private let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceivePhotosUpdate),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        imagesListService.fetchPhotosNextPage(tokenStorage.token ?? "") { _ in }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: ImagesListService.didChangeNotification, object: nil)
    }
    
    @objc private func didReceivePhotosUpdate() {
        let oldCount = photos.count
        photos = imagesListService.photos
        let newCount = photos.count
        
        guard newCount > oldCount else { return }
        
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        
        tableView.performBatchUpdates({
            tableView.insertRows(at: indexPaths, with: .automatic)
        }, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare(for segue:) called with identifier:", segue.identifier ?? "nil")
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            let photo = photos[indexPath.row]
            guard let fullImageUrl = URL(string: photo.largeImageURL) else {
                assertionFailure("Invalid image URL")
                return
            }
            viewController.imageURL = fullImageUrl
            print("Sending imageURL:", fullImageUrl)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
    
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            fatalError("Unable to dequeue ImagesListCell")
        }
        let photo = photos[indexPath.row]
        
        cell.updateCellHeight = { [weak tableView] in
            guard let tableView = tableView else { return }
            DispatchQueue.main.async {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
        cell.delegate = self
        cell.configure(with: photo, dateFormatter: displayDateFormatter)
        return cell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        var photo = photos[indexPath.row]
        
        let newLikeStatus = !photo.isLiked
        photo.isLiked = newLikeStatus
        photos[indexPath.row] = photo
        cell.setIsLiked(newLikeStatus)
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: newLikeStatus) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success:
                    print("Like status updated successfully")
                    break
                case .failure(let error):
                    print("Failed to update like status: \(error)")
                    photo.isLiked.toggle()
                    self.photos[indexPath.row] = photo
                    cell.setIsLiked(photo.isLiked)
                }
            }
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Cell is active, indexPath:", indexPath)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage(tokenStorage.token ?? "") { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    print("Error fetching next page: \(error)")
                }
            }
        }
    }
}
