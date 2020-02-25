//
//  CellModelable.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/22.
//  Copyright © 2020 cream. All rights reserved.
//

import UIKit

protocol AbstractCellRepresentable: UITableViewCell {
    /// dequeue Cell from tableView at indexPath
    static func dequeue(from tableView: UITableView, for indexPath: IndexPath) -> Self
    /// bindind CellModel to cell
    func binding(with abstractCellModel: AbstractCellModelRepresentable)
}
    
extension AbstractCellRepresentable {
    static func dequeue(from tableView: UITableView, for indexPath: IndexPath) -> Self {
        return tableView.dequeueReusableCell(withIdentifier: String(describing: self), for: indexPath) as! Self
    }
}

protocol CellRepresentable: AbstractCellRepresentable {
    associatedtype CellModel
    
    func binding(with cellModel: CellModel)
}

extension CellRepresentable {
    
    func binding(with abstractCellModel: AbstractCellModelRepresentable) {
        guard let cellModel = abstractCellModel as? CellModel else { return }
        self.binding(with: cellModel)
    }
}
