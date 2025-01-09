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
    private var task: URLSessionTask? // Переменная для хранения указателя на последнюю созданную задачу. Если активных задач нет, то значение будет nil
    private var lastCode: String? // Переменная для хранения значения code, которое было передано в последнем созданном запросе
    
    private init() {
        
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread) // Проверяем, что код выполняется из главного потока
        if task != nil { //Проверяем, выполняется ли в данный момент POST-запрос
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
            print("Failed to create URLRequest")
            completion(.failure(OAuthError.urlEncodingError))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.tokenStorage.token = response.access_token
                    completion(.success(response.access_token))
                case .failure(let error):
                    print("Error: \(error)")
                    completion(.failure(error))
                }
            }
            self.task = nil // Обнуляем task, ведь мы завершили обработку
            self.lastCode = nil // Когда запрос завершился, а мы его обработали, удалим lastCode, чтобы можно было повторить запрос с тем же кодом.
        }
        self.task = task // Прежде чем запускать выполнение запроса в пункте 17, нужно зафиксировать состояние, сохранив ссылку на task — иначе возможны гонки
        task.resume() // Запускаем запрос на выполнение
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "oauth/token", relativeTo: URL(string: baseApiUrl)) else {
            assertionFailure("Failed to create URL")
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
