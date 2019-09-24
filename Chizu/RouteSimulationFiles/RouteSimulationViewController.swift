//
//  RouteSimulationViewController.swift
//  Chizu
//
//  Created by Nick on 9/13/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import UIKit
import SnapKit

class RouteSimulationViewController: UIViewController {
    @IBOutlet weak var currentInst: UILabel!
    @IBOutlet weak var floors: PerspectiveStackView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var endNavButton: UIButton!
    
    private var route: Route!
    private var currentStep: Step! {
        didSet {
            self.configureViewForStep(self.currentStep)
        }
    }
    private var stepIndex = 0
    
    var timer: Timer?
    var time: Float = 0
    var timeUntilNextStep: Float = 2
    
    
    func configureWithRoute(_ route: Route) {
        self.route = route
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(floors)
        
        view.bringSubviewToFront(nextButton)
        view.bringSubviewToFront(currentInst)
        
        for floor in route.floors {
            floor.contentMode = .scaleAspectFit
            floors.add(view: floor)
        }
        
        floors.spacing = 90
        
        nextButton.layer.cornerRadius = 8
        endNavButton.layer.cornerRadius = 8
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setInitialView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func restartTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(updateTimer),
                                     userInfo: nil,
                                     repeats: true)
        time = 0
    }
    
    @objc func updateTimer() {
        time += 0.1
        
        if time >= timeUntilNextStep {
            timer?.invalidate()
            nextStep()
        }
    }
    
    func nextStep() {
        if stepIndex < route.steps.count - 1 {
            stepIndex += 1
            currentStep = route.steps[stepIndex]
        }
    }
    
    func setInitialView() {
        if let firstStep = route.steps.first {
            configureViewForStep(firstStep)
        }
    }
    
    func configureViewForStep(_ step: Step) {
        
        UIView.animate(withDuration: 0.5) {
            self.currentInst.alpha = step.isDirectionLabelVisible ? 1 : 0
            self.nextButton.alpha = step.duration == nil ? 1 : 0
            self.nextButton.isEnabled = (step.duration == nil)
        }
        
        self.currentInst.text = step.directionInstruction
        
        if let duration = step.duration {
            timeUntilNextStep = duration
            restartTimer()
        }
        
        if let animation = step.animation {
            performAnimation(animation)
        }
    }
    
    func performAnimation(_ animation: AnimationType) {
        switch animation {
        case .perspectiveShift(let stackedView):
            floors.perspectiveShift(view: stackedView)
        case .undoPerspectiveShift(let stackedView):
            floors.undoPerspectiveShift(for: stackedView)
        case .perspectiveShiftAllViews:
            floors.perspectiveShiftAllViews()
        case .undoAllPerspectiveShifts:
            floors.undoAllPerspectiveShifts()
        case .splayAllViews:
            floors.splayAllViews()
        case .moveToSplayedPosition(let stackedView):
            floors.moveToSplayedPosition(stackedView)
        case .moveToUnsplayedPosition(let stackedView):
            floors.moveToUnsplayedPosition(stackedView)
        case .unsplayAllViews:
            floors.unsplayAllViews()
        case .perspectiveSplayAllViews:
            floors.perspectiveSplayAllViews()
        case .moveToSplayedPositionWithPerspective(let stackedView):
            floors.moveToSplayedPositionWithPerspective(stackedView)
        case .moveToUnsplayedPositionWithPerspective(let stackedView):
            floors.moveToUnsplayedPositionWithPerspective(stackedView)
        case .undoPerspectiveSplays:
            floors.undoPerspectiveSplays()
        case .spotlight(let stackedView):
            floors.spotlight(stackedView)
        case .undoSpotlight:
            floors.undoSpotlightAnimation()
        case .drawSegment(let routePath):
            floors.drawRoute(forSegment: routePath)
        case .drawAllSegments(let routePath):
            floors.drawAllRouteSegments(forRoutePath: routePath)
        case .trekSegment(let segment):
            floors.trek(alongSegment: segment)
        case .removeUserLocation:
            floors.removeUserLocation()
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        nextStep()
    }
    
    @IBAction func endNavButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
