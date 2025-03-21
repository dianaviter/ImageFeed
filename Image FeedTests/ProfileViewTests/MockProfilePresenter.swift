//
//  Untitled.swift
//  ImageFeed
//
//  Created by Diana Viter on 18.03.2025.
//

import Foundation
@testable import ImageFeed

final class MockProfilePresenter: ProfilePresenterProtocol {
    var profile: ImageFeed.ProfileService.Profile?
    
    var profileImage: ImageFeed.ProfileImageService.ProfileImage?
    
    var profileImageServiceObserver: (any NSObjectProtocol)?
    
    var tokenStorage: (any ImageFeed.TokenStorageProtocol)?
    
    var view: ProfileViewControllerProtocol?
    var navigateToLoginScreenCalled = false

    func fetchProfileData() {}
    func showLogoutAlert() {}
    func observeProfileImageChanges() {}
    func removeObserver() {}

    func navigateToLoginScreen() {
        print("🚀 Метод navigateToLoginScreen вызван в ProfilePresenter")
        navigateToLoginScreenCalled = true
    }
}


