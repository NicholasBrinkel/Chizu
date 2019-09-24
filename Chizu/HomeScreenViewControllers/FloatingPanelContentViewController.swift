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
    @IBOutlet weak var foodAndDrink: UIImageView!
    @IBOutlet weak var events: UIImageView!
    
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
        
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(foodAndDrinkTapped))
        let tapGestureRecognizerEvents = UITapGestureRecognizer.init(target: self, action: #selector(eventsTapped))
        tapGestureRecognizer.delegate = self
        tapGestureRecognizerEvents.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: NSNotification.Name.favAdded, object: nil)
        
        foodAndDrink.addGestureRecognizer(tapGestureRecognizer)
        events.addGestureRecognizer(tapGestureRecognizerEvents)
    }
    
    @objc func reloadTableView() {
        self.tableView.reloadData()
    }
    
    @objc func foodAndDrinkTapped() {
        
        NotificationCenter.default.post(name: .foodAndDiningTapped, object: nil)
    }
    
    @objc func eventsTapped() {
        NotificationCenter.default.post(name: .eventsTapped, object: nil)
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
            cell.subTitleLabel.text = "\(POICategoriesData.favorites.count) Place\(POICategoriesData.favorites.count == 1 ? "" : "s")"
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

extension FloatingPanelContentViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

class SearchCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
}
