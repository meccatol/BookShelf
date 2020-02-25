//
//  LoadMoreCellModel.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/23.
//  Copyright © 2020 cream. All rights reserved.
//

import Foundation
import Combine

class LoadMoreCellModel: CellModelRepresentable {
    var cellType = LoadMoreTableViewCell.self
    let isLoading = CurrentValueSubject<Bool, Never>(false)
    let visibleRatio = CurrentValueSubject<Double, Never>(0.0)
    let loadAction: VoidCompletion
    
    init(loadAction: @escaping VoidCompletion) {
        self.loadAction = loadAction
    }
}
