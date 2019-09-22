//
//  FavoritesViewController.swift
//  Chizu
//
//  Created by Apple User on 9/22/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
}

extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoritesData.favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: String(describing: FavoritesCell.self)) as! FavoritesCell
        let favorite = FavoritesData.favorites[indexPath.row]
        
        cell.configureWithPOI(favorite)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension FavoritesViewController: UITableViewDelegate {
    
}

class FavoritesCell: UITableViewCell {
    @IBOutlet weak var poiName: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconImageBackgroundView: UIView!
    
    private var poi: POIType!
    
    func configureWithPOI(_ poi: POIType) {
        self.poi = poi
        
        self.iconImageView.image = poi.iconImage()
        self.iconImageView.tintColor = .white
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.width / 2
    }
}
