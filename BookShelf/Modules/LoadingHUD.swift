//
//  LoadingHUD.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/25.
//  Copyright © 2020 cream. All rights reserved.
//

import UIKit

final class LoadingHUD {
    private static let indicatorView = UIActivityIndicatorView(style: .large)
    private static let containerView = UIView(frame: UIScreen.main.bounds)
    
    static func setups() {
        self.indicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.isOpaque = false
        self.containerView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        self.containerView.alpha = 1.0
        self.containerView.addSubview(self.indicatorView)
        self.containerView.addConstraints([self.containerView.centerXAnchor.constraint(equalTo: self.indicatorView.centerXAnchor),
                                           self.containerView.centerYAnchor.constraint(equalTo: self.indicatorView.centerYAnchor)])
    }
    
    static func startLoading() {
        DispatchQueue.main.async {
            self.containerView.alpha = 0.0
            UIView.animate(withDuration: 0.25) {
                self.containerView.alpha = 1.0
            }
            
            if (!self.containerView.subviews.contains(self.indicatorView)) { self.setups() }
            
            for window in UIApplication.shared.windows where window.isKeyWindow {
                if let rootViewController = window.rootViewController, !rootViewController.view.subviews.contains(self.containerView) {
                    rootViewController.view.addSubview(self.containerView)
                    rootViewController.view.bringSubviewToFront(self.containerView)
                    rootViewController.view.addConstraints(NSLayoutConstraint.fillConstraints(toParent: rootViewController.view, subView: self.containerView))
                }
            }
            
            self.indicatorView.startAnimating()
        }
    }
    
    static func stopLoading() {
        DispatchQueue.main.async {
            self.containerView.alpha = 1.0
            UIView.animate(withDuration: 0.25, animations: {
                self.containerView.alpha = 0.0
            }) { _ in
                self.indicatorView.stopAnimating()
                self.containerView.removeFromSuperview()
            }
        }
    }
}
