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
    fileprivate var scaleCalculated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fpc = FloatingPanelController()
        fpc.delegate = self
        
        let contentView = self.storyboard?.instantiateViewController(withIdentifier: "FloatingPanelContentViewController") as! FloatingPanelContentViewController
        contentView.parentVC = self
        contentView.searchBeginBlock = { [weak self] in
            self?.previousFpcPosition = self?.fpc.position
            self?.fpc.move(to: .full, animated: true)
        }
        
        contentView.searchCancelledBlock = { [weak self] in
            if let previousPosition = self?.previousFpcPosition {
                self?.fpc.move(to: previousPosition, animated: true)
                self?.previousFpcPosition = .none
            } else {
                self?.fpc.move(to: .tip, animated: true)
            }
        }
        
        fpc.view.layer.cornerRadius = 8
        
        fpc.set(contentViewController: contentView)
        fpc.addPanel(toParent: self)
        mainMapImageView.isUserInteractionEnabled = true
        scrollView.delegate = self
        //scrollView.canCancelContentTouches = false
        //scrollView.delaysContentTouches = false
        scrollView.snp.makeConstraints { (make) in
        make.bottom.equalToSuperview().offset(0 - (UIScreen.main.bounds.height / 4) - 16)
        }
        
        fpc.contentViewController?.definesPresentationContext = true
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
                make.width.height.equalTo(18 / self.scrollView.zoomScale)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let image = self.mainMapImageView.image else {return}
        
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
        
        if scaleCalculated == false {
            scrollView.contentSize = mainMapImageView.frame.size
            let scaleWidth = scrollView.frame.size.width / scrollView.contentSize.width
            let scaleHeight = scrollView.frame.size.height / scrollView.contentSize.height
            let minScale = min(scaleWidth, scaleHeight)
            
            scrollView.minimumZoomScale = minScale * 0.99
            scrollView.maximumZoomScale = 50.0
            
            scrollView.setZoomScale(minScale * 0.9, animated: true)
            scaleCalculated = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fpc.removePanelFromParent(animated: animated)
    }
    
    private func drawPOI(pixel: Pixel) {
        let poiView = POIPin()
        poiView.backgroundColor = pixel.poiType.iconBackgroundColor()
        poiView.iconImageView.image = pixel.poiType.iconImage()
        mainMapImageView.addSubview(poiView)
        poiView.pixelInfo = pixel
        
        poiView.tappedAction = { [weak self] in
            let width: CGFloat = 200
            let height: CGFloat = 200
            
            self?.scrollView.zoom(to: CGRect(x: poiView.pixelInfo!.position.x - width / 2 , y: poiView.pixelInfo!.position.y - height / 2, width: width, height: height), animated: true)
            
            let poiPrevVC = self?.storyboard?.instantiateViewController(withIdentifier: "POIPreviewViewController") as! POIPreviewViewController
            poiPrevVC.configure(poi: poiView.pixelInfo!.poiType)
            
            self?.fpc.set(contentViewController: poiPrevVC)
            self?.fpc.move(to: .tip, animated: true)
        }
        
        let widthScale =  mainMapImageView.bounds.width / 1000.0
        let heightScale = mainMapImageView.bounds.height / 1451.0
        
        UIView.animate(withDuration: 0.3) {
            poiView.snp.makeConstraints { (make) in
                make.width.height.equalTo(18 / self.scrollView.zoomScale)
                make.centerX.equalTo(pixel.position.x * widthScale)
                make.centerY.equalTo(pixel.position.y * heightScale)
            }
            poiView.layoutIfNeeded()
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
            case .tip: return UIScreen.main.bounds.height / 4 // A bottom inset from the safe area
            case .hidden: return nil
            }
        }
    }
}

extension MainMapViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            self.performSegue(withIdentifier: "showNavDemo", sender: self)
        }
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
