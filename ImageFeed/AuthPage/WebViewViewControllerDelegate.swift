//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Diana Viter on 01.03.2025.
//


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

final class WebViewViewController: UIViewController {
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    weak var delegate: WebViewViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        webView.isUserInteractionEnabled = true

        // Добавляем наблюдение за прогрессом загрузки страницы
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [],
            changeHandler: { [weak self] _, _ in
                self?.updateProgress()
            }
        )

        loadAuthView()
        updateProgress()
        
        print("✅ WebViewViewController загружен, delegate: \(String(describing: delegate))")
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: UnsplashAuthorizeURLString) else { 
            print("🚨 Ошибка: не удалось создать URLComponents")
            return 
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else { 
            print("🚨 Ошибка: не удалось создать URL")
            return 
        }
        
        let request = URLRequest(url: url)
        
        print("🔗 Загружаем URL: \(url.absoluteString)")
        webView.load(request)
    }

    @IBAction private func didTapBackButton(_ sender: Any?) {
        print("🔙 Кнопка Назад нажата")
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
        print("🌍 Навигация по URL: \(navigationAction.request.url?.absoluteString ?? "Unknown")")

        if let code = code(from: navigationAction) {
            print("✅ Код авторизации получен: \(code)")
            print("✅ Делегат перед вызовом: \(String(describing: delegate))")
            
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        guard let url = navigationAction.request.url else {
            print("🚨 Ошибка: URL отсутствует в navigationAction")
            return nil
        }

        print("🔍 Проверяем URL: \(url.absoluteString)")

        guard let urlComponents = URLComponents(string: url.absoluteString),
              urlComponents.path == "/oauth/authorize/native",
              let items = urlComponents.queryItems,
              let codeItem = items.first(where: { $0.name == "code" }) else {
            print("❌ Код не найден в URL")
            return nil
        }

        print("✅ Найден код: \(codeItem.value ?? "nil")")
        return codeItem.value
    }
}
