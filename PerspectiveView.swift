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
    
    var currentPositionState: AnimationDirection = .unAnimated
    var currentTransformState: AnimationDirection = .unAnimated
    
    var prevPositionState: AnimationDirection = .unAnimated
    var prevTransformState: AnimationDirection = .unAnimated
    
    
    /*----------------*/
    
    
    func transformValueForState() -> CATransform3D {
        switch currentTransformState {
        case .animated:
            return toTransformValue
        case .unAnimated:
            return fromTransformValue
        }
    }
    
    func positionValueForState() -> CGPoint {
        switch currentPositionState {
        case .animated:
            return toPositionValue
        case .unAnimated:
            return fromPositionValue
        }
    }
    
    /*----------------*/
    
    
    func transformValueForPrevState() -> CATransform3D {
        switch prevTransformState {
        case .animated:
            return toTransformValue
        case .unAnimated:
            return fromTransformValue
        }
    }
    
    func positionValueForPrevState() -> CGPoint {
        switch prevPositionState {
        case .animated:
            return toPositionValue
        case .unAnimated:
            return fromPositionValue
        }
    }
}
