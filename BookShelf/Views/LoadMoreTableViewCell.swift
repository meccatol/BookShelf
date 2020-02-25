//
//  LoadMoreTableViewCell.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/23.
//  Copyright © 2020 cream. All rights reserved.
//

import UIKit
import Combine

class LoadMoreTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var activityObserver = [AnyCancellable]()
}

extension LoadMoreTableViewCell: CellRepresentable {
    
    func binding(with cellModel: LoadMoreCellModel) {
        
        self.activityObserver.append(cellModel.isLoading.sink(receiveValue: { [weak self] isLoading in
            isLoading ? self?.activityIndicator?.startAnimating() : self?.activityIndicator?.stopAnimating ()
        }))
        
        self.activityObserver.append(cellModel.visibleRatio.sink(receiveValue: { [weak self, weak cellModel] visibleRatio in
            
            let triggerThreshold = visibleRatio * 1.3
            self?.activityIndicator.alpha = CGFloat(min(max(triggerThreshold, 0.0), 1.0))
            
            if let cellModel = cellModel, !cellModel.isLoading.value, triggerThreshold >= 1.0 {
                cellModel.loadAction()
            }
        }))
    }
}
