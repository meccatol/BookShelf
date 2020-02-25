//
//  NSLayoutConstraint+.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/25.
//  Copyright © 2020 cream. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    
    static func fillConstraints(toParent parent: UIView, subView: UIView) -> [NSLayoutConstraint] {
        return [parent.leadingAnchor.constraint(equalTo: subView.leadingAnchor),
                parent.trailingAnchor.constraint(equalTo: subView.trailingAnchor),
                parent.topAnchor.constraint(equalTo: subView.topAnchor),
                parent.bottomAnchor.constraint(equalTo: subView.bottomAnchor)]
    }
}
