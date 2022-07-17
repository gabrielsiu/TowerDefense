//
//  Enemy.swift
//  TowerDefense
//
//  Created by Gabriel Siu on 2022-07-15.
//

import UIKit

enum Direction {
    case up
    case down
    case left
    case right
}

class Enemy: UIView {
    var direction: Direction
    var invalidDirection: Direction
    
    var hitpoints: Int
    
    var color: UIColor {
        switch hitpoints {
        case 3: return .green
        case 2: return .blue
        case 1: return .red
        default: return .black
        }
    }
    
    var speed: CGFloat {
        switch hitpoints {
        case 3: return 1
        case 2: return 0.75
        case 1: return 0.5
        default: return 0
        }
    }
    
    var isValid = true
    
    init(hitpoints: Int, length: CGFloat, startPoint: CGPoint, initialDirection: Direction) {
        self.hitpoints = hitpoints
        self.direction = initialDirection
        self.invalidDirection = .left // TODO
        super.init(frame: CGRect(x: startPoint.x * length, y: startPoint.y * length, width: length, height: length))
        
        backgroundColor = color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func switchDirection() {
        switch direction {
        case .up: direction = .right
        case .right: direction = .down
        case .down: direction = .left
        case .left: direction = .up
        }
    }
    
    func setInvalidDirection() {
        switch direction {
        case .up: invalidDirection = .down
        case .down: invalidDirection = .up
        case .left: invalidDirection = .right
        case .right: invalidDirection = .left
        }
    }
    
    func newRect(_ distance: CGFloat? = nil) -> CGRect {
        let offset: CGFloat
        if let distance = distance, distance != 0 {
            offset = distance
        } else {
            offset = speed
        }
        
        switch direction {
        case .up: return frame.offsetBy(dx: 0, dy: -offset)
        case .down: return frame.offsetBy(dx: 0, dy: offset)
        case .left: return frame.offsetBy(dx: -offset, dy: 0)
        case .right: return frame.offsetBy(dx: offset, dy: 0)
        }
    }
    
    func move(_ distance: CGFloat? = nil) {
        let offset: CGFloat
        if let distance = distance, distance != 0 {
            offset = distance
        } else {
            offset = speed
        }
        
        switch direction {
        case .up: center.y = center.y - offset
        case .down: center.y = center.y + offset
        case .left: center.x = center.x - offset
        case .right: center.x = center.x + offset
        }
        
        
        // TODO: Remove when end detection added
        if center.x >= 450 {
            removeFromSuperview()
        }
    }
    
    func decrementHitpoints() {
        guard isValid else { return }
        
        hitpoints -= 1
        
        if hitpoints <= 0 {
            removeFromSuperview()
        } else {
            backgroundColor = color
        }
    }
    
    func invalidate() {
        isValid = false
        hitpoints = 0
        backgroundColor = color
    }
}
