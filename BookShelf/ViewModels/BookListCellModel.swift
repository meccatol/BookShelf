//
//  BookListCellModel.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/22.
//  Copyright © 2020 cream. All rights reserved.
//

import Foundation

class BookListCellModel: CellModelRepresentable {
    var cellType = BookListTableViewCell.self
    
    let thumbnailUrl: URL
    let title: String
    let subtitle: String
    let price: String
    let isbn13: String
    let link: URL
    
    init(with book: Book) {
        self.thumbnailUrl = book.imageUrl
        self.title = book.title
        self.subtitle = book.subtitle
        self.price = book.price
        self.isbn13 = book.isbn13
        self.link = book.link
    }
    
    func transformIntoBook() -> Book {
        return Book(title: self.title, subtitle: self.subtitle, isbn13: self.isbn13, price: self.price, imageUrl: self.thumbnailUrl, link: self.link)
    }
}

extension BookListCellModel: Hashable {
    
    static func == (lhs: BookListCellModel, rhs: BookListCellModel) -> Bool {
        return lhs.isbn13 == rhs.isbn13
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.isbn13)
        hasher.combine(self.title)
    }
}
