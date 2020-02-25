//
//  BookListTableViewCell.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/22.
//  Copyright © 2020 cream. All rights reserved.
//

import UIKit

class BookListTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
}

extension BookListTableViewCell: CellRepresentable {
    
    func binding(with cellModel: BookListCellModel) {
        self.thumbnailImageView.loadImage(by: cellModel.thumbnailUrl)
        self.titleLabel.text = cellModel.title
        self.subtitleLabel.text = cellModel.subtitle
        self.priceLabel.text = cellModel.price
    }
}
