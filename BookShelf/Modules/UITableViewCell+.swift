//
//  UITableViewCell+.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/23.
//  Copyright © 2020 cream. All rights reserved.
//

import UIKit

public extension UITableViewCell {
    static func registerWithNib(to tableView: UITableView) {
        tableView.register(UINib(nibName: String(describing: self), bundle: nil), forCellReuseIdentifier: String(describing: self))
    }
}
