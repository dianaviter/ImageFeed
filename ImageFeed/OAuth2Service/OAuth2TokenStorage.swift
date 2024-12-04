//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Diana Viter on 01.12.2024.
//

import Foundation

final class OAuth2TokenStorage {
    let tokenKey = "authToken"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: tokenKey)
        }
    }
}
