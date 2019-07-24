//
//  MainMapViewController.swift
//  Chizu
//
//  Created by Nick on 7/23/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import UIKit
import FloatingPanel

class MainMapViewController: UIViewController {
    var fpc: FloatingPanelController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fpc = FloatingPanelController()
        fpc.delegate = self
        
        let contentView = self.storyboard?.instantiateViewController(withIdentifier: "FloatingPanelContentViewController")
        fpc.set(contentViewController: contentView)
        
        fpc.addPanel(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fpc.addPanel(toParent: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fpc.removePanelFromParent(animated: animated)
    }
}

extension MainMapViewController: FloatingPanelControllerDelegate {
    
}
