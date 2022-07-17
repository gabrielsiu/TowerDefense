//
//  TrackVC.swift
//  TowerDefense
//
//  Created by Gabriel Siu on 2022-07-15.
//

import UIKit

final class TrackVC: UIViewController {
    
    private let viewModel: TrackViewModel
    
    // MARK: Initialization
    
    init(_ viewModel: TrackViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
        
        NotificationCenter.default.addObserver(self, selector: #selector(fireProjectile(_:)),
                                               name: Notification.Name(k.Notification.projectileFired), object: nil)
        
        viewModel.setupGrid().forEach { view.addSubview($0) }
        
        
        setupEnemyButton()
        setupTowerTap()
    }
    
    // MARK: Setup
    
    private func setupEnemyButton() {
        let button = UIButton()
        button.addTarget(self, action: #selector(towersButtonTapped), for: .touchUpInside)
        button.setTitle("Towers", for: .normal)
        view.addSubview(button)
        button.setEdgeConstraints(bottom: view.bottomAnchor, trailing: view.trailingAnchor,
                                  padding: UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 25))
    }
    
    private func setupTowerTap() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addTower(tap:))))
    }
    
    // MARK: Actions
    
    @objc private func towersButtonTapped() {
        let enemy = viewModel.addEnemy(hitpoints: 3, startIndex: CGPoint(x: 0, y: 4))
        view.addSubview(enemy)
    }
    
    @objc private func addTower(tap: UITapGestureRecognizer) {
        let tower = viewModel.addTower(tap.location(in: view))
        view.addSubview(tower)
    }
    
    @objc private func fireProjectile(_ notification: Notification) {
        if let info = notification.object as? ProjectileInfo {
            let projectile = viewModel.addProjectile(info)
            view.addSubview(projectile)
        }
    }
}
