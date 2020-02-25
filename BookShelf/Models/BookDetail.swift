//
//  RichBook.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/20.
//  Copyright © 2020 cream. All rights reserved.
//

import Foundation

struct BookDetail: Codable {
    let error: String
    let title, subtitle, authors, publisher, language : String
    let isbn10, isbn13, pages, year, rating, desc, price: String
    let imageUrl, link: URL
    
    private enum CodingKeys: String, CodingKey {
        case error, title, subtitle, authors, publisher, language, isbn10, isbn13, pages, year, rating, desc, price
        case imageUrl = "image"
        case link = "url"
    }
}
