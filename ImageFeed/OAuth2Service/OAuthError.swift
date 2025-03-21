//
//  OAuthError.swift
//  ImageFeed
//
//  Created by Diana Viter on 01.03.2025.
//


//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Diana Viter on 01.12.2024.
//

import Foundation

private enum OAuthError: Error {
    case urlEncodingError
    case serverResponseError
    case noDataError
    case invalidRequest
}

struct OAuthTokenResponseBody: Decodable {
    let access_token: String
}

final class OAuth2Service {
    private let tokenStorage = OAuth2TokenStorage()
    private let networkClient = NetworkClient()
    private let baseApiUrl = "https://unsplash.com"
    
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}

    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                completion(.failure(OAuthError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(OAuthError.invalidRequest))
                return
            }
        }
        
        lastCode = code
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("🚨 Failed to create URLRequest")
            completion(.failure(OAuthError.urlEncodingError))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ Token received: \(response.access_token)")
                    self.tokenStorage.token = response.access_token
                    completion(.success(response.access_token))
                case .failure(let error):
                    print("❌ Error fetching token: \(error)")
                    completion(.failure(error))
                }
            }
            self.task = nil
            self.lastCode = nil
        }
        self.task = task
        task.resume()
    }

    /// ✅ Метод выхода из аккаунта
    func logout() {
        print("🚪 Пользователь вышел из аккаунта, токен удалён")
        tokenStorage.token = nil
    }

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "oauth/token", relativeTo: URL(string: baseApiUrl)) else {
            assertionFailure("🚨 Failed to create URL")
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HttpMethods.post.rawValue
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        let parameterArray = parameters.compactMap { (key, value) -> String? in
            guard let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                print("🚨 Failed to encode parameter value for key: \(key)")
                return nil
            }
            return "\(key)=\(encodedValue)"
        }
        
        if parameterArray.isEmpty {
            print("🚨 Parameter array is empty after encoding")
        }
        
        urlRequest.httpBody = parameterArray.joined(separator: "&").data(using: .utf8)
        
        return urlRequest
    }
}
