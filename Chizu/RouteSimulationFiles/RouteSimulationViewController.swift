//
//  RouteSimulationViewController.swift
//  Chizu
//
//  Created by Nick on 9/13/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import UIKit

class RouteSimulationViewController: UIViewController {
    @IBOutlet weak var currentInst: UILabel!
    @IBOutlet weak var floors: PerspectiveStackView!
    @IBOutlet weak var nextButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.layer.cornerRadius = 8
    }
    
    func simulatedRoute() {
    
    }
}
