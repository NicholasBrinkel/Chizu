//
//  PerspectiveStackView.swift
//  Chizu
//
//  Created by Nick on 7/23/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import SnapKit
import UIKit

enum AnimationDirection {
    case `do`
    case undo
    
    func opposite() -> AnimationDirection {
        switch self {
        case .do:
            return .undo
        case .undo:
            return .do
        }
    }
}

class PerspectiveStackView: UIView {
    private var stackedViews = [UIView]()
    private var stackedPerspectiveViews = [PerspectiveView]()
    var spacing: CGFloat
    var duration: Double = 1
    var timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    var additionalPerspectiveSplayTransforms = [CATransform3D]() {
        didSet {
            updateToFromTransforms()
        }
    }
    var xOffsetAfterPerspectiveAnimation: CGFloat = 0.0
    
    var perspectiveTransform: CATransform3D = {
        func degToRad(_ degrees: CGFloat) -> CGFloat {
            return degrees * CGFloat((Float.pi)) / 180
        }
        
        let transform = CATransform3DRotate(CATransform3DIdentity, degToRad(65), 1, 0, 0)
        return CATransform3DRotate(transform, degToRad(50), 0, 0, 1)
        }() {
        didSet {
            updateToFromTransforms()
        }
    }
    
    private var originalPerspectiveValues = [CATransform3D]()
//    private var shiftedPerspectiveValues = [CATransform3D]()
//    private var originalPositionValues = [CGPoint]()
//    private var splayedPositionValues = [CGPoint]()
    
    private enum Property {
        case transform
        case position
    }
    
    init(frame: CGRect, withStackedViews views: [UIView], andSpacing spacing: CGFloat) {
        self.spacing = spacing
        self.originalPerspectiveValues = views.map({ $0.layer.transform })
//        self.shiftedPerspectiveValues = views.map({ $0.layer.transform })
//
//        self.originalPositionValues = views.map({ $0.layer.position })
        
        super.init(frame: frame)
        
        views.map({ self.add(view: $0) })
        
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
        updateToFromTransforms()
        
        CATransaction.begin()
        self.stackedPerspectiveViews.map({ self.addPerspectiveAnimation(to: $0, for: .do)})
        CATransaction.commit()
    }
    
    func perspectiveShift(view: UIView) {
        let i = index(of: view)
        
        CATransaction.begin()
        addPerspectiveAnimation(to: stackedPerspectiveViews[i], for: .do)
        CATransaction.commit()
    }
    
    func undoPerspectiveShift(for view: UIView) {
        let i = index(of: view)
        
        CATransaction.begin()
        addPerspectiveAnimation(to: stackedPerspectiveViews[i], for: .undo)
        CATransaction.commit()
    }
    
    func undoAllPerspectiveShifts() {
        CATransaction.begin()
        self.stackedPerspectiveViews.map({ self.addPerspectiveAnimation(to: $0, for: .undo)})
        CATransaction.commit()
    }
    
    func perspectiveShift(view: UIView, from: CATransform3D, to: CATransform3D) {
        let repositioningView = stackedPerspectiveViews[index(of: view)]
        
        repositioningView.fromTransformValue = from
        repositioningView.toTransformValue = to
        
        CATransaction.begin()
        
        let perspectiveAnimation = makePerspectiveAnimation(from: from, to: to)
        self.set(property: .transform, for: repositioningView, and: .do)
        
        repositioningView.layer.add(perspectiveAnimation, forKey: "transform")
        
        CATransaction.commit()
    }
    
    // MARK: Position Animations
    /*-----------------------------------------------------------*/
    
    func splayAllViews() {
        CATransaction.begin()
        self.stackedPerspectiveViews.map({ self.addPositionAnimation(to: $0, for: .do)})
        CATransaction.commit()
    }
    
    func moveToSplayedPosition(_ view: UIView) {
        let i = index(of: view)
        
        CATransaction.begin()
        addPositionAnimation(to: stackedPerspectiveViews[i], for: .do)
        CATransaction.commit()
    }
    
    func moveToUnsplayedPosition(_ view: UIView) {
        let i = index(of: view)
        
        CATransaction.begin()
        addPositionAnimation(to: stackedPerspectiveViews[i], for: .undo)
        CATransaction.commit()
    }
    
    func unsplayAllViews() {
        CATransaction.begin()
        self.stackedPerspectiveViews.map({ self.addPositionAnimation(to: $0, for: .undo)})
        CATransaction.commit()
    }
    
    func reposition(view: UIView, from: CGPoint, to: CGPoint) {
        let repositioningView = stackedPerspectiveViews[index(of: view)]
        
        repositioningView.fromPositionValue = from
        repositioningView.toPositionValue = to
        
        CATransaction.begin()
        
        let positionAnimation = makePositionAnimation(for: repositioningView, .do)
        set(property: .position, for: repositioningView, and: .do)
        
        repositioningView.layer.add(positionAnimation, forKey: "position")
        
        CATransaction.commit()
    }
    
    // MARK: Perspective Shift + Splay Animations
    /*-----------------------------------------------------------*/
    
    
    func perspectiveSplayAllViews() {
        animatePerspectiveSplay(for: .do)
    }
    
    func undoPerspectiveSplays() {
        animatePerspectiveSplay(for: .undo)
    }
    
    private func animatePerspectiveSplay(for direction: AnimationDirection) {
        CATransaction.begin()
        
        stackedPerspectiveViews.enumerated().map { (i: Int, stackedView: PerspectiveView) in
            let perspectiveSplayAnimation = makePerspectiveSplayAnimation(for: stackedView, direction)
            self.set(property: .position, for: stackedView, and: direction)
            self.set(property: .transform, for: stackedView, and: direction)
            
            stackedView.layer.add(perspectiveSplayAnimation, forKey: nil)
        }
        
        CATransaction.commit()
    }
    
    
    /*-----------------------------------------------------------*/
    
    
    private func set(property: Property, for view: PerspectiveView, and direction: AnimationDirection) {
        CATransaction.setDisableActions(true)
        
        switch property {
        case .transform:
            view.layer.transform = view.transformValue(direction)
        case .position:
            view.layer.position = view.positionValue(direction)
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
    
    private func addPerspectiveAnimation(to view: PerspectiveView, for direction: AnimationDirection) {
        let perspectiveAnimation = makePerspectiveAnimation(for: view, direction)
        set(property: .transform, for: view, and: direction)
        
        view.layer.add(perspectiveAnimation, forKey: "transform")
    }
    
    private func addPositionAnimation(to view: PerspectiveView, for direction: AnimationDirection) {
        let positionAnimation = makePositionAnimation(for: view, direction)
        set(property: .position, for: view, and: direction)
        
        view.layer.add(positionAnimation, forKey: "position")
    }
    
    // MARK: Animation Makers
    /*-----------------------------------------------------------*/
    
    private func makePerspectiveAnimation(for view: PerspectiveView, _ direction: AnimationDirection) -> CABasicAnimation {
        return makePerspectiveAnimation(from: view.transformValue(direction.opposite()), to: view.transformValue(direction))
    }
    
    private func makePerspectiveAnimation(from: CATransform3D, to: CATransform3D) -> CABasicAnimation {
        let perspectiveAnimation = CABasicAnimation(keyPath: "transform")
        
        perspectiveAnimation.fromValue = from
        perspectiveAnimation.toValue = to
        perspectiveAnimation.duration = self.duration
        perspectiveAnimation.timingFunction = self.timingFunction
        
        return perspectiveAnimation
    }
    
    private func makePerspectiveSplayAnimation(for view: PerspectiveView, _ direction: AnimationDirection) -> CAAnimationGroup {
        let perspectiveAnimation = makePerspectiveAnimation(for: view, direction)
        let positionAnimation = makePositionAnimation(for: view, direction)
        
        let perspectiveSplayAnimation = CAAnimationGroup()
        
        perspectiveSplayAnimation.animations = [perspectiveAnimation, positionAnimation]
        perspectiveSplayAnimation.duration = self.duration
        perspectiveSplayAnimation.timingFunction = self.timingFunction
        
        return perspectiveSplayAnimation
    }
    
    private func makePositionAnimation(for view: PerspectiveView, _ direction: AnimationDirection) -> CABasicAnimation {
        return makePositionAnimation(from: view.positionValue(direction.opposite()), to: view.positionValue(direction))
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
        self.stackedPerspectiveViews.map({ $0.layer.position = self.layer.position })
        updateToFromPositions()
    }
    
    
    func add(view: UIView, at i: Int) {
        guard i <= self.stackedViews.count else { return }
        // If the view isn't alredy in the stack, add it.
        guard (!self.stackedViews.contains(view)) else { return }
        
        let perspectiveView = makePerspectiveViewWith(view)
        self.stackedViews.insert(view, at: i)
        self.stackedPerspectiveViews.insert(perspectiveView, at: i)
        
        insertSubview(perspectiveView, at: i)
        perspectiveView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        updateToFromPositions()
    }
    
    func add(view: UIView) {
        // If the view isn't alredy in the stack, add it.
        guard (!self.stackedViews.contains(view)) else { return }
        
        let perspectiveView = makePerspectiveViewWith(view)
        self.stackedPerspectiveViews.append(perspectiveView)
        self.stackedViews.append(view)
        
        addSubview(perspectiveView)
        perspectiveView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        updateToFromPositions()
    }
    
    private func makePerspectiveViewWith(_ view: UIView) -> PerspectiveView {
        let perspectiveView = PerspectiveView(frame: view.frame)
        
        perspectiveView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        return perspectiveView
    }
    
    private func updateToFromPositions() {
        let splayPositions = makeSplayPositions(stackedPerspectiveViews.count, origin: layer.position, spacing: spacing)
        
        stackedPerspectiveViews.enumerated().map { (i: Int, view: PerspectiveView) in
            view.fromPositionValue = view.layer.position
            view.toPositionValue = splayPositions[i]
        }
    }
    
    private func updateToFromTransforms() {
        let toTransform = combineAllTransforms()
        
        stackedPerspectiveViews.enumerated().map { (i: Int, view: PerspectiveView) in
            view.fromTransformValue = originalPerspectiveValues[i]
            view.toTransformValue = toTransform
        }
    }
    
    func index(of view: UIView) -> Int {
        return stackedViews.firstIndex(of: view)!
    }
    
    func remove(view: UIView) {
        // If the view exists in the stack, remove it.
        if let i = self.stackedViews.firstIndex(of: view) {
            self.stackedViews.remove(at: i)
        }
    }
}

