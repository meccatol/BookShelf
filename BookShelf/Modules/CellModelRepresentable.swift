//
//  CellModelRepresentable.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/22.
//  Copyright © 2020 cream. All rights reserved.
//

import UIKit

protocol AbstractCellModelRepresentable {
    
    func cell(from tableView: UITableView, for indexPath: IndexPath) -> AbstractCellRepresentable
}

protocol CellModelRepresentable: AbstractCellModelRepresentable {
    associatedtype CellType: AbstractCellRepresentable
    var cellType: CellType.Type { get set }
}

extension CellModelRepresentable {
    func cell(from tableView: UITableView, for indexPath: IndexPath) -> AbstractCellRepresentable {
        let cell = self.cellType.dequeue(from: tableView, for: indexPath)
        cell.binding(with: self)
        return cell
    }
}
