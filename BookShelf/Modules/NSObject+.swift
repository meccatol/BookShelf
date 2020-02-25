//
//  NSObject+.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/23.
//  Copyright © 2020 cream. All rights reserved.
//

import Foundation

extension NSObject {
    
    func setAssociatedObject(value: Any, key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func getAssociatedObject(key: UnsafeRawPointer) -> Any? {
        return objc_getAssociatedObject(self, key)
    }
}
