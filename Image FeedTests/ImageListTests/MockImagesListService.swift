//
//  MockImagesListService.swift
//  ImageFeed
//
//  Created by Diana Viter on 19.03.2025.
//

import XCTest
@testable import ImageFeed

final class MockImagesListService: ImagesListServiceProtocol {
    var mockPhotos: [Photo] = []
    var mockLikeSuccess = true

    func fetchPhotosNextPage(_ token: String, completion: @escaping (Result<[Photo], Error>) -> Void) {
        completion(.success(mockPhotos))
    }

    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        if mockLikeSuccess {
            completion(.success(()))
        } else {
            completion(.failure(NSError(domain: "LikeError", code: -1, userInfo: nil)))
        }
    }
}
