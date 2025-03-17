//
//  AuthentificationViewController.swift
//  ImageFeed
//
//  Created by Diana Viter on 28.11.2024.
//

import UIKit
import ProgressHUD
import WebKit
    

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
    @IBOutlet var loginButton: UIButton!
    private let ShowWebViewSegueIdentifier = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?
    private let oauth2Service = OAuth2Service.shared
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    var photos: [Photo] = []
    let splashViewController = SplashViewController()
    
    override func viewDidLoad() {
        loginButton.titleLabel?.font = UIFont(name: "SFProText-Bold", size: 17)
        loginButton.layer.cornerRadius = 16
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewSegueIdentifier {
            guard let webViewVC = segue.destination as? WebViewViewController else {
                assertionFailure("Error: WebViewViewController not found")
                return
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewVC.presenter = webViewPresenter
            webViewPresenter.view = webViewVC
            webViewVC.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    
    private func configureBackButton () {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "Back button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "Back button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
        func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
            vc.dismiss(animated: true)
            
            UIBlockingProgressHUD.show()
            oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
                guard let self = self else { return }
                
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success:
                    print("Authorization is successfull, loading TabBarController")
                    splashViewController.switchToTabBarController()
                case .failure:
                    print("Authorization error")
                }
            }
        }
        
        func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
            vc.dismiss(animated: true)
        }
        
        private func switchToTabBarController() {
            guard let window = UIApplication.shared.windows.first else { return }
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController")
            window.rootViewController = tabBarController
        }
    }
