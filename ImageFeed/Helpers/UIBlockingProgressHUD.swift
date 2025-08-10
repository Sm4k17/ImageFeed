//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 27.07.2025.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD: UIViewController {
    
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
    
    static func succeed() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.succeed()
    }
    
    static func failed() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.failed()
    }
}
