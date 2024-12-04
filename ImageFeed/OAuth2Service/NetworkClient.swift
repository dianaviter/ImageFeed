//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Diana Viter on 01.12.2024.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case dataNotFound
}

final class NetworkClient {
    func data(request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void) {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                handler(result)
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                print("URL request error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.dataNotFound))
                print("Invalid HTTP response")
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                print("HTTP error: \(httpResponse.statusCode)")
                return
            }
            
            guard let data = data else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.dataNotFound))
                print("Data not found")
                return
            }
            
            fulfillCompletionOnTheMainThread(.success(data))
        }
        task.resume()
    }
}
