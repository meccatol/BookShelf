//
//  SecondViewController.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/19.
//  Copyright © 2020 cream. All rights reserved.
//

import UIKit
import Combine

class SearchBookViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    private let searchController = UISearchController(searchResultsController: nil)
    
    var searchedBooksViewModel: SearchBookListViewModel? {
        didSet {
            if let searchedBooksViewModel = self.searchedBooksViewModel, !searchedBooksViewModel.bookCellModels.isEmpty {
                searchedBooksViewModel.cacheSearchedResult()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setups()
    }
    
    //MARK: - Setups
    private func setups() {
        
        self.navigationItem.title = "Book Search"
        
        BookListCellModel.CellType.registerWithNib(to: self.tableView)
        LoadMoreCellModel.CellType.registerWithNib(to: self.tableView)
        
        //Setup Search Controller
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search book what you want to find"
        self.searchController.searchBar.delegate = self
        self.definesPresentationContext = true
        self.navigationItem.searchController = self.searchController
        
        #if DEBUG
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(cleanCache))
        #endif
    }
    
    //MARK: - Fetch
    private func fetch(with searchText: String?, page: String? = nil, completion: (() -> Void)? = nil) {
        
        guard let searchText = searchText?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), !searchText.isEmpty else {
            completion?()
            return
        }
        
        // 검색어가 같다면, 더 높은 페이지를 검색해야 진행
        if let searchedBooksViewModel = self.searchedBooksViewModel,
            searchedBooksViewModel.lastSearchedText == searchText, let page = page,
            searchedBooksViewModel.page >= Int(page) ?? 0 {
            completion?()
            return
        }
        
        // 검색어가 다르다면, page가 nil이어야 함
        if self.searchedBooksViewModel?.lastSearchedText != searchText, page != nil {
            completion?()
            return
        }
        
        LoadingHUD.startLoading()
        
        let searchAPICall = { [weak self] in
            
            APIClient<API.Book>.request(.search(searchText, page), decodedType: BookList.self) { (response) in
                
                defer {
                    completion?()
                    LoadingHUD.stopLoading()
                }
                
                guard let bookList = response.decodedObject, response.error == nil else {
                    self?.searchedBooksViewModel = nil
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                    if let error = response.error {
                        let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                        self?.present(alertController, animated: true, completion: nil)
                    }
                    return
                }
                
                self?.searchBookListCompletion(bookList: bookList, searchText: searchText)
            }
        }
        
        // Attempt restoration only at first search
        let cacheKey = searchText.lowercased()
        if page == nil && DataCache.shared.hasCachedData(withKey: cacheKey) {
            
            DispatchQueue.global().async { [weak self] in
                
                DataCache.shared.getData(withKey: cacheKey) { cachedSearchData in
                    
                    if let cachedSearchData = cachedSearchData, let bookList = cachedSearchData.decoded(to: BookList.self) {
                        
                        self?.searchBookListCompletion(bookList: bookList, searchText: searchText, completion: completion)
                        LoadingHUD.stopLoading()
                    } else {
                        
                        searchAPICall()
                    }
                }
            }
        } else {
            searchAPICall()
        }
    }
    
    private func searchBookListCompletion(bookList: BookList, searchText: String, completion: (() -> Void)? = nil) {
        
        defer {
            completion?()
        }
        
        guard let searchedBooksListViewModel = SearchBookListViewModel(searchedBookList: bookList,
                                                                     lastSearchedText: searchText,
                                                                     loadAction: self.loadMoreAction()) else { return }
        
        if self.searchedBooksViewModel == nil || self.searchedBooksViewModel!.lastSearchedText != searchText {
            self.searchedBooksViewModel = searchedBooksListViewModel
        } else if let currentSearchedBooksViewModel = self.searchedBooksViewModel {
            currentSearchedBooksViewModel.appendMoreLoadedSearchedBooks(searchedBooksListViewModel)
            self.searchedBooksViewModel = currentSearchedBooksViewModel
        } else {
            self.searchedBooksViewModel = nil
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func loadMoreAction() -> VoidCompletion {
        
        return { [weak self] in
            
            guard let unwrappedSelf = self,
                let viewModel = unwrappedSelf.searchedBooksViewModel,
                viewModel.canLoadMore, !viewModel.isLoadingMore else { return }
            
            viewModel.isLoadingMore = true
            unwrappedSelf.fetch(with: viewModel.lastSearchedText, page: String(viewModel.page + 1)) { [weak self] in
                DispatchQueue.main.async {
                    viewModel.isLoadingMore = false
                }
                self?.updateNavigationTitle()
            }
        }
    }
    
    private func updateNavigationTitle() {
        
        DispatchQueue.main.async {
            guard let viewModel = self.searchedBooksViewModel else {
                self.navigationItem.title = "Book Search"
                return
            }
            self.navigationItem.title = "'\(viewModel.lastSearchedText)' books : \(viewModel.bookCellModels.count)"
        }
    }
    
    /// For testing: clean cache
    #if DEBUG
    @objc
    private func cleanCache() {
        
        let alert = UIAlertController(title: "Do you want to clean cached datas?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            ImageCache.shared.cleanCache()
            DataCache.shared.cleanCache()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    #endif
}

extension SearchBookViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchedBooksViewModel?.cellModels.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let newBooksViewModel = self.searchedBooksViewModel else {
            fatalError("newBooksViewModel is nil")
        }
        
        return newBooksViewModel.cellModels[indexPath.row].cell(from: tableView, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let searchedBooksViewModel = self.searchedBooksViewModel, indexPath.row < searchedBooksViewModel.bookCellModels.count else {
            fatalError("newBooksViewModel is nil")
        }
        let detailViewController = BookDetailViewController(isbn13: searchedBooksViewModel.bookCellModels[indexPath.row].isbn13)
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if self.searchedBooksViewModel?.canLoadMore ?? false,
            self.tableView.indexPathsForVisibleRows?.last?.row == self.tableView.numberOfRows(inSection: 0) - 1,
            let loadMoreCell = self.tableView.visibleCells.last as? LoadMoreTableViewCell {
            
            let intersectionFrame = self.tableView.frame.intersection(loadMoreCell.convert(loadMoreCell.bounds, to: nil))
            let visibleRatio = Double(intersectionFrame.height / loadMoreCell.frame.height)
            
            self.searchedBooksViewModel?.changedVisibleRatioOfLoadMoreCell(visibleRatio)
        }
    }
}

extension SearchBookViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchText = searchBar.text
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        self.searchController.isActive = false
        self.fetch(with: searchText) { [weak self] in
            self?.updateNavigationTitle()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = String()
        searchBar.resignFirstResponder()
    }
}
