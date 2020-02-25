//
//  URL+.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/23.
//  Copyright © 2020 cream. All rights reserved.
//

import Foundation

extension URL {
    
    var cacheKey: String {
        guard let lastComponent = self.pathComponents.last?.lowercased() else {
            fatalError("URL's last component is Empty")
        }
        return lastComponent
    }
}
