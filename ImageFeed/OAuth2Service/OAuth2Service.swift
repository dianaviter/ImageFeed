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
}

struct OAuthTokenResponseBody: Decodable {
    let access_token: String
}

final class OAuth2Service {
    private let tokenStorage = OAuth2TokenStorage()
    private let networkClient = NetworkClient()
    private let baseApiUrl = "https://unsplash.com"

    static let shared = OAuth2Service()

    init() {}

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "oauth/token", relativeTo: URL(string: baseApiUrl)) else { return nil }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
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
                return nil
            }
            return "\(key)=\(encodedValue)"
        }
        
        urlRequest.httpBody = parameterArray.joined(separator: "&").data(using: .utf8)

        return urlRequest
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(OAuthError.urlEncodingError))
            return
        }
        
        networkClient.data(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        let response = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                        self.tokenStorage.token = response.access_token
                        completion(.success(response.access_token))
                    } catch {
                        print("Decoding error: \(error)")
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    print("Request error: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
}