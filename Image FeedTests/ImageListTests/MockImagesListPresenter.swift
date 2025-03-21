//
//  MockImagesListPresenter.swift
//  ImageFeed
//
//  Created by Diana Viter on 19.03.2025.
//

import XCTest
@testable import ImageFeed

final class MockImagesListPresenter: ImagesListPresenterProtocol {
    var photos: [ImageFeed.Photo] = []
    
    var view: ImagesListViewControllerProtocol?
    var photosCount: Int = 1
    var fetchInitialPhotosCalled = false
    var toggleLikeCalled = false
    
    let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    func fetchInitialPhotos() {
        fetchInitialPhotosCalled = true
    }

    func photo(at index: Int) -> Photo {
        return Photo(id: "1", size: CGSize(width: 100, height: 200), createdAt: Date(), welcomeDescription: "test", thumbImageURL: "thumb1", largeImageURL: "large1", isLiked: false)
    }

    func photoURL(at index: Int) -> URL? {
        return URL(string: "https://example.com/image.jpg")
    }

    func cellHeight(for width: CGFloat, at index: Int) -> CGFloat {
        return 100.0
    }

    func toggleLike(at index: Int, completion: @escaping (Photo) -> Void) {
        print("✅ MockPresenter: toggleLike вызван для index: \(index)")
        toggleLikeCalled = true
    }

    func loadMorePhotosIfNeeded(currentIndex: Int) {}
}
