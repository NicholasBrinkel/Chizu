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
    case unAnimated
    case animated
    
    func opposite() -> AnimationDirection {
        switch self {
        case .unAnimated:
            return .animated
        case .animated:
            return .unAnimated
        }
    }
    
    mutating func toggle() {
        switch self {
        case .animated:
            self = .unAnimated
        case .unAnimated:
            self = .animated
        }
    }
}

enum AnimationType {
    case perspectiveShift(UIView)
    case undoPerspectiveShift(UIView)
    case perspectiveShiftAllViews
    case undoAllPerspectiveShifts
    
    case splayAllViews
    case moveToSplayedPosition(UIView)
    case moveToUnsplayedPosition(UIView)
    case unsplayAllViews
    
    case perspectiveSplayAllViews
    case moveToSplayedPositionWithPerspective(UIView)
    case moveToUnsplayedPositionWithPerspective(UIView)
    case undoPerspectiveSplays
    
    case spotlight(UIView)
    case drawRoute
}

class PerspectiveStackView: UIView {
    private var stackedViews = [UIView]()
    private var stackedPerspectiveViews = [PerspectiveView]()
    var spacing: CGFloat = 50
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
    private var originalPositionValues = [CGPoint]()
    
    private enum Property {
        case transform
        case position
    }
    
    init(frame: CGRect, withStackedViews views: [UIView], andSpacing spacing: CGFloat) {
        self.spacing = spacing
        super.init(frame: frame)
        
        self.originalPerspectiveValues = views.map({
            print("\n Position: \($0.layer.position) \n")
            return $0.layer.transform
        })
        self.originalPositionValues = views.map({
            return $0.layer.position
        })
        
        _ = views.map({ self.add(view: $0) })
        
        centerStartingPositions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateToFromPositions()
        for view in stackedPerspectiveViews {
            view.updateConstraints()
        }
    }
    
    func degToRad(_ degrees: CGFloat) -> CGFloat {
        return degrees * CGFloat((Float.pi)) / 180
    }
    
    

    // MARK: Perspective Shift Animations
    /*-----------------------------------------------------------*/
    
    
    
    func perspectiveShiftAllViews() {
        updateToFromTransforms()
        setDirectionForAll(property: .transform, to: .animated)
        
        CATransaction.begin()
        _ = self.stackedPerspectiveViews.map({ self.addPerspectiveAnimation(to: $0)})
        CATransaction.commit()
    }
    
    func perspectiveShift(view: UIView) {
        let perspectiveView = perspectiveViewForView(view: view)
        setDirection(.animated, forProperty: .transform, inView: perspectiveView)
        
        CATransaction.begin()
        addPerspectiveAnimation(to: perspectiveView)
        CATransaction.commit()
    }
    
    func undoPerspectiveShift(for view: UIView) {
        let perspectiveView = perspectiveViewForView(view: view)
        setDirection(.unAnimated, forProperty: .transform, inView: perspectiveView)
        
        CATransaction.begin()
        addPerspectiveAnimation(to: perspectiveView)
        CATransaction.commit()
    }
    
    func undoAllPerspectiveShifts() {
        setDirectionForAll(property: .transform, to: .unAnimated)
        
        CATransaction.begin()
        _ = self.stackedPerspectiveViews.map({ self.addPerspectiveAnimation(to: $0)})
        CATransaction.commit()
    }
    
    func perspectiveShift(view: UIView, from: CATransform3D, to: CATransform3D) {
        let repositioningView = perspectiveViewForView(view: view)

        repositioningView.fromTransformValue = from
        repositioningView.toTransformValue = to
        
        CATransaction.begin()
        
        let perspectiveAnimation = makePerspectiveAnimation(from: from, to: to)
        update(property: .transform, for: repositioningView)
        
        repositioningView.layer.add(perspectiveAnimation, forKey: "transform")
        
        CATransaction.commit()
    }
    
    // MARK: Position Animations
    /*-----------------------------------------------------------*/
    
    func splayAllViews() {
        setDirectionForAll(property: .position, to: .animated)
        
        CATransaction.begin()
        _ = self.stackedPerspectiveViews.map({ self.addPositionAnimation(to: $0)})
        CATransaction.commit()
    }
    
    func moveToSplayedPosition(_ view: UIView) {
        let perspectiveView = perspectiveViewForView(view: view)
        setDirection(.animated, forProperty: .position, inView: perspectiveView)
        
        CATransaction.begin()
        addPositionAnimation(to: perspectiveView)
        CATransaction.commit()
    }
    
    func moveToUnsplayedPosition(_ view: UIView) {
        let perspectiveView = perspectiveViewForView(view: view)
        setDirection(.unAnimated, forProperty: .position, inView: perspectiveView)
        
        CATransaction.begin()
        addPositionAnimation(to: perspectiveView)
        CATransaction.commit()
    }
    
    func unsplayAllViews() {
        setDirectionForAll(property: .position, to: .unAnimated)
        
        CATransaction.begin()
        _ = self.stackedPerspectiveViews.map({ self.addPositionAnimation(to: $0)})
        CATransaction.commit()
    }
    
    func reposition(view: UIView, from: CGPoint, to: CGPoint) {
        let repositioningView = perspectiveViewForView(view: view)

        repositioningView.fromPositionValue = from
        repositioningView.toPositionValue = to
        
        CATransaction.begin()
        
        let positionAnimation = makePositionAnimation(for: repositioningView)
        update(property: .position, for: repositioningView)
        
        repositioningView.layer.add(positionAnimation, forKey: "position")
        
        CATransaction.commit()
    }
    
    // MARK: Perspective Shift + Splay Animations
    /*-----------------------------------------------------------*/
    
    
    func perspectiveSplayAllViews() {
        setDirectionForAll(property: .transform, to: .animated)
        setDirectionForAll(property: .position, to: .animated)
        
        CATransaction.begin()
        _ = stackedPerspectiveViews.map({ self.addPerspectiveSplayAnimation(to: $0) })
        CATransaction.commit()
    }
    
    func moveToSplayedPositionWithPerspective(_ view: UIView) {
        let perspectiveView = perspectiveViewForView(view: view)
        setDirection(.animated, forProperty: .transform, inView: perspectiveView)
        setDirection(.animated, forProperty: .position, inView: perspectiveView)
        
        addPerspectiveSplayAnimation(to: perspectiveView)
    }
    
    func moveToUnsplayedPositionWithPerspective(_ view: UIView) {
        let perspectiveView = perspectiveViewForView(view: view)
        setDirection(.unAnimated, forProperty: .transform, inView: perspectiveView)
        setDirection(.unAnimated, forProperty: .position, inView: perspectiveView)
        
        addPerspectiveSplayAnimation(to: perspectiveView)
    }
    
    func undoPerspectiveSplays() {
        setDirectionForAll(property: .transform, to: .unAnimated)
        setDirectionForAll(property: .position, to: .unAnimated)
        
        CATransaction.begin()
        _ = stackedPerspectiveViews.map({ self.addPerspectiveSplayAnimation(to: $0) })
        CATransaction.commit()
    }
    
    
    func addPath(forRoute routePath: RoutePath, toIndex i: Int) {
        let pathCreator = PathCreator()
        let path = pathCreator.createPath(fromPoints: Grid.shared.getPointsForRoute(routePath))
        let pathLayer = pathCreator.makePathLayer(withPath: path, withAnimationTimingFunctionName: .easeIn, styleProvider: .none)
        pathLayer.fillColor = nil
        
        stackedPerspectiveViews[i].layer.addSublayer(pathLayer)
        
                let animation =  CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
                animation.toValue = 1
                animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
                animation.duration = 2
        
                CATransaction.begin()
                pathLayer.add(animation, forKey: "line")
            pathLayer.strokeEnd = 1
                CATransaction.commit()
    }
    
    
    // MARK: PerspectiveView updating helper functions
    /*-----------------------------------------------------------*/
    
    
    private func perspectiveViewForView(view: UIView) -> PerspectiveView {
        return stackedPerspectiveViews[index(of: view)]
    }
    
    private func updateToFromPositions() {
        print("Start --------------------------------------------------------------------------------------------------------")
        let splayPositions = makeSplayPositions(stackedPerspectiveViews.count, origin: self.originalPositionValues.first ?? self.layer.position, spacing: spacing)
        
        _ = stackedPerspectiveViews.enumerated().map { (i: Int, view: PerspectiveView) in
            view.fromPositionValue = originalPositionValues[i]
            print("\nUpdated from Position: \(view.fromPositionValue)\n")
            view.toPositionValue = splayPositions[i]
            print("\nUpdated to Position: \(view.toPositionValue)\n")
        }
        
        print("End --------------------------------------------------------------------------------------------------------")
    }
    
    private func updateToFromTransforms() {
        let toTransform = combineAllTransforms()
        
        _ = stackedPerspectiveViews.enumerated().map { (i: Int, view: PerspectiveView) in
            view.fromTransformValue = originalPerspectiveValues[i]
//            print("\nUpdated Tansform: \(toTransform)\n")
            view.toTransformValue = toTransform
            
        }
    }
    
    private func setDirectionForAll(property: Property, to direction: AnimationDirection) {
        _ = stackedPerspectiveViews.map({
            setDirection(direction, forProperty: property, inView: $0)
        })
    }
    
    private func setDirection(_ direction: AnimationDirection, forProperty property: Property, inView perspectiveView: PerspectiveView) {
        switch property {
        case .transform:
            perspectiveView.prevTransformState = perspectiveView.currentTransformState
            perspectiveView.currentTransformState = direction
        case .position:
            //print("\(perspectiveView.positionValueForPrevState()) set to \(perspectiveView.positionValueForState())"
            perspectiveView.prevPositionState = perspectiveView.currentPositionState
            perspectiveView.currentPositionState = direction
        }
    }
    
    private func index(of view: UIView) -> Int {
        return stackedViews.firstIndex(of: view)!
    }
    
    
    // MARK: Animation Maker Helper Functions
    /*-----------------------------------------------------------*/
    
    
    private func update(property: Property, for view: PerspectiveView) {
        CATransaction.setDisableActions(true)
        
        switch property {
        case .transform:
            view.layer.transform = view.transformValueForState()
        case .position:
            view.layer.position = view.positionValueForState()
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
        _ = self.stackedPerspectiveViews.map({ $0.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
        }) })
        _ = self.stackedPerspectiveViews.map({ $0.subviews.map({ $0.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
        })})})
        updateToFromPositions()
        self.layoutIfNeeded()
    }
    
    // MARK: Animation Adders
    /*-----------------------------------------------------------*/
    
    private func addPerspectiveAnimation(to view: PerspectiveView) {
        let perspectiveAnimation = makePerspectiveAnimation(for: view)
        update(property: .transform, for: view)
        
        view.layer.add(perspectiveAnimation, forKey: "transform")
    }
    
    private func addPositionAnimation(to view: PerspectiveView) {
        let positionAnimation = makePositionAnimation(for: view)
        update(property: .position, for: view)
        
        view.layer.add(positionAnimation, forKey: "position")
    }
    
    private func addPerspectiveSplayAnimation(to view: PerspectiveView) {
        let perspectiveSplayAnimation = makePerspectiveSplayAnimation(for: view)
        update(property: .transform, for: view)
        update(property: .position, for: view)
        
        view.layer.add(perspectiveSplayAnimation, forKey: nil)
    }
    
    // MARK: Animation Makers
    /*-----------------------------------------------------------*/
    
    private func makePerspectiveAnimation(for view: PerspectiveView) -> CABasicAnimation {
//        print("from: \(view.transformValueForPrevState())")
        return makePerspectiveAnimation(from: view.layer.transform, to: view.transformValueForState())
    }
    
    private func makePositionAnimation(for view: PerspectiveView) -> CABasicAnimation {
        return makePositionAnimation(from: view.layer.position, to: view.positionValueForState())
    }
    
    private func makePerspectiveSplayAnimation(for view: PerspectiveView) -> CAAnimationGroup {
        let perspectiveAnimation = makePerspectiveAnimation(for: view)
        let positionAnimation = makePositionAnimation(for: view)
        
        let perspectiveSplayAnimation = CAAnimationGroup()
        
        perspectiveSplayAnimation.animations = [perspectiveAnimation, positionAnimation]
        perspectiveSplayAnimation.duration = self.duration
        perspectiveSplayAnimation.timingFunction = self.timingFunction
        
        return perspectiveSplayAnimation
    }
    
    private func makePerspectiveAnimation(from: CATransform3D, to: CATransform3D) -> CABasicAnimation {
        let perspectiveAnimation = CABasicAnimation(keyPath: "transform")
        
        perspectiveAnimation.fromValue = from
        perspectiveAnimation.toValue = to
        perspectiveAnimation.duration = self.duration
        perspectiveAnimation.timingFunction = self.timingFunction
        
        return perspectiveAnimation
    }
    
    private func makePositionAnimation(from: CGPoint, to: CGPoint) -> CABasicAnimation {
        let positionAnimation = CABasicAnimation(keyPath: "position")
        
        print("\nfrom: \(from), to \(to)\n")
        
        positionAnimation.fromValue = from
        positionAnimation.toValue = to
        positionAnimation.duration = self.duration
        positionAnimation.timingFunction = self.timingFunction
        
        return positionAnimation
    }
    
    /*------------------------------------------------------------*/
    
    
    func add(view: UIView, at i: Int) {
        guard i <= self.stackedViews.count else { return }
        // If the view isn't alredy in the stack, add it.
        guard (!self.stackedViews.contains(view)) else { return }
        
        let perspectiveView = makePerspectiveViewWith(view)
        self.stackedViews.insert(view, at: i)
        self.stackedPerspectiveViews.insert(perspectiveView, at: i)
        
        insertSubview(perspectiveView, at: i)
        perspectiveView.snp.makeConstraints { (make) in
            make.topMargin.bottomMargin.leadingMargin.trailingMargin.equalToSuperview()
            
            self.originalPerspectiveValues = stackedViews.map({
                print("\n Position: \($0.layer.position) \n")
                return $0.layer.transform
            })
            self.originalPositionValues = stackedViews.map({
                return $0.layer.position
            })
            make.center.equalToSuperview()
        }
        
        self.originalPerspectiveValues.append(view.layer.transform)
        
        centerStartingPositions()
        updateToFromPositions()
    }
    
    func add(view: UIView) {
        // If the view isn't alredy in the stack, add it.
        guard (!self.stackedViews.contains(view)) else { return }
        
        let perspectiveView = makePerspectiveViewWith(view)
        self.stackedPerspectiveViews.append(perspectiveView)
        self.stackedViews.append(view)
        
        self.originalPerspectiveValues.append(view.layer.transform)
        
        addSubview(perspectiveView)
        perspectiveView.snp.makeConstraints { (make) in
            make.topMargin.bottomMargin.leadingMargin.trailingMargin.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        centerStartingPositions()
        updateToFromPositions()
    }
    
    private func makePerspectiveViewWith(_ view: UIView) -> PerspectiveView {
        let perspectiveView = PerspectiveView(frame: view.frame)
        
        perspectiveView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.topMargin.bottomMargin.leadingMargin.trailingMargin.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        return perspectiveView
    }
    
    func remove(view: UIView) {
        // If the view exists in the stack, remove it.
        if let i = self.stackedViews.firstIndex(of: view) {
            self.stackedViews.remove(at: i)
        }
    }
}

