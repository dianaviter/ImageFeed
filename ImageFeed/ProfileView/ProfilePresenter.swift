//
// ProfilePresenter.swift
//  ImageFeed
//
//  Created by Diana Viter on 17.03.2025.
//

import UIKit

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    var profile: ProfileService.Profile? { get }
    var profileImage: ProfileImageService.ProfileImage? { get }
    var profileImageServiceObserver: NSObjectProtocol? { get set }
    var tokenStorage: TokenStorageProtocol? { get } 
    func showLogoutAlert()
    func fetchProfileData()
    func observeProfileImageChanges()
    func removeObserver()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var profile: ProfileService.Profile?
    var profileImage: ProfileImageService.ProfileImage?
    var profileImageServiceObserver: NSObjectProtocol?
    var tokenStorage: TokenStorageProtocol?

    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private var isDataLoaded = false

    init(
        view: ProfileViewControllerProtocol,
        profileService: ProfileServiceProtocol,
        profileImageService: ProfileImageServiceProtocol,
        tokenStorage: TokenStorageProtocol
    ) {
        self.view = view
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.tokenStorage = tokenStorage
    }
    
    func fetchProfileData() {
        guard let token = tokenStorage?.token else {
            print("Token is nil")
            return
        }
        print("🟢 Загружаем профиль")
        profileService.fetchProfile(token) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.view?.updateProfile(profile: profile)
                self?.profileImageService.fetchProfileImage(token) { imageResult in
                    switch imageResult {
                    case .success(let profileImage):
                        self?.view?.updateProfileImage(profileImage: profileImage)
                        self?.isDataLoaded = true
                        self?.view?.updateUIAfterDataLoad()
                    case .failure (let error):
                        print ("Failed to fetch profile (Image): \(error)")
                    }
                }
            case .failure (let error):
                print ("❌ Ошибка загрузки профиля:", error)
                print ("Failed to fetch profile: \(error)")
            }
        }
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )

        let yesAction = UIAlertAction(title: "Да", style: .default) { _ in
            self.logout()
        }

        let noAction = UIAlertAction(title: "Нет", style: .default, handler: nil)

        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        view?.presentAlert(alert)
    }
    
    func logout() {
        OAuth2Service.shared.logout()
        view?.navigateToLoginScreen()
    }

    func navigateToLoginScreen() {
        view?.navigateToLoginScreen()
    }
    
    func observeProfileImageChanges() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let userInfo = notification.userInfo as? [String: ProfileImageService.ProfileImage],
                  let profileImage = userInfo["profileImage"] else {
                return
            }
            view?.updateProfileImage(profileImage: profileImage)
        }
    }
    
    func removeObserver() {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
