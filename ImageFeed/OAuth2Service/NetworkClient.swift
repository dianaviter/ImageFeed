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
    case decodingError(Error)
    case invalidResponse
}

struct AnyKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
    }
}

final class NetworkClient {
    private func data(request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void) {
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

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            if let error = error {
                print("Server response error: \(error.localizedDescription)")
                completion(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                print("Invalid HTTP response: \(response.debugDescription)")
                
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(NetworkError.dataNotFound))
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Server responce: \(responseString)")
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .custom { codingKeys in
                    guard let lastKey = codingKeys.last else {
                        fatalError("No last key found in codingKeys")
                    }
                    if lastKey.stringValue == "created_at" {
                        return AnyKey(stringValue: "createdAt")!
                    }
                    return lastKey
                }
                
                decoder.dateDecodingStrategy = .iso8601
                let object = try decoder.decode(T.self, from: data)
                print("Decoded object: \(object)")
                completion(.success(object))
            } catch {
                print ("Decoding error: \(error)")
                completion(.failure(NetworkError.decodingError(error)))
            }
        }
        task.resume()
        return task
    }
}

