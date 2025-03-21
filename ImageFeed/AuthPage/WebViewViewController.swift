//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Diana Viter on 28.11.2024.
//

import UIKit
import WebKit

fileprivate let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController, WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
    }
    
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    private let imagesListService = ImagesListService()
    
    weak var delegate: WebViewViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        webView.isUserInteractionEnabled = true
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [],
            changeHandler: { [weak self] _, _ in
                self?.updateProgress()
            }
        )

        loadAuthView()
        updateProgress()
        
        print("WebViewViewController loaded, delegate: \(String(describing: delegate))")
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: UnsplashAuthorizeURLString) else {
            print("Error: failed to create URLComponents")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            print("Error: failed to create URL")
            return
        }
        
        let request = URLRequest(url: url)
        
        print("Loading URL: \(url.absoluteString)")
        webView.load(request)
    }

    @IBAction private func didTapBackButton(_ sender: Any?) {
        delegate?.webViewViewControllerDidCancel(self)
        dismiss(animated: true)
    }

    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = abs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}

// MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        print("URL navigation: \(navigationAction.request.url?.absoluteString ?? "Unknown")")

        if let code = code(from: navigationAction) {
            print("Authorization code received: \(code)")
         if let delegate = delegate {
                delegate.webViewViewController(self, didAuthenticateWithCode: code)
            } else {
                print("Failed to set delegate")
            }
            dismiss(animated: true)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        guard let url = navigationAction.request.url else {
            print("Error: URL is missing in navigationAction")
            return nil
        }

        print("Checking URL: \(url.absoluteString)")

        guard let urlComponents = URLComponents(string: url.absoluteString),
              urlComponents.path == "/oauth/authorize/native",
              let items = urlComponents.queryItems,
              let codeItem = items.first(where: { $0.name == "code" }) else {
            print("Failed to find URL code")
            return nil
        }

        print("Code found: \(codeItem.value ?? "nil")")
        return codeItem.value
    }
}
