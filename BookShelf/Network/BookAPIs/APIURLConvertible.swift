//
//  API.Book.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/22.
//  Copyright © 2020 cream. All rights reserved.
//

import Foundation

protocol BookAPIURLConvertible: APIURLConvertible { }

extension BookAPIURLConvertible {
    
    var host: String {
        return "api.itbook.store"
    }
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = self.host
        components.path = self.path
        guard let url = components.url else { fatalError("failed to covert url") }
        return url
    }
}

extension API {
    
    enum Book: BookAPIURLConvertible {
        
        case new
        case detail(String)
        case search(String, String?)
        
        var path: String {
            switch self {
            case .new:
                return "/1.0/new"
            case .detail(let isbn13):
                return "/1.0/books/\(isbn13)"
            case .search(let query, let page):
                var path = "/1.0/search/\(query)"
                if let page = page {
                    path += "/\(page)"
                }
                return path
            }
        }
    }
}
