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
    
    var currentState: AnimationState = AnimationState(position: .unAnimated, transform: .unAnimated)
    var previousState: AnimationState = AnimationState(position: .unAnimated, transform: .unAnimated)
    
    
    /*----------------*/
    
    
    func transformValueForState() -> CATransform3D {
        switch currentState.transform {
        case .animated:
            return toTransformValue
        case .unAnimated:
            return fromTransformValue
        }
    }
    
    func positionValueForState() -> CGPoint {
        switch currentState.position {
        case .animated:
            return toPositionValue
        case .unAnimated:
            return fromPositionValue
        }
    }
}

struct AnimationState {
    var position: AnimationDirection
    var transform: AnimationDirection
}
