//
//  UIView+Constraints.swift
//  TowerDefense
//
//  Created by Gabriel Siu on 2022-07-17.
//

import UIKit

extension UIView {
    
    func setEdgeConstraints(top: NSLayoutYAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, leading: NSLayoutXAxisAnchor? = nil, trailing: NSLayoutXAxisAnchor? = nil, padding: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
    }
    
    func setAxisConstraints(xAnchor: NSLayoutXAxisAnchor? = nil, yAnchor: NSLayoutYAxisAnchor? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        if let xAnchor = xAnchor {
            centerXAnchor.constraint(equalTo: xAnchor).isActive = true
        }
        if let yAnchor = yAnchor {
            centerYAnchor.constraint(equalTo: yAnchor).isActive = true
        }
    }
}
