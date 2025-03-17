//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Diana Viter on 01.12.2024.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController, AuthViewControllerDelegate, WebViewViewControllerDelegate {

    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        print("Code received in authViewController: \(code)")
        
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                print("Token received")
                self.switchToTabBarController()
            case .failure:
                print("Failed to receive token")
                self.showErrorAlert()
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        print("Authorization is cancelled by user")
        vc.dismiss(animated: true)
        showErrorAlert()
    }
    
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private var username: String?
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = .ypBlackIOS
        setupConstraints()

        if oauth2TokenStorage.token != nil {
            switchToTabBarController()
        } else {
            showAuthScreen()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        
        guard let token = oauth2TokenStorage.token else { return }
        fetchProfile(token)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func showAuthScreen () {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private let splashImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "SplashScreenLogo"))
        imageView.frame = CGRect(x: 100, y: 100, width: 75, height: 78)
        return imageView
    } ()
    
    private func setupConstraints () {
        splashImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(splashImage)
        
        NSLayoutConstraint.activate([
            splashImage.widthAnchor.constraint(equalToConstant: 75),
            splashImage.heightAnchor.constraint(equalToConstant: 78),
            splashImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            splashImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    
    private func showErrorAlert () {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: "Oк",
            style: .default) { _ in
                alert.dismiss(animated: true)
            }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure(let error):
                self.showErrorAlert()
                print ("Failed to fetch profile: \(error)")
            }
        }
        profileImageService.fetchProfileImage(token) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure(let error):
                self.showErrorAlert()
                print ("Failed to fetch profile (Image): \(error)")
            }
        }
    }

    func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    private func didAuthenticate(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
        guard let token = oauth2TokenStorage.token else { return }
        fetchProfile(token)
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }

    func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure:
                break
            }
        }
    }
}
