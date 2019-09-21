//
//  POIPreviewViewController.swift
//  Chizu
//
//  Created by Apple User on 9/20/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import UIKit

class POIPreviewViewController: UIViewController {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startRouteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startRouteButton.layer.cornerRadius = 8
        iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
    }
    
    
    @IBAction func startRoute(_ sender: Any) {
        performSegue(withIdentifier: "", sender: self)
    }
}
