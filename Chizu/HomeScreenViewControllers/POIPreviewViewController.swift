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
    @IBOutlet weak var iconImaeViewBackground: UIView!
    
    var poi: POIType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startRouteButton.layer.cornerRadius = 8
        iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
        iconImaeViewBackground.layer.cornerRadius = iconImaeViewBackground.frame.width / 2
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        
        self.iconImageView.image = poi!.iconImage()
        self.nameLabel.text = poi!.rawValue
        self.iconImageView.backgroundColor = poi!.iconBackgroundColor()
        self.iconImaeViewBackground.backgroundColor = poi!.iconBackgroundColor()
    }
    
    func configure(poi: POIType) {
        self.poi = poi
    }
    
    @IBAction func startRoute(_ sender: Any) {
        let navDemoVC = storyboard?.instantiateViewController(withIdentifier: String(describing: RouteSimulationViewController.self)) as! RouteSimulationViewController
        
        navDemoVC.configureWithRoute(Routes.E2Route)
        self.present(navDemoVC, animated: true)
    }
}
