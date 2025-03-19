//
//  ImagesListPresenterTests.swift
//  ImageFeed
//
//  Created by Diana Viter on 19.03.2025.
//

import XCTest
@testable import ImageFeed

final class ImagesListPresenterTests: XCTestCase {
    
    var presenter: ImagesListPresenter!
    var mockView: MockImagesListViewController!
    var mockService: MockImagesListService!
    
    override func setUp() {
        super.setUp()
        mockView = MockImagesListViewController()
        mockService = MockImagesListService()
        presenter = ImagesListPresenter(imagesListService: mockService)
        presenter.view = mockView
    }
    
    override func tearDown() {
        presenter = nil
        mockView = nil
        mockService = nil
        super.tearDown()
    }
    
    func testFetchInitialPhotosSuccess() {
        let expectation = XCTestExpectation(description: "Photos fetched and reloadData called")
        
        let expectedPhotos = [
            Photo(id: "1", size: CGSize(width: 100, height: 200), createdAt: Date(), welcomeDescription: "test", thumbImageURL: "thumb1", largeImageURL: "large1", isLiked: false),
            Photo(id: "2", size: CGSize(width: 150, height: 250), createdAt: Date(), welcomeDescription: "test", thumbImageURL: "thumb2", largeImageURL: "large2", isLiked: true)
        ]
        mockService.mockPhotos = expectedPhotos

        presenter.fetchInitialPhotos()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.presenter.photosCount, expectedPhotos.count)
            XCTAssertTrue(self.mockView.reloadDataCalled)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    
    func testToggleLikeSuccess() {
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 200), createdAt: Date(), welcomeDescription: "test", thumbImageURL: "thumb1", largeImageURL: "large1", isLiked: false)
        presenter.photos = [photo]
        mockService.mockLikeSuccess = true

        presenter.toggleLike(at: 0) { _ in }

        XCTAssertTrue(presenter.photos[0].isLiked)
        XCTAssertTrue(mockView.reloadDataCalled)
    }

    func testToggleLikeFailure() {
        let expectation = XCTestExpectation(description: "Like update failed and reverted")
        
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 200), createdAt: Date(), welcomeDescription: "test", thumbImageURL: "thumb1", largeImageURL: "large1", isLiked: false)
        presenter.photos = [photo]
        mockService.mockLikeSuccess = false

        presenter.toggleLike(at: 0) { _ in }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.presenter.photos[0].isLiked)
            XCTAssertTrue(self.mockView.reloadDataCalled)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

}
