//
//  PathCreator.swift
//  Chizu
//
//  Created by Nick on 9/9/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import UIKit

class PathCreator: NSObject {
    
    let defaultPathStyle = PathStyleProvider(strokeEnd: 0, lineWidth: 4, strokeColor: UIColor.blue.cgColor, fillColor: nil, opacity: 1)
    
    override init() {
        super.init()
    }
    
    func createPath(fromPoints points: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: points.first!)
        
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        
        return path
    }
    
    func makePathLayer(withPath path: UIBezierPath, withAnimationTimingFunctionName name: CAMediaTimingFunctionName, styleProvider: PathStyleProvider? = nil ) -> CAShapeLayer {
        let pathLayer = CAShapeLayer()
        
        if let styleProvider = styleProvider {
            pathLayer.addStyle(withProvider: styleProvider)
            path.lineWidth = styleProvider.lineWidth
        } else {
            pathLayer.addStyle(withProvider: defaultPathStyle)
            path.lineWidth = defaultPathStyle.lineWidth
        }
        
        path.stroke()
        pathLayer.path = path.cgPath
        
        return pathLayer
    }
}

struct PathStyleProvider {
    let strokeEnd: CGFloat
    let lineWidth: CGFloat
    let strokeColor: CGColor
    let fillColor: CGColor?
    let opacity: Float
}

extension CAShapeLayer {
    func addStyle(withProvider provider: PathStyleProvider) {
        self.strokeEnd = provider.strokeEnd
        self.lineWidth = provider.lineWidth
        self.strokeColor = provider.strokeColor
        self.fillColor = provider.strokeColor
        self.opacity = provider.opacity
    }
}
