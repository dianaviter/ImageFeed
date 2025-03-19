//
//  Untitled.swift
//  ImageFeed
//
//  Created by Diana Viter on 19.03.2025.
//

import XCTest
@testable import ImageFeed

final class MockTableView: UITableView {
    var reloadDataCalled = false

    override func reloadData() {
        reloadDataCalled = true
        super.reloadData()
    }
}
