//
//  BookList.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/23.
//  Copyright © 2020 cream. All rights reserved.
//

import Foundation

struct BookList: Codable {
    let error: String
    let total: String
    let page: String?
    let books: [Book]
    
    private enum CodingKeys: String, CodingKey {
        case error, total, page, books
    }
}
