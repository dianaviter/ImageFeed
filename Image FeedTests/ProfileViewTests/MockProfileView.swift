//
//  Untitled.swift
//  ImageFeed
//
//  Created by Diana Viter on 18.03.2025.
//

@testable import ImageFeed
import Foundation
import UIKit

final class MockProfileView: ProfileViewControllerProtocol {
    func updateUIAfterDataLoad() {

    }
    
    var updatedProfile: ProfileService.Profile?
    var profileUpdated = false
    var didPresentAlert = false
    var presenter: ProfilePresenterProtocol?
    var didNavigateToLogin = false

    func updateProfile(profile: ProfileService.Profile) {
        self.updatedProfile = profile
        self.profileUpdated = true
    }
    
    func updateProfileImage(profileImage: ProfileImageService.ProfileImage) {}
    
    func navigateToLoginScreen() {
        print("🚀 navigateToLoginScreen вызван в MockProfileView")
        didNavigateToLogin = true
    }

    func presentAlert(_ alert: UIAlertController) {
        didPresentAlert = true
    }
}
