//
//  FloatingPanelContentViewController.swift
//  Chizu
//
//  Created by Nick on 7/19/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import FloatingPanel
import UIKit

class FloatingPanelContentViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var parentVC: UITableViewDelegate?
    var searchBeginBlock: (() -> ())?
    var searchCancelledBlock: (() -> ())?
    var presentingPOI: POIType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = parentVC
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: NSNotification.Name.favAdded, object: nil)
    }
    
    @objc func reloadTableView() {
        self.tableView.reloadData()
    }
}

extension FloatingPanelContentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // if indexPath.row == 1 {
            self.performSegue(withIdentifier: "showNavDemo", sender: self)
       // }
    }
}

extension FloatingPanelContentViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SearchCell
            print(cell)
            print(cell)
            print(tableView)
            cell.iconImageView.image = UIImage(named: "like")
            cell.titleLabel.text = "Favorites"
            cell.subTitleLabel.text = "\(FavoritesData.favorites.count) Place\(FavoritesData.favorites.count == 1 ? "" : "s")"
            return cell
        case 1:
            let cell = UITableViewCell()
            cell.textLabel?.text = "E2-5A-22-Huddle"
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func setPresentingPOI(_ poi: POIType) {
        self.presentingPOI = poi
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPOIDetail" {
            let destination = segue.destination as! POIPreviewViewController
            if let poi = presentingPOI {
                destination.configure(poi: poi)
            }
        }
    }
}

extension FloatingPanelContentViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBeginBlock?()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchCancelledBlock?()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchCancelledBlock?()
    }
}

class SearchCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
}
