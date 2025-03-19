//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Diana Viter on 19.03.2025.
//

import Foundation
import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photosCount: Int { get }
    var displayDateFormatter: DateFormatter { get }
    func fetchInitialPhotos()
    func photo(at index: Int) -> Photo
    func photoURL(at index: Int) -> URL?
    func cellHeight(for width: CGFloat, at index: Int) -> CGFloat
    func toggleLike(at index: Int, completion: @escaping (Photo) -> Void)
    func loadMorePhotosIfNeeded(currentIndex: Int)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    private let imagesListService: ImagesListServiceProtocol
    weak var view: ImagesListViewControllerProtocol?
    let tokenStorage = OAuth2TokenStorage()
    
    var photos: [Photo] = []
    
    var photosCount: Int {
        return photos.count
    }
    
    let displayDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM yyyy"
            formatter.locale = Locale(identifier: "ru_RU")
            return formatter
        }()
    
    init(imagesListService: ImagesListServiceProtocol = ImagesListService()) {
        self.imagesListService = imagesListService
    }
    
    func fetchInitialPhotos() {
        imagesListService.fetchPhotosNextPage(tokenStorage.token ?? "") { [weak self] result in
            switch result {
            case .success(let newPhotos):
                self?.photos.append(contentsOf: newPhotos)
                DispatchQueue.main.async {
                    self?.view?.reloadData()
                }
            case .failure(let error):
                print("Error fetching photos: \(error)")
            }
        }
    }
    
    func photo(at index: Int) -> Photo {
        return photos[index]
    }
    
    func photoURL(at index: Int) -> URL? {
        return URL(string: photos[index].largeImageURL)
    }
    
    func cellHeight(for width: CGFloat, at index: Int) -> CGFloat {
        let photo = photos[index]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        return photo.size.height * scale + imageInsets.top + imageInsets.bottom
    }
    
    func toggleLike(at index: Int, completion: @escaping (Photo) -> Void) {
        var photo = photos[index]
        let newLikeStatus = !photo.isLiked

        photo.isLiked = newLikeStatus
        photos[index] = photo
        view?.reloadData()
        
        imagesListService.changeLike(photoId: photo.id, isLike: newLikeStatus) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Like status updated successfully")
                case .failure(let error):
                    print("Failed to update like status: \(error)")
                    self.photos[index].isLiked.toggle()
                    self.view?.reloadData()
                }
            }
        }
    }
    
    func loadMorePhotosIfNeeded(currentIndex: Int) {
        if currentIndex == photos.count - 1 {
            fetchInitialPhotos()
        }
    }
}
