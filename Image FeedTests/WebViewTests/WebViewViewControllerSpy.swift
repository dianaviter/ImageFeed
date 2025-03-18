//
//  WebViewViewControllerSpy.swift
//  ImageFeed
//
//  Created by Diana Viter on 17.03.2025.
//

import ImageFeed
import Foundation

final class WebViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: (any ImageFeed.WebViewPresenterProtocol)?
    var loadRequestCalled: Bool = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
    }
    
    func setProgressHidden(_ isHidden: Bool) {
    }
    
}
