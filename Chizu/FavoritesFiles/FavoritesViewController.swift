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
}

extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoritesData.favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "FavoritesCell")!
        let favorite = FavoritesData.favorites[indexPath.row]
        
        // Set cell's image data
        cell.imageView?.image = favorite.iconImage()
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.backgroundColor = favorite.iconBackgroundColor()
        if let width = cell.imageView?.frame.width {
            cell.imageView?.layer.cornerRadius = width / 2
        }
        
        cell.textLabel?.text = favorite.rawValue
        
        return cell
    }
    
    
}

extension FavoritesViewController: UITableViewDelegate {
    
}
