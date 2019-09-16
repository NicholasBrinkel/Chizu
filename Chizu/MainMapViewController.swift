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
        
        let contentView = self.storyboard?.instantiateViewController(withIdentifier: "FloatingPanelContentViewController") as! FloatingPanelContentViewController
        contentView.parentVC = self
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
        func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
            return MyFloatingPanelLayout()
    }
    
    class MyFloatingPanelLayout: FloatingPanelLayout {
        public var initialPosition: FloatingPanelPosition {
            return .tip
        }
        
        public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
            switch position {
            case .full: return 18.0
            case .half: return UIScreen.main.bounds.height / 2.0 // A bottom inset from the safe area
            case .tip: return UIScreen.main.bounds.height / 4.0 // A bottom inset from the safe area
            default: return nil // Or `case .hidden: return nil`
            }
        }
    }
}

extension MainMapViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if indexPath.row == 1 {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "showSplayDemo", sender: self)
        // }
    }
}
