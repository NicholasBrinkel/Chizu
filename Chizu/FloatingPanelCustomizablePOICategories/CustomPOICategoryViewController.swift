//
//  FavoritesViewController.swift
//  Chizu
//
//  Created by Apple User on 9/22/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import UIKit

protocol POICategoriesDelegate: class {
    func poiTapped(_ poi: POIType)
}

enum POICategory: String {
    case favorites = "Favorites"
    case food = "Food & Drinks"
    case events = "Events"
    
    func POIs() -> [POIType] {
        switch self {
        case .favorites:
            return POICategoriesData.favorites
        case .food:
            return POICategoriesData.dining
        case .events:
            return POICategoriesData.events
        }
    }
}

class CustomPOICategoryViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    private var category: POICategory?
    weak var delegate: POICategoriesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.navItem.title = self.category?.rawValue
    }
    
    func configureWithCategory(_ category: POICategory) {
        self.category = category
    }
}

extension CustomPOICategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let cat = self.category else { return 0 }
        return cat.POIs().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cat = self.category else { return UITableViewCell() }
        
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: String(describing: POICell.self), for: indexPath) as! POICell
        let poi = cat.POIs()[indexPath.row]
        
        cell.configureWithPOI(poi)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension CustomPOICategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tappedCell = tableView.cellForRow(at: indexPath) as? POICell else { return }
        
        delegate?.poiTapped(tappedCell.poi)
    }
}

class POICell: UITableViewCell {
    @IBOutlet weak var poiName: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconImageBackgroundView: UIView!
    
    var poi: POIType!
    
    func configureWithPOI(_ poi: POIType) {
        self.poi = poi
        
        self.iconImageBackgroundView.backgroundColor = poi.iconBackgroundColor()
        self.iconImageBackgroundView.layer.cornerRadius = self.iconImageBackgroundView.frame.width / 2
        self.iconImageView.image = poi.iconImage()
        self.iconImageView.tintColor = .white
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.width / 2
        
        self.poiName.text = poi.rawValue
    }
}
