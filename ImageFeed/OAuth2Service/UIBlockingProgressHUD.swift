//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Diana Viter on 04.01.2025.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        UIApplication.shared.windows.first
    }
    
    static func show () {
        window?.isUserInteractionEnabled = true
        ProgressHUD.animate()
    }
    
    static func dismiss () {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}

