//
//  Book.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/20.
//  Copyright © 2020 cream. All rights reserved.
//

import Foundation

/*
 * isbn : The International Standard Book Number (ISBN) is a numeric commercial book identifier which is intended to be unique.
 * cf) https://en.wikipedia.org/wiki/International_Standard_Book_Number
 */

struct Book: Codable {
    let title, subtitle, isbn13, price: String
    let imageUrl, link: URL
    
    private enum CodingKeys: String, CodingKey {
        case title, subtitle, isbn13, price
        case imageUrl = "image"
        case link = "url"
    }
}
