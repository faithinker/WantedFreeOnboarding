//
//  UIView+.swift
//  Concurrency
//
//  Created by jhkim on 2023/02/20.
//

import UIKit

extension UIView {
    func addSubViews(_ view: [UIView]) {
        view.forEach { addSubview($0) }
    }
}
