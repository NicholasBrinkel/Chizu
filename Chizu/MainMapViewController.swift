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
    let position: CGPoint
}

class MainMapViewController: UIViewController {
    var fpc: FloatingPanelController!
    @IBOutlet weak var mainMapImageView: UIImageView!
    var previousFpcPosition: FloatingPanelPosition?
    var pixels: [Pixel] = []
    
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
        
        fpc.set(contentViewController: contentView)
        
        fpc.addPanel(toParent: self)
        
        mainMapImageView.snp.makeConstraints { (make) in
        make.bottom.equalToSuperview().offset(0 - (UIScreen.main.bounds.height / 4) - 16)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async { //This takes a long time, so it's done in the background. Will animate the pins in once done processing pixel markers
            guard let image = self.mainMapImageView.image else {return}
            self.pixels = self.findColors(image)
            print()
        }
        fpc.addPanel(toParent: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fpc.removePanelFromParent(animated: animated)
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
                }
                if data[pixelInfo + 3] == 66 {
                    let pixel = Pixel(color: color, position: point)
                    imageColors.append(pixel)
                }
            }
        }
        return imageColors
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
