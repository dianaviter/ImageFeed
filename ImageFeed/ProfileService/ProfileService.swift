//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Diana Viter on 04.01.2025.
//

import Foundation
import UIKit

private enum ProfileServiceError: Error {
    case urlEncodingError
    case serverResponseError(Error)
    case noDataError
    case invalidRequest
    case decodingError
}

enum HttpMethods: String {
    case get = "GET"
    case post = "POST"
}

final class ProfileService {
    // MARK: - Properties
    
    static let shared = ProfileService()
    private init () {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    var token: String?
    var username: String?
    
    // MARK: - Profile Model
    
    struct ProfileResult: Decodable {
        let id: String?
        let updatedAt: String?
        let username: String
        let firstName: String
        let lastName: String?
        let twitterUsername: String?
        let portfolioUrl: URL?
        let bio: String?
        let location: String?
        let totalLikes: Int?
        let totalPhotos: Int?
        let totalCollections: Int?
        let followedByUser: Bool?
        let downloads: Int?
        
        enum CodingKeys: String, CodingKey {
            case id, username, bio, location, downloads
            case updatedAt = "updated_at"
            case firstName = "first_name"
            case lastName = "last_name"
            case twitterUsername = "twitter_username"
            case portfolioUrl = "portfolio_url"
            case totalLikes = "total_likes"
            case totalPhotos = "total_photos"
            case totalCollections = "total_collections"
            case followedByUser = "followed_by_user"
        }
    }
    
    struct Profile: Decodable {
        let username: String
        let firstName: String
        var lastName: String?
        var name: String {
            return firstName + " " + (lastName ?? "")
        }
        var loginName: String {
            return "@" + username
        }
        var bio: String?
    }
    
    // MARK: - Methods
    
    private func createUrlRequestPublicInfo (authToken: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            if token != OAuth2TokenStorage().token {
                task?.cancel()
            } else {
                completion(.failure(ProfileServiceError.invalidRequest))
                return
            }
        } else {
            if token == OAuth2TokenStorage().token {
                completion (.failure(ProfileServiceError.invalidRequest))
            }
        }
        
        guard let request = createUrlRequestPublicInfo(authToken: token) else {
            print ("Failed to create URLRequest")
            completion(.failure(ProfileServiceError.urlEncodingError))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let profile = Profile (
                        username: response.username,
                        firstName: response.firstName,
                        lastName: response.lastName,
                        bio: response.bio ?? "")
                    self.username = profile.username
                    completion(.success(profile))
                case .failure(let error):
                    print("Error: \(error)")
                    completion(.failure(error))
                }
                self.task = nil
                self.token = nil
            }
        }
        self.token = token
        task.resume()
    }
    
}
