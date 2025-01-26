//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Diana Viter on 26.01.2025.
//

import UIKit

private enum ImagesListError: Error {
    case urlEncodingError
    case serverResponseError(Error)
    case noDataError
    case invalidRequest
    case decodingError
}

// MARK: - Models

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Codable {
    let id: String?
    let createdAt: Date?
    let updatedAt: Date?
    let width: Int?
    let height: Int?
    let color: String?
    let blurHash: String?
    let likes: Int?
    let likedByUser: Bool?
    let description: String?
    let urls: Urls?
}

enum CodingKeys: String, CodingKey {
    case id, width, height, color, likes, description, user, urls
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case blurHash = "blur_hash"
    case likedByUser = "liked_by_user"
}

struct Urls: Codable {
    let raw: String?
    let full: String?
    let regular: String?
    let small: String?
    let thumb: String?
}

final class ImagesListService {
    // MARK: - Properties
    
    var lastLoadedPage: Int = 0 //номер последней скачанной страницы
    private (set) var photos: [Photo] = [] //список уже скачанных фотографий
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    private var task: URLSessionTask?
    private var request: URLRequest?
    private var urlSession: URLSession?
    
    // MARK: - Private Methods
    
    private func createUrlRequest (authToken: String) -> URLRequest? {
        guard let url = URL (string: "https://api.unsplash.com/photos?page=\(lastLoadedPage + 1)&per_page=10") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.get.rawValue
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func fetchPhotosNextPage(_ token: String, completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard task == nil else {
            completion(.failure(ImagesListError.invalidRequest))
            return
        }
        
        guard let request = createUrlRequest(authToken: token) else {
            print ("Failed to create URL request")
            completion(.failure(ImagesListError.urlEncodingError))
            return
        }
        
        let task = urlSession?.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                defer { self.task = nil }
                switch result {
                case .success(let response):
                    let newPhotos: [Photo] = response.compactMap { photoResult in
                        guard let id = photoResult.id,
                              let width = photoResult.width,
                              let height = photoResult.height,
                              let createdAt = photoResult.createdAt,
                              let welcomeDescription = photoResult.description,
                              let thumbImageURL = photoResult.urls?.thumb,
                              let largeImageURL = photoResult.urls?.full,
                              let isLiked = photoResult.likedByUser
                        else { return nil }
                        
                        return Photo(
                            id: id,
                            size: CGSize(width: width, height: height),
                            createdAt: createdAt,
                            welcomeDescription: welcomeDescription,
                            thumbImageURL: thumbImageURL,
                            largeImageURL: largeImageURL,
                            isLiked: isLiked)
                    }
                        
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage += 1
                        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                        completion(.success(newPhotos))
                    case .failure(let error):
                        print ("Error: \(error)")
                        completion(.failure(error))
                    }
                }
        }
        task?.resume()
    }
    
    // MARK: - Methods
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        
    }
}
