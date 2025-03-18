//
//  Untitled.swift
//  ImageFeed
//
//  Created by Diana Viter on 18.03.2025.
//

@testable import ImageFeed
import Foundation

final class MockProfileService: ProfileServiceProtocol {
    var profile: ProfileService.Profile?

    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileService.Profile, Error>) -> Void) {
        if let profile = profile {
            completion(.success(profile))
        } else {
            completion(.failure(NSError(domain: "TestError", code: -1, userInfo: nil)))
        }
    }
}
