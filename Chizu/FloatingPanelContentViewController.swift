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
    
    var parentVC: UITableViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = parentVC
    }
}

extension FloatingPanelContentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // if indexPath.row == 1 {
            self.performSegue(withIdentifier: "showSplayDemo", sender: self)
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
            cell.subTitleLabel.text = "0 Places"
            return cell
        case 1:
            let cell = UITableViewCell()
            cell.textLabel?.text = "E2-5A-22-Huddle"
            return cell
        default:
            return UITableViewCell()
        }
    }
}

class SearchCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
}
