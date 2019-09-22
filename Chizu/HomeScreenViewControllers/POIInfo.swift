//
//  POIInfo.swift
//  Chizu
//
//  Created by Brandon Salahat on 9/21/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import UIKit
import ImageScrollView

enum POIType: String, CaseIterable {
    case mainDining = "Cafeteria"
    case w4Dining = "W4 Cafeteria"
    case e1Market = "E1 Mitsuwa Market"
    case w1Market = "W1 Mitsuwa Market"
    case gym = "Fitness Center"
    case exCenter = "Musuem"
    case unify = "Unify FCU"
    case clinic = "Concentra Clinic"
    case pharmacy = "Walmart Pharmacy"
    case eastCoffee = "Starbucks #1"
    case westCoffee = "Starbucks #2"
    case event = "OctoberBeast"
    case user = "User"
    
    func ctaTitle() -> String? {
        switch self {
        case .mainDining, .w4Dining, .westCoffee, .eastCoffee: return "View Menu"
            
        case .e1Market:
            return .none
        case .w1Market:
            return .none
        case .gym:
            return .none
        case .exCenter:
            return .none
        case .unify:
            return "View Website"
        case .clinic:
            return .none
        case .pharmacy:
            return .none
        case .event:
            return "Event Details"
        case .user: return .none
        }
    }
    
    func hoursOfOperationString() -> String {
        switch self {
        case .mainDining:
            return "11 AM - 2 PM"
        case .w4Dining:
            return "11 AM - 2 PM"
        case .e1Market:
            return "Always Open"
        case .w1Market:
            return "Always Open"
        case .gym:
            return "6 AM - 10 PM"
        case .exCenter:
            return "9 AM - 3 PM"
        case .unify:
            return "8 AM - 5 PM"
        case .clinic:
            return "8 AM - 5 PM"
        case .pharmacy:
            return "8 AM - 6 PM"
        case .eastCoffee:
            return "8 AM - 3 PM"
        case .westCoffee:
            return "8 AM - 3 PM"
        case .event:
            return "October 3rd, 11 AM - 1 PM"
        case .user:
            return ""
       
        }
    }
    
    private func menuWrapperView(menuImage: UIImage) -> UIViewController {
        let viewController = UIViewController()
        let imageView = ImageScrollView()
        let closeButton = UIButton()
        let closeAction: (UIControl) -> () = { control in
            viewController.dismiss(animated: true, completion: .none)
        }
        viewController.view.backgroundColor = UIColor.black
        viewController.view.addSubview(imageView)
        viewController.view.addSubview(closeButton)
        
        imageView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        imageView.contentMode = .scaleAspectFit
        
        closeButton.setImage(UIImage(named: "CloseIcon"), for: .normal)
        closeButton.tintColor = UIColor.white
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.addAction(for: .touchUpInside, closure: closeAction)
        
        closeButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(44)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(32)
        }
        
        viewController.loadViewIfNeeded()
        imageView.setup()
        imageView.display(image: menuImage)
        
        return viewController
    }
    
    func webWrapperView(url: String) -> UIViewController {
        let viewController = UIViewController()
        let webView = UIWebView()
        let closeButton = UIButton()
        let closeAction: (UIControl) -> () = { control in
            viewController.dismiss(animated: true, completion: .none)
        }
        viewController.view.backgroundColor = UIColor.black
        viewController.view.addSubview(webView)
        viewController.view.addSubview(closeButton)
        
        webView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        let url = URL(string: url)!
        let request = URLRequest(url: url)
        webView.loadRequest(request)
        
        closeButton.setImage(UIImage(named: "CloseIcon"), for: .normal)
        closeButton.tintColor = UIColor.white
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.addAction(for: .touchUpInside, closure: closeAction)
        
        closeButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(44)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(32)
        }
        
        viewController.loadViewIfNeeded()
        
        return viewController
    }
    
    
    func accessoryViewController() -> UIViewController? {
        switch self {
        case .mainDining:
            return self.menuWrapperView(menuImage: UIImage(named: "MainCafeMenu")!)
        case .w4Dining:
            return self.menuWrapperView(menuImage: UIImage(named: "W4Menu")!)
        case .e1Market:
            return .none
        case .w1Market:
            return .none
        case .gym:
            return .none
        case .exCenter:
            return .none
        case .unify:
            return self.webWrapperView(url: "https://www.unifyfcu.com/")
        case .clinic:
            return .none
        case .pharmacy:
            return .none
        case .eastCoffee:
            return self.menuWrapperView(menuImage: UIImage(named: "EastCoffeeMenu")!)
        case .westCoffee:
            return self.menuWrapperView(menuImage: UIImage(named: "WestCoffeeMenu")!)
        case .event:
            return self.menuWrapperView(menuImage: UIImage(named: "EventDetails")!)
        case .user: return .none
        }
    }
    
    func iconBackgroundColor() -> UIColor {
        switch self {
        case .mainDining, .w4Dining: return UIColor.orange
        case .e1Market, .w1Market: return UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1)
        case .gym, .exCenter: return UIColor.purple
        case .unify: return UIColor.purple
        case .clinic: return UIColor.cyan
        case .pharmacy: return UIColor.blue
        case .eastCoffee, .westCoffee: return UIColor.black
        case .event: return UIColor(red: 0.5, green: 0.8, blue: 0.8, alpha: 1)
        case .user: return UIColor.blue
        }
    }
    
    func iconImage() -> UIImage? {
        switch self {
        case .mainDining, .w4Dining: return UIImage(named: "food")
        case .e1Market, .w1Market: return UIImage(named: "Market")
        case .gym, .exCenter: return UIImage(named: "social")
        case .unify: return UIImage(named: "Unify")
        case .clinic: return UIImage(named: "medical")
        case .pharmacy: return UIImage(named: "walmart")
        case .eastCoffee, .westCoffee: return UIImage(named: "Coffee")
        case .event: return UIImage(named: "event")
        case .user: return .none
        }
    }
    
    static func POIForPixelMarker(r: CGFloat, b: CGFloat, g: CGFloat, a: CGFloat) -> POIType? {
        switch (r, b, g, a) {
        case (0.0, 18.0, 111.0, 111.0): return .mainDining
        case (0.0, 168.0, 168.0, 168.0): return .w4Dining
        case (0.0, 168.0, 78.0, 168.0): return .e1Market
        case (0.0, 38.0, 77.0, 168.0): return .w1Market
        case (16.0, 64.0, 102.0, 168.0): return .gym
        case (32.0, 116.0, 84.0, 168.0): return .exCenter
        case (32.0, 116.0, 168.0, 168.0): return .unify
        case (54.0, 104.0, 149.0, 168.0): return .clinic
        case (54.0, 128.0, 43.0, 168.0): return .pharmacy
        case (54.0, 128.0, 167.0, 168.0): return .eastCoffee
        case (54.0, 128.0, 1.0, 168.0): return .westCoffee
        case (168.0, 48.0, 0.0, 168.0): return .event
        case (168.0, 168.0, 94.0, 168.0): return .user
        default: return .none
        }
    }
}


extension UIControl {
    
    /// Typealias for UIControl closure.
    public typealias UIControlTargetClosure = (UIControl) -> ()
    
    private class UIControlClosureWrapper: NSObject {
        let closure: UIControlTargetClosure
        init(_ closure: @escaping UIControlTargetClosure) {
            self.closure = closure
        }
    }
    
    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }
    
    private var targetClosure: UIControlTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? UIControlClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, UIControlClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure(self)
    }
    
    public func addAction(for event: UIControl.Event, closure: @escaping UIControlTargetClosure) {
        targetClosure = closure
        addTarget(self, action: #selector(UIControl.closureAction), for: event)
    }
    
}
