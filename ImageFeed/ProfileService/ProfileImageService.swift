//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Diana Viter on 06.01.2025.
//

import Foundation

private enum ProfileServiceError: Error {
    case urlEncodingError
    case serverResponseError(Error)
    case noDataError
    case invalidRequest
    case decodingError
}

final class ProfileImageService {
    // MARK: - Properties
    
    static let shared = ProfileImageService()
    private init () {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private let profileService = ProfileService.shared
    private var imageUrl: URL?
    static let didChangeNotification = Notification.Name ("ProfileImageServiceDidChengeNotification")
    
    // MARK: - Supporting Models
    
    struct ProfileImageSizes: Codable {
        let small: String?
        let medium: String?
        let large: String?
    }
    
    struct ProfileImage: Codable {
        let profileImage: ProfileImageSizes
        
        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }
    
    // MARK: - Private Methods
    
    private func createUrlRequestPrivateInfo(authToken: String) -> URLRequest? {
        guard let username = profileService.username else {
            print("Username is nil or empty")
            return nil
        }
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("Invalid URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    // MARK: - Methods
    
    func fetchProfileImage(_ token: String, completion: @escaping (Result<ProfileImage, Error>) -> Void) {
        assert(Thread.isMainThread)
        if let currentTask = task, token != OAuth2TokenStorage().token {
            currentTask.cancel()
        }
        
        guard token == OAuth2TokenStorage().token else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        guard let request = createUrlRequestPrivateInfo(authToken: token) else {
            print("Failed to create URLRequest (Image)")
            completion(.failure(ProfileServiceError.urlEncodingError))
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileImage, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("Response Data: \(response)")
                    completion(.success(response))
                    NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self, userInfo: ["profileImage": response])
                case .failure(let error):
                    print("Error: \(error)")
                    completion(.failure(error))
                }
                self.task = nil
            }
        }
        task?.resume()
    }
}
