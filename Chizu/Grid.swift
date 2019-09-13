//
//  Grid.swift
//  Chizu
//
//  Created by Nick on 9/10/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import Foundation
import UIKit

enum SupportedDevice: String {
    case XSMax = "iPhone XS Max"
    case XSMaxSim = "Simulator iPhone XS Max"
    case iPad_6 = "iPad 6"
    case iPad_6Sim = "Simulator iPad 6"
    case XR = "iPhone XR"
    case XRSim = "Simulator iPhone XR"
}

protocol Route {
    func getRoute() -> [Cell]
}

class Grid {
    let device: SupportedDevice?
    
    // There are 2 points per desk, 4 per back-to-back desk. This is the general scale that is used across the grid.
    // Point 0 is the boundary wall, so we start at 1 for routes if they start by the wall
    let xMax: CGFloat = 48
    let yMax: CGFloat = 152
    
    private lazy var calibratePoints = [Cell(x: 0, y: 0), Cell(x: Grid.shared.xMax, y: Grid.shared.yMax)]
    
    // These are the distance from the edge of the picture to the map content. These numbers are added to the points when converted to CGPoints. May vary from device to device.
    var xDistanceFromLeftEdgeToContent: CGFloat = 40.5
    var yDistanceFromTopEdgeToContent: CGFloat = 34
    var grid: [[Cell]] = [[]]
    
    // Custom routes.
    /// (0, 0) IS THE UPPER LEFT CORNER OF THE CONTENT. NOT the Picture. if the picture is in the shape of a reversed L, extend the highest point
    /// and furthest left point and let those values combined be (0, 0).
    enum Example1: Route {
        case fifthFlor
        case secondFloor
        
        func getRoute() -> [Cell] {
            switch self {
            case .fifthFlor:
                return [Cell(x: 0, y: 0), Cell(x: Grid.shared.xMax, y: Grid.shared.yMax), Cell(x: 40.5, y: 40.5), Cell(x: 40.5, y: 37), Cell(x: 33, y: 37), Cell(x: 33, y: 84), Cell(x: 23, y: 84), Cell(x: 23, y: 90)]
            case .secondFloor:
                return [Cell(x: 23.4, y: 90), Cell(x: 23.4, y: 84), Cell(x: 14.5, y: 84), Cell(x: 14.5, y: 131), Cell(x: 2, y: 131)/*, Cell(x: 5.5, y: 26)*/]
            }
        }
    }
    
    static let shared: Grid = {
        return Grid()
    }()
    
    init() {
        device = SupportedDevice(rawValue: UIDevice.modelName)
        
        for x in 0..<Int(xMax) {
            grid.append([Cell]())
            for y in 0..<Int(yMax) {
                grid[x].append(Cell(x: CGFloat(integerLiteral: x), y: CGFloat(integerLiteral: y)))
            }
        }
    }
    
    private func getOffsetCell(for cell: Cell) -> Cell {
        return Cell(x: (cell.x + xDistanceFromLeftEdgeToContent), y: (cell.y + yDistanceFromTopEdgeToContent))
    }
    
    func getPointsForRoute(_ route: Route) -> [CGPoint] {
        if let device = device {
            switch device {
            case .XSMax, .XSMaxSim:
                xDistanceFromLeftEdgeToContent = 40.5
                yDistanceFromTopEdgeToContent = 34
                
                let xScaleFactor: CGFloat = 3.1
                let yScaleFactor: CGFloat = 3.03
                return route.getRoute().map({ getOffsetCell(for: $0) }).map({ CGPoint(x: $0.x * xScaleFactor, y: $0.y * yScaleFactor) })
            case .iPad_6, .iPad_6Sim:
                xDistanceFromLeftEdgeToContent = 41.5
                yDistanceFromTopEdgeToContent = 4.75
                
                let xScaleFactor: CGFloat = 5.8
                let yScaleFactor: CGFloat = 5.75
                return route.getRoute().map({ getOffsetCell(for: $0) }).map({ CGPoint(x: $0.x * xScaleFactor, y: $0.y * yScaleFactor) })
            case .XR, .XRSim:
                xDistanceFromLeftEdgeToContent = 41.5
                yDistanceFromTopEdgeToContent = 41
                
                let xScaleFactor: CGFloat = 3.1
                let yScaleFactor: CGFloat = 3.03
                return route.getRoute().map({ getOffsetCell(for: $0) }).map({ CGPoint(x: $0.x * xScaleFactor, y: $0.y * yScaleFactor) })
            }
        } else {
            xDistanceFromLeftEdgeToContent = 43
            yDistanceFromTopEdgeToContent = 34
            
            let xScaleFactor: CGFloat = 3.1
            let yScaleFactor: CGFloat = 3.03
            return route.getRoute().map({ getOffsetCell(for: $0) }).map({ CGPoint(x: $0.x * xScaleFactor, y: $0.y * yScaleFactor) })
        }
    }
}

struct Cell {
    let x: CGFloat
    let y: CGFloat
}

public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad11,4", "iPad11,5":                    return "iPad Air (3rd generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad Mini 5"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}
