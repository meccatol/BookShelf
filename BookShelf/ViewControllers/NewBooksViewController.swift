//
//  FirstViewController.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/19.
//  Copyright © 2020 cream. All rights reserved.
//

import UIKit

class NewBooksViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    var newBooksViewModel: NewBookListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setups()
        self.fetch()
    }
    
    //MARK: - Setups
    private func setups() {
        self.navigationItem.title = "What's new!"
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(self.handleRefreshControl), for: .valueChanged)
        BookListCellModel.CellType.registerWithNib(to: self.tableView)
    }
    
    //MARK: - Fetch
    private func fetch(completion: (() -> Void)? = nil) {
        LoadingHUD.startLoading()
        
        APIClient<API.Book>.request(.new, decodedType: BookList.self) { [weak self] (response) in
            defer {
                completion?()
                LoadingHUD.stopLoading()
            }
            
            guard let unwrappedSelf = self, let bookList = response.decodedObject, response.error == nil else {
                if let error = response.error {
                    let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                    self?.present(alertController, animated: true, completion: nil)
                }
                return
            }
            
            unwrappedSelf.newBooksViewModel = NewBookListViewModel(books: bookList.books)
            DispatchQueue.main.async {
                unwrappedSelf.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Actions
    @objc
    private func handleRefreshControl() {
        self.fetch { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
    }
}

extension NewBooksViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newBooksViewModel?.cellModels.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let newBooksViewModel = self.newBooksViewModel else {
            fatalError("newBooksViewModel is nil")
        }
        
        return newBooksViewModel.cellModels[indexPath.row].cell(from: tableView, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let newBooksViewModel = self.newBooksViewModel else {
            fatalError("newBooksViewModel is nil")
        }
        let detailViewController = BookDetailViewController(isbn13: newBooksViewModel.cellModels[indexPath.row].isbn13)
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

