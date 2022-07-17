//
//  Tower.swift
//  TowerDefense
//
//  Created by Gabriel Siu on 2022-07-15.
//

import UIKit

struct ProjectileInfo {
    let xStep: CGFloat
    let yStep: CGFloat
    let origin: CGPoint
}

class Tower: UIView {
    
    var fireRate: CGFloat = 1
    var fireTimer: Timer?
    
    init(_ x: CGFloat, _ y: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: 50, height: 50))
        backgroundColor = .brown
        setupTimer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTimer() {
        fireTimer = Timer.scheduledTimer(timeInterval: fireRate, target: self, selector: #selector(fire), userInfo: nil, repeats: true)
    }
    
    @objc func fire() {
        guard let enemyPosition = EnemyPositionService.instance.firstEnemy() else { return }
//        print(frame)
//        print(enemyPosition)
        
        let xDiff = enemyPosition.x - frame.midX
        let yDiff = enemyPosition.y - frame.midY
        
        let hyp = sqrt(pow(xDiff, 2) + pow(yDiff, 2))
        
        let xStep = 3 * xDiff / hyp
        let yStep = 3 * yDiff / hyp
        
        let info = ProjectileInfo(xStep: xStep, yStep: yStep, origin: CGPoint(x: frame.midX, y: frame.midY))
        
        NotificationCenter.default.post(name: Notification.Name("projectileFired"), object: info)
    }
    
}
