//
//  UIImageView+.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/22.
//  Copyright © 2020 cream. All rights reserved.
//

import UIKit

extension UIImageView {
    
    private struct AssociatedKey {
        static var loadedUrlKey = 0
    }
    
    func loadImage(by url: URL?) {
        let loadedUrlString = self.getAssociatedObject(key: &AssociatedKey.loadedUrlKey) as? String
        
        if let url = url, loadedUrlString != url.absoluteString {
            self.image = nil
            self.setAssociatedObject(value: url.absoluteString, key: &AssociatedKey.loadedUrlKey)
            
            DispatchQueue.global().async { [weak self] in
                
                let getDataOfUrl = {
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        
                        let currentLoadedUrlString = self?.getAssociatedObject(key: &AssociatedKey.loadedUrlKey) as? String
                        
                        guard currentLoadedUrlString == url.absoluteString else { return }
                        
                        ImageCache.shared.setImage(image, key: url.cacheKey)
                        DispatchQueue.main.async {
                            self?.image = image
                        }
                    }
                }
                
                if ImageCache.shared.hasCachedImage(withKey: url.cacheKey) {
                    ImageCache.shared.getImage(withKey: url.cacheKey, completion: { image in
                        
                        let currentLoadedUrlString = self?.getAssociatedObject(key: &AssociatedKey.loadedUrlKey) as? String
                        
                        guard currentLoadedUrlString == url.absoluteString else { return }
                        
                        if let image = image {
                            DispatchQueue.main.async {
                                self?.image = image
                            }
                        } else {
                            getDataOfUrl()
                        }
                    })
                } else {
                    getDataOfUrl()
                }
            }
        }
    }
}
