//
//  ViewController.swift
//  TowerDefense
//
//  Created by Gabriel Siu on 2022-07-15.
//

import UIKit

class ViewController: UIViewController {
    
    var enemies = [Enemy]()
    var towers = [Tower]()
    var projectiles = [Projectile]()
    
    var obstacleTiles = [UIView]()
    
    var testTimer: Timer?
    
    var enemyMoveTimer: Timer?
    var enemyPositionTimer: Timer?
    
    // Grid
    let numTilesHorizontal = 8
    var tileLength: CGFloat {
        UIScreen.main.bounds.width / CGFloat(numTilesHorizontal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
        
        NotificationCenter.default.addObserver(self, selector: #selector(fireProjectile(_:)),
                                               name: Notification.Name("projectileFired"), object: nil)
        setupTimers()
        
        setupGrid()
        setupEnemyButton()
        setupTowerTap()
    }
    
    // MARK: Setup
    
    func setupGrid() {
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
                    view.addSubview(tile)
                    obstacleTiles.append(tile)
                }
            }
        }
    }
    
    func setupTimers() {
        testTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(alsdjf), userInfo: nil, repeats: true)
        
        enemyMoveTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(moveEnemies), userInfo: nil, repeats: true)
        enemyPositionTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(updatePositions), userInfo: nil, repeats: true)
    }
    
    func setupEnemyButton() {
        let button = UIButton()
        button.addTarget(self, action: #selector(addEnemy), for: .touchUpInside)
        button.setTitle("Rickyy", for: .normal)
        view.addSubview(button)
        button.setAxisConstraints(xAnchor: view.centerXAnchor, yAnchor: view.centerYAnchor)
    }
    
    func setupTowerTap() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addTower(tap:))))
    }
    
    // MARK: Actions
    
    @objc func alsdjf() {
//        let positions = enemies.map { $0.center }
//        print(positions)
//        print(projectiles.map { $0.superview!.bounds.contains($0.frame) })
//        print(projectiles)
        print(enemies.map { $0.color })
    }
    
    @objc func moveEnemies() {
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
    
    @objc func updatePositions() {
        enemies = enemies.filter { $0.center.x < 450 }
        EnemyPositionService.instance.updatePositions(enemies.map { $0.center })
    }
    
    @objc func addEnemy() {
        let enemy = Enemy(hitpoints: 3, length: tileLength, startPoint: CGPoint(x: 0, y: 4), initialDirection: .right)
        view.addSubview(enemy)
        enemies.append(enemy)
    }
    
    @objc func addTower(tap: UITapGestureRecognizer) {
        let point = tap.location(in: view)
        let tower = Tower(point.x - 25, point.y - 25)
        view.addSubview(tower)
        towers.append(tower)
    }
    
    @objc func fireProjectile(_ notification: Notification) {
        if let info = notification.object as? ProjectileInfo {
            let projectile = Projectile(info.origin.x, info.origin.y, info.xStep, info.yStep)
            view.addSubview(projectile)
            projectiles.append(projectile)
        }
    }
}












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
    
    func setSquareAspectRatio(sideLength: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: sideLength).isActive = true
        heightAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
}
