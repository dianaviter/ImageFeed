//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Diana Viter on 11.11.2024.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    // MARK: - Properties
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    let token = OAuth2TokenStorage().token
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlackIOS
        setupConstraints()
        observeProfileImageChanges()
        fetchProfileData()
        
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        view.addSubview(logoutButton)
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapLogoutButton() {
        OAuth2Service.shared.logout()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let authVC = storyboard.instantiateViewController(identifier: "AuthViewController") as? AuthViewController else {
            print("Failed to create AuthViewController")
            return
        }
        authVC.modalPresentationStyle = .fullScreen
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = authVC
            window.makeKeyAndVisible()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupConstraints () {
        [avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.heightAnchor.constraint(equalToConstant: 24),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }
    
    private func observeProfileImageChanges() {
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
            self.updateProfileImage(profileImage: profileImage)
        }
    }
    
    private func fetchProfileData () {
        guard let token = token else {
            print("Token is nil")
            return
        }
        
        profileService.fetchProfile(token) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.updateProfile(profile: profile)
                self?.profileImageService.fetchProfileImage(token) { imageResult in
                    switch imageResult {
                    case .success(let profileImage):
                        self?.updateProfileImage(profileImage: profileImage)
                    case .failure (let error):
                        print ("Failed to fetch profile (Image): \(error)")
                    }
                }
            case .failure (let error):
                print ("Failed to fetch profile: \(error)")
            }
        }
    }
    
    private func updateProfile (profile: ProfileService.Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    private func updateProfileImage(profileImage: ProfileImageService.ProfileImage) {
        guard let imageUrlString = profileImage.profileImage.medium,
              let imageUrl = URL(string: imageUrlString) else {
            return
        }
        avatarImageView.kf.setImage(with: imageUrl)
    }
    
    // MARK: - UI Elements
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "UserPic"))
        imageView.frame = CGRect(x: 100, y: 100, width: 70, height: 70)
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        
        return imageView
    } ()
    
    private let nameLabel: UILabel = {
        let label = UILabel ()
        label.textColor = .white
        label.font = UIFont(name: "SFProText-Bold", size: 23)
        return label
    } ()
    
    private let loginNameLabel: UILabel = {
        let label = UILabel ()
        label.textColor = .ypGray
        label.font = UIFont(name: "SFProText-Regular", size: 13)
        return label
    } ()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel ()
        label.textColor = .white
        label.font = UIFont(name: "SFProText-Regular", size: 13)
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton ()
        let imageButton = UIImage(named: "Exit")
        button.setImage(imageButton, for: .normal)
        return button
        
    } ()
}
