//
//  ViewController.swift
//  ImageFeed
//
//  Created by Diana Viter on 02.11.2024.
//

import UIKit

protocol ImagesListViewControllerProtocol: AnyObject, ImagesListCellDelegate {
    func reloadData()
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {

    @IBOutlet var tableView: UITableView!
    var presenter: ImagesListPresenterProtocol
    var dataSource: ImagesListDataSource?
    let imagesListService = ImagesListService()
    let tokenStorage = OAuth2TokenStorage()
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    init(tableView: UITableView!, presenter: ImagesListPresenterProtocol, dataSource: ImagesListDataSource? = nil) {
        self.tableView = tableView
        self.presenter = presenter
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        let defaultPresenter = ImagesListPresenter()
        
        self.presenter = defaultPresenter

        super.init(coder: coder)

        let defaultDataSource = ImagesListDataSource(presenter: defaultPresenter, viewController: self)

        self.dataSource = defaultDataSource
        self.presenter.view = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupPresenter()
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
            let photo = presenter.photos[indexPath.row]
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

    private func setupTableView() {
        dataSource = ImagesListDataSource(presenter: presenter, viewController: self) // 🔥 Передаем self

        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }   
  
    private func setupPresenter() {
        presenter.view = self
        presenter.fetchInitialPhotos()
    }

    func reloadData() {
        tableView.reloadData()
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        presenter.toggleLike(at: indexPath.row) { _ in 
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [indexPath], with: .none)

            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isTestMode = ProcessInfo.processInfo.arguments.contains("testMode")
        if isTestMode {
            return
        }
        if indexPath.row == presenter.photos.count - 1 {
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


