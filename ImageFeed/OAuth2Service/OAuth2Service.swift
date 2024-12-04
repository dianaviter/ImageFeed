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
    private init() {}
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Failed to create URLRequest")
            completion(.failure(OAuthError.urlEncodingError))
            return
        }
        
        networkClient.data(request: request) { result in
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
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "oauth/token", relativeTo: URL(string: baseApiUrl)) else {
            print("Failed to create URL with base: \(baseApiUrl)")
            return nil
        }
        
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
                print("Failed to encode parameter value for key: \(key)")
                return nil
            }
            return "\(key)=\(encodedValue)"
        }
        
        if parameterArray.isEmpty {
            print("Parameter array is empty after encoding")
        }
        
        urlRequest.httpBody = parameterArray.joined(separator: "&").data(using: .utf8)
        
        return urlRequest
    }
}
