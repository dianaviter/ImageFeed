import Foundation
import SwiftKeychainWrapper

protocol TokenStorageProtocol {
    var token: String? { get set }
}

final class OAuth2TokenStorage: TokenStorageProtocol {
    static let shared = OAuth2TokenStorage()
    private let tokenKey = "authToken"

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                let isSuccess = KeychainWrapper.standard.set(token, forKey: tokenKey)
                guard isSuccess else {
                    print("Failed to save token in Keychain")
                    return
                }
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
                print("Token is deleted from Keychain")
            }
        }
    }
    
    func isTokenAvailable() -> Bool {
        return KeychainWrapper.standard.string(forKey: tokenKey) != nil
    }
}
