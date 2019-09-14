//
//  Step.swift
//  Chizu
//
//  Created by Nick on 9/13/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import UIKit

struct Step {
    let isButtonVisible: Bool
    let isDirectionLabelVisible: Bool
    let directionInstruction: String
    let animation: AnimationType?
    let duration: Float?
    
    init(isButtonVisible: Bool, isDirectionLabelVisible: Bool, directionInstruction: String, animation: AnimationType?, duration: Float? = nil) {
        self.isButtonVisible = isButtonVisible
        self.isDirectionLabelVisible = isDirectionLabelVisible
        self.directionInstruction = directionInstruction
        self.animation = animation
        self.duration = duration
    }
}
