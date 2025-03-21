//
//  Untitled.swift
//  ImageFeed
//
//  Created by Diana Viter on 18.03.2025.
//

@testable import ImageFeed
import Foundation

final class MockProfileImageService: ProfileImageServiceProtocol {
    func fetchProfileImage(_ token: String, completion: @escaping (Result<ProfileImageService.ProfileImage, Error>) -> Void) {
        let testImage = ProfileImageService.ProfileImage(
            profileImage: ProfileImageService.ProfileImageSizes(
                small: "https://test.com/small.jpg",
                medium: "https://test.com/medium.jpg",
                large: "https://test.com/large.jpg"
            )
        )
        completion(.success(testImage))
    }
}
