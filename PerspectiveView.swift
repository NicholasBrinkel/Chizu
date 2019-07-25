//
//  PerspectiveView.swift
//  Chizu
//
//  Created by Nick on 7/24/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import UIKit

class PerspectiveView: UIView {
    var toTransformValue: CATransform3D!
    var fromTransformValue: CATransform3D!
    
    var toPositionValue: CGPoint!
    var fromPositionValue: CGPoint!
    
    func positionValue(_ direction: AnimationDirection) -> CGPoint {
        switch direction {
        case .do:
            return toPositionValue
        case .undo:
            return fromPositionValue
        }
    }
    
    func transformValue(_ direction: AnimationDirection) -> CATransform3D {
        switch direction {
        case .do:
            return toTransformValue
        case .undo:
            return fromTransformValue
        }
    }
}
