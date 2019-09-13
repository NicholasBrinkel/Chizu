//
//  Routes.swift
//  Chizu
//
//  Created by Nick on 9/13/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import UIKit

class Routes {
    static let E2Route = Route(floors: [UIImage(named: "floor1")!, UIImage(named: "floor2")!, UIImage(named: "floor3")!, UIImage(named: "floor4")!, UIImage(named: "floor5")!], routePath: Example1.self)
    
    // Custom routes.
    /// (0, 0) IS THE UPPER LEFT CORNER OF THE CONTENT. NOT the Picture. if the picture is in the shape of a reversed L, extend the highest point
    /// and furthest left point and let those values combined be (0, 0).
    enum Example1: RoutePath, CaseIterable {
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
    }
}

protocol RoutePath {
    func getRoutePathPoints() -> [Cell]
}

struct Route {
    let floors: [UIImage]
    let routePath: RoutePath.Type
}
