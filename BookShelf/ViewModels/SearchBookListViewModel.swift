//
//  SearchBookListViewModel.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/23.
//  Copyright © 2020 cream. All rights reserved.
//

import Foundation

class SearchBookListViewModel {
    var page: Int
    let total: Int
    var bookCellModels: [BookListCellModel]
    var lastSearchedText: String
    let loadMoreCellModel: LoadMoreCellModel
    
    var canLoadMore: Bool {
        return self.bookCellModels.count < self.total
    }
    var isLoadingMore: Bool {
        get {
            self.loadMoreCellModel.isLoading.value
        }
        set {
            self.loadMoreCellModel.isLoading.value = newValue
        }
    }
    
    var cellModels: [AbstractCellModelRepresentable] {
        var cellModels = [AbstractCellModelRepresentable]()
        cellModels.append(contentsOf: self.bookCellModels)
        if self.canLoadMore {
            cellModels.append(self.loadMoreCellModel)
        }
        return cellModels
    }
    
    init?(searchedBookList: BookList, lastSearchedText: String, loadAction: @escaping VoidCompletion) {
        guard let pageString = searchedBookList.page,
            let page = Int(pageString), let total = Int(searchedBookList.total) else { return nil }
        self.page = page
        self.total = total
        self.bookCellModels = searchedBookList.books.map { BookListCellModel(with: $0) }
        self.lastSearchedText = lastSearchedText
        self.loadMoreCellModel = LoadMoreCellModel(loadAction: loadAction)
    }
    
    func appendMoreLoadedSearchedBooks(_ moreLoadedSearchedBooks: SearchBookListViewModel) {
        self.bookCellModels.append(contentsOf: moreLoadedSearchedBooks.bookCellModels)
        self.page = moreLoadedSearchedBooks.page
    }
    
    func changedVisibleRatioOfLoadMoreCell(_ visibleRatio: Double) {
        self.loadMoreCellModel.visibleRatio.value = visibleRatio
    }
    
    func cacheSearchedResult() {
        let cacheKey = self.lastSearchedText.lowercased()
        
        DispatchQueue.global().async {
            let bookListToCache = BookList(error: "0", total: String(self.total), page: String(self.page), books: self.bookCellModels.map{ $0.transformIntoBook() })
            if let dataToCache = try? JSONEncoder().encode(bookListToCache) {
                DataCache.shared.setData(dataToCache, key: cacheKey)
            }
        }
    }
}
