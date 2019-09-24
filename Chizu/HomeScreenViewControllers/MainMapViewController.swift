//
//  MainMapViewController.swift
//  Chizu
//
//  Created by Nick on 7/23/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import UIKit
import FloatingPanel
import SnapKit

struct Pixel {
    let color: UIColor
    let poiType: POIType
    let position: CGPoint
}

fileprivate class UserLocationPin: UIView {
    let iconImageView = UIImageView()
    var pixelInfo: Pixel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        addSubview(iconImageView)
        
        iconImageView.backgroundColor = UIColor.white
        iconImageView.layer.borderColor = UIColor.blue.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2.0
        layer.borderWidth = 10.0
    }
}

fileprivate class POIPin: UIView {
    let iconImageView = UIImageView()
    var pixelInfo: Pixel?
    var magicButton = UIButton()
    var tappedAction: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    @objc func tapped() {
        tappedAction?()
    }
    
    private func sharedInit() {
        addSubview(iconImageView)
        addSubview(magicButton)
        magicButton.backgroundColor = UIColor.clear
        
        magicButton.addTarget(self, action: #selector(self.tapped), for: .touchUpInside)
        
        iconImageView.tintColor = UIColor.white
        iconImageView.contentMode = .scaleAspectFit
        
        iconImageView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.height.width.equalToSuperview().multipliedBy(0.6)
        }
        
        magicButton.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2.0
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2.0
    }
}

class MainMapViewController: UIViewController, UIScrollViewDelegate {
    var fpc: FloatingPanelController!
    @IBOutlet weak var mainMapImageView: UIImageView!
    var previousFpcPosition: FloatingPanelPosition?
    var pixels: [Pixel] = []
    fileprivate var poiPins: [POIPin] = []
    @IBOutlet weak var scrollView: UIScrollView!
    private var firstLoad = true
    private var poiSearchVC: FloatingPanelContentViewController!
    private var userLocationPulseView: UIView!
    
    private var scaleWidth: CGFloat!
    private var scaleHeight: CGFloat!
    
    fileprivate var tempE2View: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fpc = FloatingPanelController()
        fpc.delegate = self
        
        self.poiSearchVC = self.storyboard?.instantiateViewController(withIdentifier: "FloatingPanelContentViewController") as! FloatingPanelContentViewController
        self.poiSearchVC.parentVC = self
        
        self.poiSearchVC.searchBeginBlock = { [weak self] in
            self?.previousFpcPosition = self?.fpc.position
            self?.fpc.move(to: .full, animated: true)
        }
        
        self.poiSearchVC.searchCancelledBlock = { [weak self] in
            if let previousPosition = self?.previousFpcPosition {
                self?.fpc.move(to: previousPosition, animated: true)
                self?.previousFpcPosition = .none
            } else {
                self?.fpc.move(to: .tip, animated: true)
            }
        }
        
        fpc.view.layer.cornerRadius = 8
        
        fpc.set(contentViewController: self.poiSearchVC)
        fpc.addPanel(toParent: self)
        mainMapImageView.isUserInteractionEnabled = true
        scrollView.delegate = self
        //scrollView.canCancelContentTouches = false
        //scrollView.delaysContentTouches = false
        scrollView.snp.makeConstraints { (make) in
        make.bottom.equalToSuperview().offset(0 - (UIScreen.main.bounds.height / 4) - 16)
        }
        
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resetFPC)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentDiningPOIs), name: .foodAndDiningTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentEventsPOIs), name: .eventsTapped, object: nil)
    }
    
    @objc func presentDiningPOIs() {
        presentPOICategoryVCFor(category: .food)
    }
    
    @objc func presentEventsPOIs() {
        presentPOICategoryVCFor(category: .events)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mainMapImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
        
        for poiView in self.poiPins {
            poiView.snp.updateConstraints { (make) in
                let scaledSize = 18 / (self.scrollView.zoomScale / 1.5)
                
                if scaledSize > 14 {
                    make.width.height.equalTo(18 / (self.scrollView.zoomScale / 1.5))
                } else {
                    make.width.height.equalTo(14)
                }
                
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let image = self.mainMapImageView.image else {return}
        
        if let _ = tempE2View {
            tempE2View?.removeFromSuperview()
            tempE2View = .none
            resetFPC()
        }
        
        if self.pixels.count < 1 {
            DispatchQueue.global(qos: .background).async { //This takes a long time, so it's done in the background. Will animate the pins in once done processing pixel markers
                self.pixels = self.findColors(image)
                for oldPin in self.poiPins {
                    oldPin.removeFromSuperview()
                }
                self.poiPins = []
                for secretPixel in self.pixels {
                    DispatchQueue.main.async {
                        self.drawPOI(pixel: secretPixel)
                    }
                }
            }
        }
        
        fpc.addPanel(toParent: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        sizeScrollViewToFit()
    }
    
    @objc func sizeScrollViewToFit() {
        if firstLoad {
            self.scaleWidth = scrollView.frame.size.width / scrollView.contentSize.width
            self.scaleHeight = scrollView.frame.size.height / scrollView.contentSize.height
        }
        
        self.firstLoad = false
        
        scrollView.contentSize = mainMapImageView.frame.size
        let minScale = min(scaleWidth, scaleHeight)
        
        scrollView.minimumZoomScale = minScale * 0.99
        scrollView.maximumZoomScale = 50.0
        
        scrollView.setZoomScale(minScale * 0.9, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fpc.removePanelFromParent(animated: animated)
    }
    
    private func drawPOI(pixel: Pixel) {
        if pixel.poiType != .user {
            let poiView = POIPin()
            poiView.backgroundColor = pixel.poiType.iconBackgroundColor()
            poiView.iconImageView.image = pixel.poiType.iconImage()
            mainMapImageView.addSubview(poiView)
            poiPins.append(poiView)
            poiView.pixelInfo = pixel
            
            poiView.tappedAction = { [weak self] in
                self?.zoomOnPOI(pixel.poiType)
            }
            
            let widthScale =  mainMapImageView.bounds.width / 1000.0
            let heightScale = mainMapImageView.bounds.height / 1451.0
            
            UIView.animate(withDuration: 0.3) {
                poiView.snp.makeConstraints { (make) in
                    
                    let scaledSize = 18 / (self.scrollView.zoomScale / 1.5)
                    
                    if scaledSize > 14 {
                        make.width.height.equalTo(18 / (self.scrollView.zoomScale / 1.5))
                    } else {
                        make.width.height.equalTo(14)
                    }
                    make.centerX.equalTo(pixel.position.x * widthScale)
                    make.centerY.equalTo(pixel.position.y * heightScale)
                }
                poiView.layoutIfNeeded()
            }
        } else {
            let poiView = UserLocationPin()
            
            poiView.backgroundColor = UIColor.white
            poiView.layer.borderColor = UIColor.blue.cgColor
            
            mainMapImageView.addSubview(poiView)
            
            poiView.pixelInfo = pixel
            
            let widthScale =  mainMapImageView.bounds.width / 1000.0
            let heightScale = mainMapImageView.bounds.height / 1451.0
            self.userLocationPulseView = UIView()
            mainMapImageView.addSubview(userLocationPulseView)
            self.userLocationPulseView.backgroundColor = UIColor.blue.withAlphaComponent(0.9)
            self.userLocationPulseView.layer.cornerRadius = (24 / self.scrollView.zoomScale) / 2
            self.userLocationPulseView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
            UIView.animate(withDuration: 0.3) {
                poiView.snp.makeConstraints { (make) in
                    make.width.height.equalTo(12 / self.scrollView.zoomScale)
                    make.centerX.equalTo(pixel.position.x * widthScale)
                    make.centerY.equalTo(pixel.position.y * heightScale)
                }
                self.userLocationPulseView.snp.makeConstraints({ (make) in
                    make.width.height.equalTo(24 / self.scrollView.zoomScale)
                    make.centerX.equalTo(pixel.position.x * widthScale)
                    make.centerY.equalTo(pixel.position.y * heightScale)
                })
                
                poiView.layoutIfNeeded()
            }
            
            UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: UIView.AnimationOptions.repeat, animations: {
                self.userLocationPulseView.transform = .identity
                self.userLocationPulseView.alpha = 0.1
            }, completion: .none)
        }
    }
    
    private func zoomOnPOI(_ poi: POIType, isE2Huddle: Bool = false) {
        let width: CGFloat = 200
        let height: CGFloat = 200
        
        guard let poiPixel = self.pixels.first(where: { $0.poiType == poi} ) else {
            return
        }
        
        if isE2Huddle {
            self.scrollView.zoom(to: CGRect(x: poiPixel.position.x - width / 2 , y: poiPixel.position.y - height / 2, width: width * 2, height: height * 2), animated: true)
        } else {
            self.scrollView.zoom(to: CGRect(x: poiPixel.position.x - width / 2 , y: poiPixel.position.y - height / 2, width: width, height: height), animated: true)
        }
        
        let poiPreviewVC = self.storyboard?.instantiateViewController(withIdentifier: "POIPreviewViewController") as! POIPreviewViewController
        
        if isE2Huddle {
            poiPreviewVC.configure(poi: .e2Huddle)
        } else {
            poiPreviewVC.configure(poi: poi)
        }
        
        self.fpc.set(contentViewController: poiPreviewVC)
        self.fpc.move(to: .half, animated: true)
        let poiView = self.poiPins.first { (pin) -> Bool in
            return pin.pixelInfo?.poiType == poiPixel.poiType
        }
        
        poiView?.snp.updateConstraints { (make) in
            make.width.height.equalTo(36)
        }
        
    }
    
    private func findColors(_ image: UIImage) -> [Pixel] {
        let pixelsWide = Int(image.size.width)
        let pixelsHigh = Int(image.size.height)
        
        guard let pixelData = image.cgImage?.dataProvider?.data else { return [] }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        var imageColors: [Pixel] = []
        for x in 0..<pixelsWide {
            for y in 0..<pixelsHigh {
                let point = CGPoint(x: x, y: y)
                let pixelInfo: Int = ((pixelsWide * Int(point.y)) + Int(point.x)) * 4
                let color = UIColor(red: CGFloat(data[pixelInfo]) / 255.0,
                                    green: CGFloat(data[pixelInfo + 1]) / 255.0,
                                    blue: CGFloat(data[pixelInfo + 2]) / 255.0,
                                    alpha: CGFloat(data[pixelInfo + 3]) / 255.0)
                
                if data[pixelInfo + 3] != 255 {
                    print("Debug Color Alpha = \(data[pixelInfo + 3])")
                    print("Debug Color Red = \(CGFloat(data[pixelInfo]))")
                    print("Debug Color green = \(CGFloat(data[pixelInfo + 1]))")
                    print("Debug Color blue = \(CGFloat(data[pixelInfo + 2]))")
                    
                    if let poiType = POIType.POIForPixelMarker(r: CGFloat(data[pixelInfo]), b: CGFloat(data[pixelInfo + 2]), g: CGFloat(data[pixelInfo + 1]), a: CGFloat(data[pixelInfo + 3])) {
                        let pixel = Pixel(color: color, poiType: poiType, position: point)
                        imageColors.append(pixel)
                        print("POI Captured: \(poiType.rawValue)")
                    }
                }
            }
        }
        return imageColors
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNavDemo" {
            let vc = segue.destination as! RouteSimulationViewController
            vc.configureWithRoute(Routes.E2Route)
        }
    }
    
    @objc func resetFPC() {
        self.fpc.set(contentViewController: self.poiSearchVC)
        self.sizeScrollViewToFit()
        self.fpc.move(to: .tip, animated: true)
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
            case .tip: return 180 // A bottom inset from the safe area
            case .hidden: return nil
            }
        }
    }
}

extension MainMapViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            
            presentPOICategoryVCFor(category: .favorites)
        } else if indexPath.row == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let selectedPOI = poiSearchVC.filteredPOIResults[indexPath.row - 1]
            
            if selectedPOI != .e2Huddle {
                
                let poiView = self.poiPins.first { (pin) -> Bool in
                    return pin.pixelInfo?.poiType == selectedPOI
                }
                
                poiView?.tapped()
            } else {
                
                if let poiPixel = self.pixels.first(where: { $0.poiType == .user} ) {
                    self.zoomOnPOI(.user, isE2Huddle: true)
                    
                    tempE2View = UIView()
                    tempE2View?.backgroundColor = UIColor.red.withAlphaComponent(0.5)
                    
                    mainMapImageView.addSubview(tempE2View!)
                    
                    tempE2View?.snp.makeConstraints({ (make) in
                        make.width.equalTo(300)
                        make.height.equalTo(120)
                        make.centerX.equalTo(poiPixel.position.x + 80)
                        make.centerY.equalTo(poiPixel.position.y + 20)
                    })
                }
            }
        }
    }
    
    func presentPOICategoryVCFor(category: POICategory) {
        let poiNavVC = customPOICategoryVCFor(category: category)
        
        self.fpc.set(contentViewController: poiNavVC)
        self.fpc.move(to: .full, animated: true)
    }
    
    func customPOICategoryVCFor(category: POICategory) -> UINavigationController {
        let favoritesNavVC = storyboard?.instantiateViewController(withIdentifier: "FavoritesNavViewController") as! UINavigationController
        
        let favoritesVC = favoritesNavVC.viewControllers.first as? CustomPOICategoryViewController
        favoritesVC?.delegate = self
        favoritesVC?.configureWithCategory(category)
        
        return favoritesNavVC
    }
}

extension MainMapViewController: POICategoriesDelegate {
    func poiTapped(_ poi: POIType) {
        self.zoomOnPOI(poi)
    }
}

extension UIColor {
    
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red: red, green: green, blue: blue, alpha: alpha)
    }
    
    var redComponent: CGFloat {
        var red: CGFloat = 0.0
        getRed(&red, green: nil, blue: nil, alpha: nil)
        
        return red
    }
    
    var greenComponent: CGFloat {
        var green: CGFloat = 0.0
        getRed(&green, green: nil, blue: nil, alpha: nil)
        
        return green
    }
    
    var blueComponent: CGFloat {
        var blue: CGFloat = 0.0
        getRed(nil, green: nil, blue: &blue, alpha: nil)
        
        return blue
    }
    
    var alphaComponent: CGFloat {
        var alpha: CGFloat = 0.0
        getRed(nil, green: nil, blue: nil, alpha: &alpha)
        
        return alpha
    }
}
