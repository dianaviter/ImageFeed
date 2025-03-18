//
//  Untitled.swift
//  ImageFeed
//
//  Created by Diana Viter on 18.03.2025.
//

import Foundation
@testable import ImageFeed


final class MockOAuth2TokenStorage: TokenStorageProtocol {
    var token: String? = "test_token"
}
