//
//  Projectile.swift
//  TowerDefense
//
//  Created by Gabriel Siu on 2022-07-15.
//

import UIKit

class Projectile: UIView {
    var xStep: CGFloat
    var yStep: CGFloat
    
    init(_ x: CGFloat, _ y: CGFloat, _ xStep: CGFloat, _ yStep: CGFloat) {
        self.xStep = xStep
        self.yStep = yStep
        super.init(frame: CGRect(x: x, y: y, width: 20, height: 20))
        backgroundColor = .yellow
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move() {
        center.x = center.x + xStep
        center.y = center.y + yStep
    }
}
