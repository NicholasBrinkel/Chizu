//
//  ViewController.swift
//  Chizu
//
//  Created by Nick on 6/28/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var imageLayers: [CALayer]!
    var num: Int = 0

    var toTransform: CATransform3D!
    var undoTransform = CATransform3DIdentity
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make the array of layers
        imageLayers = createLayerStack()
        
        // Add each layer to the view
        for layer in imageLayers {
            self.view.layer.addSublayer(layer)
        }
        
        // Set the transform that each layer will transform to
        setToTransform()
    }
    
    
    // This is where the meat and potatoes are
    func setToTransform() {
        var transform = CATransform3DIdentity
        transform.m34 = -1 / 1000
        transform = CATransform3DRotate(transform, degToRad(60), 1, 0, 0)
        
        let rotation = CATransform3DRotate(transform, degToRad(80), 0, 0, 1)
        
        toTransform = rotation
    }
    
    // Converts degrees to radians because CoreAnimation uses radians
    func degToRad(_ degrees: CGFloat) -> CGFloat {
        return degrees * CGFloat((Float.pi)) / 180
    }
    
    func createLayerStack() -> [CALayer] {
        var layers = [CALayer]()
        for i in 0...4 {
            layers.append(imageLayer(yPosition: CGFloat(50 + 100*i), zPos: CGFloat(i*10)))
        }
        
        return layers
    }
    
    func imageLayer(yPosition: CGFloat, zPos: CGFloat) -> CALayer {
        let layer = CALayer()
        let image = UIImageView(image: UIImage(named: "thing"))
        image.contentMode = .scaleAspectFit
        layer.contents = UIImage(named: "thing")?.cgImage
        layer.frame = image.frame
        layer.frame = CGRect(x: (view.frame.width - layer.frame.width) / 2, y: yPosition, width: layer.frame.width, height: layer.frame.height)
        layer.zPosition = zPos
        layer.opacity = 0.5
        
        return layer
    }
    
    @IBAction func pressed(_ sender: Any) {
        let animation = CABasicAnimation(keyPath: "transform")

        animation.toValue = (num % 2 == 0) ? toTransform : undoTransform
        animation.duration = 1
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        for layer in self.imageLayers {
            layer.add(animation, forKey: "transform")
        }
    }
}

extension ViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        for layer in imageLayers {
            layer.removeAnimation(forKey: "transform")
            layer.transform = (num % 2 == 0) ? toTransform : undoTransform
        }
        
        CATransaction.commit()
        CATransaction.setDisableActions(false)
        num += 1
    }
}
