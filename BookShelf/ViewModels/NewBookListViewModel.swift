//
//  NewBooksViewModel.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/22.
//  Copyright © 2020 cream. All rights reserved.
//

import Foundation

class NewBookListViewModel {
    let cellModels: [BookListCellModel]
    
    init(books: [Book]) {
        self.cellModels = books.map { BookListCellModel(with: $0) }
    }
}
