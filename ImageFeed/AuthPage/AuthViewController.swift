//
//  AuthentificationViewController.swift
//  ImageFeed
//
//  Created by Diana Viter on 28.11.2024.
//

import UIKit
import ProgressHUD

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
    
    override func viewDidLoad() {
        loginButton.titleLabel?.font = UIFont(name: "SFProText-Bold", size: 17)
        loginButton.layer.cornerRadius = 16
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            let photo = photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL)
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
                delegate?.authViewController(self, didAuthenticateWithCode: code)
            case .failure:
                // TODO: Обработайте ошибку авторизации
                break
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

