//
//  EnemyPositionService.swift
//  TowerDefense
//
//  Created by Gabriel Siu on 2022-07-16.
//

import UIKit

class EnemyPositionService {
    static let instance = EnemyPositionService()
    
    private var positions = [CGPoint]()
    
    func updatePositions(_ newPositions: [CGPoint]) {
        positions = newPositions
    }
    
    func firstEnemy() -> CGPoint? {
        return positions.first
    }
}
