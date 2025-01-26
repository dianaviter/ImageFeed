//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Diana Viter on 01.12.2024.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    let tokenKey = "authToken"
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                let isSuccess = KeychainWrapper.standard.set(token, forKey: tokenKey)
                
                guard isSuccess else {
                    print ("Error saving token")
                    return
                }
            }
        }
    }
}
