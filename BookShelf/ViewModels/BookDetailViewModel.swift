//
//  BookDetailViewModel.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/23.
//  Copyright © 2020 cream. All rights reserved.
//

import Foundation
import Combine

class BookDetailViewModel {
    
    let thumbnailUrl: URL
    let title: String
    let subtitle: String
    let authors: String
    let desc: String
    let price: String
    let link: URL
    let isbn13: String
    var memo: String?
    
    init(with bookDetail: BookDetail) {
        self.thumbnailUrl = bookDetail.imageUrl
        self.title = bookDetail.title
        self.subtitle = bookDetail.subtitle
        self.authors = bookDetail.authors
        self.desc = bookDetail.desc
        self.price = bookDetail.price
        self.link = bookDetail.link
        self.isbn13 = bookDetail.isbn13
    }
    
    var cacheKey: String {
        return "book." + self.isbn13 + ".memo"
    }
    
    func saveMemoIfPossible() {
        if let memo = memo, !memo.isEmpty,
            let memoData = memo.data(using: .utf8) {
            DataCache.shared.setData(memoData, key: self.cacheKey)
        } else {
            DataCache.shared.removeData(withKey: self.cacheKey)
        }
    }
    
    func restoreMemoIfPossible(completion: VoidCompletion? = nil) {
        
        if DataCache.shared.hasCachedData(withKey: self.cacheKey) {
            
            let semaphore = DispatchSemaphore(value: 1)
            
            DispatchQueue.global().async {
                DataCache.shared.getData(withKey: self.cacheKey) { [weak self] data in
                    if let memoData = data, let memo = String(data: memoData, encoding: .utf8) {
                        self?.memo = memo
                    }
                    semaphore.signal()
                }
                semaphore.wait()
                completion?()
            }
        } else {
            completion?()
        }
    }
}
