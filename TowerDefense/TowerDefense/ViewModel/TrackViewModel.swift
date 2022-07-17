//
//  TrackViewModel.swift
//  TowerDefense
//
//  Created by Gabriel Siu on 2022-07-17.
//

import UIKit

final class TrackViewModel {
    
    var enemies = [Enemy]()
    var towers = [Tower]()
    var projectiles = [Projectile]()
    
    var obstacleTiles = [UIView]()
    
    var testTimer: Timer?
    var enemyMoveTimer: Timer?
    var enemyPositionTimer: Timer?
    
    let numTilesHorizontal = 8
    var tileLength: CGFloat {
        UIScreen.main.bounds.width / CGFloat(numTilesHorizontal)
    }
    
    // MARK: Initialization
    
    init() {
        setupTimers()
    }
    
    // MARK: Setup
    
    func setupGrid() -> [UIView] {
        let grid = [[1, 1, 1, 1, 1, 1, 1, 1],
                    [1, 1, 1, 1, 1, 1, 1, 1],
                    [1, 1, 1, 1, 1, 1, 1, 1],
                    [1, 1, 1, 1, 1, 1, 1, 1],
                    [0, 0, 1, 1, 1, 1, 1, 1],
                    [1, 0, 1, 1, 1, 1, 1, 1],
                    [1, 0, 1, 1, 1, 1, 1, 1],
                    [1, 0, 1, 1, 1, 1, 0, 0],
                    [1, 0, 1, 1, 1, 1, 0, 1],
                    [1, 0, 1, 1, 1, 1, 0, 1],
                    [1, 0, 1, 1, 1, 1, 0, 1],
                    [1, 0, 1, 1, 1, 1, 0, 1],
                    [1, 0, 0, 0, 0, 0, 0, 1],
                    [1, 1, 1, 1, 1, 1, 1, 1],
                    [1, 1, 1, 1, 1, 1, 1, 1],
                    [1, 1, 1, 1, 1, 1, 1, 1],
                    [1, 1, 1, 1, 1, 1, 1, 1]]
        
        let numTilesVertical: Int = Int(floor(UIScreen.main.bounds.height / tileLength))
        for i in 0..<numTilesVertical {
            for j in 0..<numTilesHorizontal {
                let tile = UIView(frame: CGRect(x: CGFloat(j) * tileLength, y: CGFloat(i) * tileLength,
                                                width: tileLength, height: tileLength))
                tile.backgroundColor = .gray
                if grid[i][j] == 1 {
                    obstacleTiles.append(tile)
                }
            }
        }
        
        return obstacleTiles
    }
    
    func setupTimers() {
        testTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(alsdjf), userInfo: nil, repeats: true)
        
        enemyMoveTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(moveEnemies), userInfo: nil, repeats: true)
        enemyPositionTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(updatePositions), userInfo: nil, repeats: true)
    }
    
    // MARK: Public Methods
    
    func addEnemy(hitpoints: Int, startIndex: CGPoint) -> Enemy {
        let enemy = Enemy(hitpoints: hitpoints, length: tileLength, startPoint: startIndex,
                          initialDirection: .right) // TODO
        enemies.append(enemy)
        return enemy
    }
    
    func addTower(_ point: CGPoint) -> Tower {
        let dropPoint = CGPoint(x: point.x - (k.Sizes.towerSideLength / 2), y: point.y - (k.Sizes.towerSideLength / 2))
        let tower = Tower(point: dropPoint, range: 200)
        towers.append(tower)
        return tower
    }
    
    func addProjectile(_ info: ProjectileInfo) -> Projectile {
        let projectile = Projectile(info.origin.x, info.origin.y, info.xStep, info.yStep)
        projectiles.append(projectile)
        return projectile
    }
    
    // MARK: Actions
    
    @objc private func moveEnemies() {
        projectiles.forEach { $0.move() }
        enemies.forEach { enemy in
            
            var prevDirection: Direction?
            var finishDistance: CGFloat?
            var intersectingTiles = obstacleTiles.filter{ $0.frame.intersects(enemy.newRect()) }
            while !intersectingTiles.isEmpty {
                
                if prevDirection == nil {
                    prevDirection = enemy.direction
                    
                    let intersectingTile = intersectingTiles.first!
                    switch enemy.direction {
                    case .up: finishDistance = abs(intersectingTile.frame.maxY - enemy.frame.minY)
                    case .down: finishDistance = abs(intersectingTile.frame.minY - enemy.frame.maxY)
                    case .left: finishDistance = abs(intersectingTile.frame.maxX - enemy.frame.minX)
                    case .right: finishDistance = abs(intersectingTile.frame.minX - enemy.frame.maxX)
                    }
                    
                } else {
                    enemy.switchDirection()
                    
                    if enemy.direction == prevDirection {
                        enemy.invalidate()
                        break
                    }
                }
                
                if enemy.direction == enemy.invalidDirection { continue }
                
                intersectingTiles = obstacleTiles.filter { $0.frame.intersects(enemy.newRect(finishDistance)) }
            }
            enemy.setInvalidDirection()
            enemy.move(finishDistance)
        }
        
        var removedProjectiles = Set<Int>()
        var removedEnemies = Set<Int>()
        
        outer: for i in 0..<projectiles.count {
            if removedProjectiles.contains(i) { continue outer }
            
            if !projectiles[i].superview!.bounds.contains(projectiles[i].frame) {
                removedProjectiles.insert(i)
                continue outer
            }
            
            for j in 0..<enemies.count {
                if removedEnemies.contains(j) { continue outer }
                
                if projectiles[i].frame.intersects(enemies[j].frame) {
                    removedProjectiles.insert(i)
                    
                    enemies[j].decrementHitpoints()
                    if enemies[j].hitpoints <= 0 {
                        removedEnemies.insert(j)
                        continue outer
                    }
                }
            }
        }
        
        removedProjectiles.forEach { projectiles[$0].removeFromSuperview() }
        removedEnemies.forEach { enemies[$0].removeFromSuperview() }
        
        projectiles = projectiles.enumerated().filter({ !removedProjectiles.contains($0.offset) }).map { $0.element }
        enemies = enemies.enumerated().filter({ !removedEnemies.contains($0.offset) }).map { $0.element }
    }
    
    @objc private func updatePositions() {
        enemies = enemies.filter { $0.center.x < 450 }
        EnemyPositionService.instance.updatePositions(enemies.map { $0.center })
    }
    
    @objc private func alsdjf() {
//        let positions = enemies.map { $0.center }
//        print(positions)
//        print(projectiles.map { $0.superview!.bounds.contains($0.frame) })
//        print(projectiles)
//        print(enemies.map { $0.color })
    }
}
