//
//  BookDetailViewController.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/20.
//  Copyright © 2020 cream. All rights reserved.
//

import UIKit

class BookDetailViewController: UIViewController {
    
    @IBOutlet private weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var authorsLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var descLabel: UILabel!
    @IBOutlet private weak var linkButton: UIButton!
    @IBOutlet private weak var memoLabel: UILabel!
    @IBOutlet private weak var memoLabelToDescBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var textViewBottomConstraint: NSLayoutConstraint!
    private weak var rightBarButtonItem: UIBarButtonItem!
    
    private let isbn13OfTargetBook: String
    private var viewModel: BookDetailViewModel!
    
    init(isbn13: String) {
        self.isbn13OfTargetBook = isbn13
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setups()
        self.fetch()
    }
    
    //MARK: - Setups
    private func setups() {
        self.navigationItem.title = "Book Detail"
        self.titleLabel.text = nil
        self.subtitleLabel.text = nil
        self.authorsLabel.text = nil
        self.priceLabel.text = nil
        self.descLabel.text = nil
        self.linkButton.isHidden = true
        self.memoLabel.isHidden = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(touchUpInsideOfRightBarSaveButton))
        self.rightBarButtonItem = self.navigationItem.rightBarButtonItem
        self.rightBarButtonItem.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustTextViewConstraint(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustTextViewConstraint(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: - Fetch
    private func fetch(completion: (() -> Void)? = nil) {
        
        LoadingHUD.startLoading()
        APIClient<API.Book>.request(.detail(self.isbn13OfTargetBook), decodedType: BookDetail.self) { [weak self] (response) in
            defer {
                completion?()
                LoadingHUD.stopLoading()
            }
            
            guard let unwrappedSelf = self, let bookDetail = response.decodedObject, response.error == nil else {
                if let error = response.error {
                    let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                    self?.present(alertController, animated: true, completion: nil)
                }
                return
            }
            
            unwrappedSelf.viewModel = BookDetailViewModel(with: bookDetail)
            unwrappedSelf.viewModel.restoreMemoIfPossible {
                DispatchQueue.main.async {
                    self?.binding()
                }
            }
        }
    }
    
    private func binding() {
        self.thumbnailImageView.loadImage(by: self.viewModel.thumbnailUrl)
        self.titleLabel.text = self.viewModel.title
        self.subtitleLabel.text = self.viewModel.subtitle
        self.authorsLabel.text = self.viewModel.authors
        self.priceLabel.text = self.viewModel.price
        self.descLabel.text = self.viewModel.desc
        self.linkButton.isHidden = false
        self.memoLabel.isHidden = false
        self.textView.text = self.viewModel.memo
        self.textView.layer.cornerRadius = 4
        self.textView.layer.borderWidth = 0.5
        self.textView.layer.borderColor = UIColor(white: 0.2, alpha: 1.0).cgColor
    }
    
    @IBAction
    private func touchUpInsideOfLinkButton(_ sender: UIButton) {
        if UIApplication.shared.canOpenURL(self.viewModel.link) {
            UIApplication.shared.open(self.viewModel.link, options: [:], completionHandler: nil)
        }
    }
    
    @objc
    private func touchUpInsideOfRightBarSaveButton() {
        self.textView.resignFirstResponder()
        self.viewModel.memo = self.textView.text
        self.viewModel.saveMemoIfPossible()
    }
    
    @objc
    private func adjustTextViewConstraint(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo,
            let isLocal = userInfo[UIResponder.keyboardIsLocalUserInfoKey] as? Bool,
            let keyboardEndFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let windowBounds = self.view.window?.bounds else { return }
        
        guard isLocal else { return }
        
        if windowBounds.height == keyboardEndFrame.minY { // dismiss
            self.textViewBottomConstraint.constant = 20.0 // default value
            self.memoLabelToDescBottomConstraint.constant = 10
            self.descLabel.alpha = 1.0
        } else {
            self.textViewBottomConstraint.constant = windowBounds.height - keyboardEndFrame.minY + 20 - self.view.safeAreaInsets.bottom
            self.memoLabelToDescBottomConstraint.constant = -self.descLabel.frame.height
            self.descLabel.alpha = 0.0
        }
        
        UIView.animate(withDuration: userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval) {
            self.view.layoutIfNeeded()
        }
    }
}

extension BookDetailViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.rightBarButtonItem.isEnabled = true
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.rightBarButtonItem.isEnabled = false
        return true
    }
}
