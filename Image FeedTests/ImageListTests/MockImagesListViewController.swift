//
//  Untitled.swift
//  ImageFeed
//
//  Created by Diana Viter on 19.03.2025.
//

import XCTest
@testable import ImageFeed

final class MockImagesListViewController: ImagesListViewControllerProtocol {
    var reloadDataCalled = false

    func reloadData() {
        reloadDataCalled = true
    }
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {}
}

