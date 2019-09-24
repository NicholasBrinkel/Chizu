//
//  BlinkingLocationAdder.swift
//  Chizu
//
//  Created by Apple User on 9/24/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import UIKit
import SnapKit

class BlinkingLocationAdder {
    var blinkingLocationView: UIView!
    var innerView: UIView!
    var duration: CGFloat = 5.0
    var origin: CGPoint = CGPoint(x: 0, y: 0)
    var color: UIColor = .red
    
    func configureWith(centerPosition: CGPoint, color: UIColor) {
        self.blinkingLocationView = UIView()
        
        blinkingLocationView.backgroundColor = UIColor.white
        blinkingLocationView.layer.borderWidth = 2.5
        blinkingLocationView.layer.borderColor = color.cgColor
        
        innerView = UIView()
        
        self.origin = centerPosition
        self.color = color
    }
    
    private func trekAnimation(withPath path: UIBezierPath, numberOfSegments: Int) -> CAKeyframeAnimation {
        let trekAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
        trekAnimation.path = path.cgPath
        trekAnimation.keyPath = "position"
        trekAnimation.repeatCount = Float(CGFloat.infinity)
        trekAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        trekAnimation.duration = CFTimeInterval(duration)
        
        let divident = numberOfSegments - 1
        
        for i in 0 ..< numberOfSegments {
            trekAnimation.values?.append(i)
            trekAnimation.keyTimes?.append(NSNumber(value: i / divident))
        }
        
        return trekAnimation
    }
    
    func addTrekAnimationTo(_ view: UIView, withPath path: UIBezierPath, numberOfSegments: Int) -> UIView {
        view.addSubview(self.blinkingLocationView)
        
        blinkingLocationView.addSubview(innerView)
        
        innerView.backgroundColor = color.withAlphaComponent(0.9)
        innerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        blinkingLocationView.backgroundColor = UIColor.white
        blinkingLocationView.layer.borderColor = color.cgColor
        
        UIView.animate(withDuration: 0.3) {
            self.blinkingLocationView.snp.makeConstraints { (make) in
                make.width.height.equalTo(10)
                make.centerX.equalTo(self.origin.x)
                make.centerY.equalTo(self.origin.y)
            }
            self.innerView.snp.makeConstraints({ (make) in
                make.left.right.top.bottom.equalToSuperview()
                make.center.equalToSuperview()
            })
            
            self.blinkingLocationView.layoutIfNeeded()
            self.innerView.layoutIfNeeded()
            
            self.blinkingLocationView.layer.cornerRadius = self.blinkingLocationView.frame.width / 2
            self.innerView.layer.cornerRadius = 5
        }
        
        UIView.animate(withDuration: 0.66, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: UIView.AnimationOptions.repeat, animations: {
            self.innerView.transform = CGAffineTransform(scaleX: 2, y: 2)
            self.innerView.alpha = 0.1
        }, completion: .none)
        
        let trekAnimation = self.trekAnimation(withPath: path, numberOfSegments: numberOfSegments)
        
        self.blinkingLocationView.layer.add(trekAnimation, forKey: nil)
        
        return self.blinkingLocationView
    }
}
