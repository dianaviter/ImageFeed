//
//  Untitled 2.swift
//  ImageFeed
//
//  Created by Diana Viter on 19.03.2025.
//

import XCTest
@testable import ImageFeed

final class ImagesListViewControllerTests: XCTestCase {
    
    var viewController: ImagesListViewController?
    var mockPresenter = MockImagesListPresenter()
    let tableView = UITableView()
    let presenter = MockImagesListPresenter()
    let mockTableView = MockTableView()
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(identifier: "ImagesListViewController") as? ImagesListViewController
        
        XCTAssertNotNil(viewController, "viewController is nil!")
        
        viewController?.presenter = mockPresenter
        viewController?.loadViewIfNeeded()
        
        XCTAssertNotNil(viewController?.tableView, "tableView is nil after loadViewIfNeeded()")
    }
    
    func testViewDidLoadCallsFetchInitialPhotos() {
        viewController?.viewDidLoad()
        
        XCTAssertTrue(mockPresenter.fetchInitialPhotosCalled)
    }
    
    func testReloadDataUpdatesTableView() {
        let mockTableView = MockTableView()
        viewController?.tableView = mockTableView

        viewController?.reloadData()

        XCTAssertTrue(mockTableView.reloadDataCalled)
    }
    
    func testDidTapLikeCallsPresenterToggleLike() {
        let expectation = expectation(description: "TableView should load its data")
        viewController?.tableView.dataSource = viewController?.dataSource
        viewController?.tableView.delegate = viewController?.dataSource
        viewController?.tableView.reloadData()
        
        DispatchQueue.main.async {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        guard let cell = viewController?.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ImagesListCell else {
            return
        }
        
        viewController?.imageListCellDidTapLike(cell)
        
        XCTAssertTrue(mockPresenter.toggleLikeCalled, "❌ toggleLike не был вызван!")
    }
}
