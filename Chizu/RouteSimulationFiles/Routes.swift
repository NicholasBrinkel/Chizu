//
//  Routes.swift
//  Chizu
//
//  Created by Nick on 9/13/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import UIKit

class Routes {
    private static let E2Floors = [
        UIImageView(image: UIImage(named: "floor1")!.imageRotatedByDegrees(degrees: 90)),
        UIImageView(image: UIImage(named: "floor2")!.imageRotatedByDegrees(degrees: 90)),
        UIImageView(image: UIImage(named: "floor3")!.imageRotatedByDegrees(degrees: 90)),
        UIImageView(image: UIImage(named: "floor4")!.imageRotatedByDegrees(degrees: 90)),
        UIImageView(image: UIImage(named: "floor5")!.imageRotatedByDegrees(degrees: 90))
    ]
    
    static let E2Route = Route(
        floors: Routes.E2Floors,
        routePath: Example1(),
        steps: [
            Step(isButtonVisible: false, isDirectionLabelVisible: false, directionInstruction: "", animation: .none, duration: 0.5),
            Step(isButtonVisible: false, isDirectionLabelVisible: false, directionInstruction: "", animation: .drawAllSegments(Example1()), duration: 2),
            Step(isButtonVisible: false, isDirectionLabelVisible: false, directionInstruction: "", animation: .perspectiveSplayAllViews, duration: 3),
            Step(isButtonVisible: true, isDirectionLabelVisible: true, directionInstruction: "Walk from desk to Elevator", animation: .spotlight(Example1.secondFloor.view)),
            Step(isButtonVisible: true, isDirectionLabelVisible: true, directionInstruction: "Take Elevator", animation: .undoSpotlight),
            Step(isButtonVisible: true, isDirectionLabelVisible: true, directionInstruction: "Walk to Conference Room", animation: .spotlight(Example1.fifthFloor.view)),
            Step(isButtonVisible: true, isDirectionLabelVisible: true, directionInstruction: "Done!", animation: .undoSpotlight)
        ]
    )
    
    // Custom routes.
    /// (0, 0) IS THE UPPER LEFT CORNER OF THE CONTENT. NOT the Picture. if the picture is in the shape of a reversed L, extend the highest point
    /// and furthest left point and let those values combined be (0, 0).
    class Example1: RoutePath {
        static let fifthFloor: Segment = {
            return Segment(pathPoints: Segments.fifthFloor.getRoutePathPoints(), view: Segments.fifthFloor.view())
        }()
        static let secondFloor: Segment = {
            return Segment(pathPoints: Segments.secondFloor.getRoutePathPoints(), view: Segments.secondFloor.view())
        }()
        
        lazy var segments: [Segment] = [Example1.fifthFloor, Example1.secondFloor]
        
        private enum Segments: CaseIterable {
            case fifthFloor
            case secondFloor
            
            func getRoutePathPoints() -> [Cell] {
                switch self {
                case .fifthFloor:
                    return [Cell(x: 40.5, y: 40.5), Cell(x: 40.5, y: 37), Cell(x: 33, y: 37), Cell(x: 33, y: 84), Cell(x: 23, y: 84), Cell(x: 23, y: 90)]
                case .secondFloor:
                    return [Cell(x: 23.4, y: 90), Cell(x: 23.4, y: 84), Cell(x: 14.5, y: 84), Cell(x: 14.5, y: 131), Cell(x: 2, y: 131)/*, Cell(x: 5.5, y: 26)*/]
                }
            }
            
            func view() -> UIImageView {
                switch self {
                case .secondFloor:
                    return Routes.E2Floors[1]
                case .fifthFloor:
                    return Routes.E2Floors[4]
                }
            }
        }
    }
}

protocol RoutePath {
    var segments: [Segment] { get }
}

struct Segment {
    let pathPoints: [Cell]
    let view: UIImageView
}

struct Route {
    let floors: [UIImageView]
    let routePath: RoutePath
    let steps: [Step]
}
