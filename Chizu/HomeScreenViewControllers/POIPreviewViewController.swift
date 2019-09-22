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
    @IBOutlet weak var hooLabel: UILabel!
    @IBOutlet weak var ctaButton: UIButton!
    @IBOutlet weak var extraCtaButton: UIButton!
    @IBOutlet weak var iconImageViewBackground: UIView!
    @IBOutlet weak var favButton: UIButton!
    
    var poi: POIType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let poi = self.poi else {
            return
        }
        
        startRouteButton.layer.cornerRadius = 8
        iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
        iconImageViewBackground.layer.cornerRadius = iconImageViewBackground.frame.width / 2
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        favButton.layer.cornerRadius = favButton.frame.width / 2
        
        hooLabel.text = "Hours: \(self.poi?.hoursOfOperationString() ?? "N/A")"
        
        if let ctaTitle = self.poi?.ctaTitle() {
            ctaButton.setTitle(ctaTitle, for: .normal)
        } else {
            ctaButton.isHidden = true
        }
        
        if self.poi == .mainDining || self.poi == .w4Dining {
            extraCtaButton.isHidden = false
            extraCtaButton.setTitle("Order Online", for: .normal)
        } else {
            extraCtaButton.isHidden = true
        }
        
        self.iconImageView.image = poi.iconImage()
        self.nameLabel.text = poi.rawValue
        self.iconImageView.backgroundColor = poi.iconBackgroundColor()
        self.iconImageView.image = poi.iconImage()
        self.nameLabel.text = poi.rawValue
        self.iconImageView.backgroundColor = poi.iconBackgroundColor()
        self.iconImageViewBackground.backgroundColor = poi.iconBackgroundColor()
    }
    
    func configure(poi: POIType) {
        self.poi = poi
    }
    
    @IBAction func extraCtaButtonTapped(_ sender: Any) {
        if let detailModal = self.poi?.webWrapperView(url: "https://toyotaplanoretail.misofi.net/") {
            present(detailModal, animated: true, completion: .none)
        }
    }
    
    @IBAction func ctaButtonTapped(_ sender: Any) {
        if let detailModal = self.poi?.accessoryViewController() {
            present(detailModal, animated: true, completion: .none)
        }
    }
    
    @IBAction func startRoute(_ sender: Any) {
        let navDemoVC = storyboard?.instantiateViewController(withIdentifier: String(describing: RouteSimulationViewController.self)) as! RouteSimulationViewController
        
        navDemoVC.configureWithRoute(Routes.E2Route)
        self.present(navDemoVC, animated: true)
    }
    
    @IBAction func favButtonPressed(_ sender: Any) {
        if let poi = self.poi {
            if !FavoritesData.favorites.contains(poi) {
                FavoritesData.favorites.append(poi)
                NotificationCenter.default.post(name: NSNotification.Name.favAdded, object: nil)
            }
        }
    }
}

extension NSNotification.Name {
    static let favAdded = NSNotification.Name("FavoriteAdded")
}
