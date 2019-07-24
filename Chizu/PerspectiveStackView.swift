//
//  PerspectiveStackView.swift
//  Chizu
//
//  Created by Nick on 7/23/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import UIKit

class PerspectiveStackView: UIView {
    private var stackedViews: [UIView]
    var spacing: CGFloat
    var duration: Double = 1
    var timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    var additionalPerspectiveSplayTransforms = [CATransform3D]()
    var xOffsetAfterPerspectiveAnimation: CGFloat = 0.0
    
    var perspectiveTransform: CATransform3D = {
        func degToRad(_ degrees: CGFloat) -> CGFloat {
            return degrees * CGFloat((Float.pi)) / 180
        }
        
        let transform = CATransform3DRotate(CATransform3DIdentity, degToRad(65), 1, 0, 0)
        return CATransform3DRotate(transform, degToRad(50), 0, 0, 1)
    }()
    
    private var originalPerspectiveValues = [CATransform3D]()
    private var shiftedPerspectiveValues = [CATransform3D]()
    private var originalPositionValues = [CGPoint]()
    private var splayedPositionValues = [CGPoint]()
    
    private enum Property {
        case transform
        case position
    }
    
    private enum AnimationDirection {
        case `do`
        case undo
    }
    
    init(frame: CGRect, withStackedViews views: [UIView], andSpacing spacing: CGFloat) {
        
        self.stackedViews = views
        self.spacing = spacing
        self.originalPerspectiveValues = views.map({ $0.layer.transform })
        self.shiftedPerspectiveValues = views.map({ $0.layer.transform })
        
        self.originalPositionValues = views.map({ $0.layer.position })
        
        super.init(frame: frame)
        
        for stackedView in self.stackedViews {
            self.addSubview(stackedView)
        }
        
        centerStartingPositions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func degToRad(_ degrees: CGFloat) -> CGFloat {
        return degrees * CGFloat((Float.pi)) / 180
    }
    
    

    // MARK: Perspective Shift Animations
    /*-----------------------------------------------------------*/
    
    
    
    func perspectiveShiftAllViews() {
        let combinedTransforms = combineAllTransforms()
        shiftedPerspectiveValues = shiftedPerspectiveValues.map({ _ in combinedTransforms })
        
        CATransaction.begin()
        self.stackedViews.map({ self.addPerspectiveAnimation(to: $0.layer, for: .do)})
        CATransaction.commit()
    }
    
    func perspectiveShift(view: UIView) {
        let index = self.stackedViews.firstIndex(of: view)!
        shiftedPerspectiveValues[index] = combineAllTransforms()
        
        CATransaction.begin()
        addPerspectiveAnimation(to: view.layer, for: .do)
        CATransaction.commit()
    }
    
    func undoPerspectiveShift(for view: UIView) {
        CATransaction.begin()
        addPerspectiveAnimation(to: view.layer, for: .undo)
        CATransaction.commit()
    }
    
    func undoAllPerspectiveShifts() {
        CATransaction.begin()
        self.stackedViews.map({ self.addPerspectiveAnimation(to: $0.layer, for: .undo)})
        CATransaction.commit()
    }
    
    func perspectiveShift(view: UIView, from: CATransform3D, to: CATransform3D) {
        if let i = stackedViews.firstIndex(of: view) {
            CATransaction.begin()
            let repositioningView = stackedViews[i]
            
            let perspectiveAnimation = makePerspectiveAnimation(from: from, to: to)
            self.set(property: .transform, to, forLayer: repositioningView.layer)
            
            repositioningView.layer.add(perspectiveAnimation, forKey: "transform")
            
            CATransaction.commit()
        }
    }
    
    // MARK: Position Animations
    /*-----------------------------------------------------------*/
    
    func splayAllViews() {
        self.splayedPositionValues = makeSplayPositions(stackedViews.count, origin: center, spacing: spacing)
        
        CATransaction.begin()
        self.stackedViews.map({ self.addPositionAnimation(to: $0.layer, for: .do)})
        CATransaction.commit()
    }
    
    func moveToSplayedPosition(_ view: UIView) {
        self.splayedPositionValues = makeSplayPositions(stackedViews.count, origin: center, spacing: spacing)
        
        CATransaction.begin()
        addPositionAnimation(to: view.layer, for: .do)
        CATransaction.commit()
    }
    
    func moveToUnsplayedPosition(_ view: UIView) {
        CATransaction.begin()
        addPositionAnimation(to: view.layer, for: .undo)
        CATransaction.commit()
    }
    
    func unsplayAllViews() {
        CATransaction.begin()
        self.stackedViews.map({ self.addPositionAnimation(to: $0.layer, for: .undo)})
        CATransaction.commit()
    }
    
    func reposition(view: UIView, from: CGPoint, to: CGPoint) {
        if let i = stackedViews.firstIndex(of: view) {
            CATransaction.begin()
            let repositioningView = stackedViews[i]
            
            let positionAnimation = makePositionAnimation(from: from, to: to)
            self.set(property: .position, to, forLayer: repositioningView.layer)
            
            repositioningView.layer.add(positionAnimation, forKey: "position")
            
            CATransaction.commit()
        }
    }
    
    // MARK: Perspective Shift + Splay Animations
    /*-----------------------------------------------------------*/
    
    
    func perspectiveSplayAllViews() {
        splayedPositionValues = makeSplayPositions(stackedViews.count, origin: center, spacing: spacing)
        shiftedPerspectiveValues.removeAll()
        
        CATransaction.begin()
        
        stackedViews.enumerated().map { (i: Int, stackedView: UIView) in
            let fromPosition = originalPositionValues[i], toPosition = splayedPositionValues[i]
            let fromTransform = originalPerspectiveValues[i], toTransform = combineAllTransforms()
            
            let perspectiveSplayAnimation = makePerspectiveSplayAnimation(from: fromPosition, fromTransform, to: toPosition, toTransform)
            self.set(property: .position, toPosition, forLayer: stackedView.layer)
            self.set(property: .transform, toTransform, forLayer: stackedView.layer)
            
            shiftedPerspectiveValues.insert(toTransform, at: i)
            
            stackedView.layer.add(perspectiveSplayAnimation, forKey: nil)
        }
        
        CATransaction.commit()
    }
    
    func undoPerspectiveSplays() {
        CATransaction.begin()
        
        stackedViews.enumerated().map { (i: Int, stackedView: UIView) in
            let fromPosition = splayedPositionValues[i], toPosition = originalPositionValues[i]
            let fromTransform = shiftedPerspectiveValues[i], toTransform = originalPerspectiveValues[i]
            
            let perspectiveSplayAnimation = makePerspectiveSplayAnimation(from: fromPosition, fromTransform, to: toPosition, toTransform)
            self.set(property: .position, toPosition, forLayer: stackedView.layer)
            self.set(property: .transform, toTransform, forLayer: stackedView.layer)
            
            stackedView.layer.add(perspectiveSplayAnimation, forKey: nil)
        }
        
        CATransaction.commit()
    }
    
    
    /*-----------------------------------------------------------*/
    
    
    private func set(property: Property, _ value: Any, forLayer layer: CALayer) {
        CATransaction.setDisableActions(true)
        
        switch property {
        case .transform:
            if let value = value as? CATransform3D {
                layer.transform = value
            }
        case .position:
            if let value = value as? CGPoint {
                layer.position = value
            }
        }
        
        CATransaction.setDisableActions(false)
    }
    
    private func combineAllTransforms() -> CATransform3D {
        if additionalPerspectiveSplayTransforms.count > 0 {
            return recursiveCombineTransform(transform: perspectiveTransform, array: additionalPerspectiveSplayTransforms)
        } else {
            return perspectiveTransform
        }
    }
    
    private func recursiveCombineTransform(transform: CATransform3D, array: [CATransform3D]) -> CATransform3D {
        if array.count == 1 {
            return CATransform3DConcat(array[0], transform)
        } else {
            return recursiveCombineTransform(transform: CATransform3DConcat(transform, array[0]), array: Array(array.dropFirst()))
        }
    }
    
    // MARK: Animation Adders
    /*-----------------------------------------------------------*/
    
    private func addPerspectiveAnimation(to layer: CALayer, for direction: AnimationDirection) {
        let i = stackedViews.firstIndex(where: { $0.layer == layer })!
        
        switch direction {
        case .do:
            let perspectiveAnimation = makePerspectiveAnimation(from: originalPerspectiveValues[i], to: shiftedPerspectiveValues[i])
            self.set(property: .transform, shiftedPerspectiveValues[i], forLayer: layer)
            
            layer.add(perspectiveAnimation, forKey: "transform")
        case .undo:
            let perspectiveAnimation = makePerspectiveAnimation(from: shiftedPerspectiveValues[i], to: originalPerspectiveValues[i])
            self.set(property: .transform, originalPerspectiveValues[i], forLayer: layer)
            
            layer.add(perspectiveAnimation, forKey: "transform")
        }
    }
    
    private func addPositionAnimation(to layer: CALayer, for direction: AnimationDirection) {
        let i = stackedViews.firstIndex(where: { $0.layer == layer })!
        
        switch direction {
        case .do:
            let positionAnimation = makePositionAnimation(from: originalPositionValues[i], to: splayedPositionValues[i])
            self.set(property: .position, splayedPositionValues[i], forLayer: layer)
            
            layer.add(positionAnimation, forKey: "position")
        case .undo:
            let positionAnimation = makePositionAnimation(from: splayedPositionValues[i], to: originalPositionValues[i])
            self.set(property: .position, originalPositionValues[i], forLayer: layer)
            
            layer.add(positionAnimation, forKey: "position")
        }
    }
    
    // MARK: Animation Makers
    /*-----------------------------------------------------------*/
    
    private func makePerspectiveAnimation(from: CATransform3D, to: CATransform3D) -> CABasicAnimation {
        let perspectiveAnimation = CABasicAnimation(keyPath: "transform")
        
        perspectiveAnimation.fromValue = from
        perspectiveAnimation.toValue = to
        perspectiveAnimation.duration = self.duration
        perspectiveAnimation.timingFunction = self.timingFunction
        
        return perspectiveAnimation
    }
    
    private func makePerspectiveSplayAnimation(from fromPosition: CGPoint, _ fromTransform: CATransform3D, to toPosition: CGPoint, _ toTransform: CATransform3D ) -> CAAnimationGroup {
        let perspectiveAnimation = makePerspectiveAnimation(from: fromTransform, to: toTransform)
        let positionAnimation = makePositionAnimation(from: fromPosition, to: toPosition)
        
        let perspectiveSplayAnimation = CAAnimationGroup()
        
        perspectiveSplayAnimation.animations = [perspectiveAnimation, positionAnimation]
        perspectiveSplayAnimation.duration = self.duration
        perspectiveSplayAnimation.timingFunction = self.timingFunction
        
        return perspectiveSplayAnimation
    }
    
    private func makePositionAnimation(from: CGPoint, to: CGPoint) -> CABasicAnimation {
        let positionAnimation = CABasicAnimation(keyPath: "position")
        
        positionAnimation.fromValue = from
        positionAnimation.toValue = to
        positionAnimation.duration = self.duration
        positionAnimation.timingFunction = self.timingFunction
        
        return positionAnimation
    }
    
    private func makeSplayPositions(_ count: Int, origin: CGPoint, spacing: CGFloat) -> [CGPoint] {
        var points = [CGPoint]()
        let countIsEven = count % 2 == 0
        let high = countIsEven ? (CGFloat(count) / 2) - 0.5 : CGFloat(count / 2)
        var low = -high
        
        while low <= high {
            points.append(CGPoint(x: origin.x + xOffsetAfterPerspectiveAnimation, y: origin.y - low * spacing))
            low += 1
        }
        
        return points
    }
    
    private func centerStartingPositions() {
        self.stackedViews.map({ $0.layer.position = self.layer.position })
        self.originalPositionValues = stackedViews.map({ $0.layer.position })
    }
    
    
    func add(view: UIView, at i: Int) {
        guard i <= self.stackedViews.count else { return }
        // If the view isn't alredy in the stack, add it.
        guard (!self.stackedViews.contains(view)) else { return }
        
        self.stackedViews.insert(view, at: i)
        self.insertSubview(view, at: i)
    }
    
    func add(view: UIView) {
        // If the view isn't alredy in the stack, add it.
        guard (!self.stackedViews.contains(view)) else { return }
        
        self.stackedViews.append(view)
        self.addSubview(view)
    }
    
    func remove(view: UIView) {
        // If the view exists in the stack, remove it.
        if let i = self.stackedViews.firstIndex(of: view) {
            self.stackedViews.remove(at: i)
        }
    }
}

