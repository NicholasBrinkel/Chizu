//
//  FavoritesData.swift
//  Chizu
//
//  Created by Apple User on 9/22/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import Foundation

class POICategoriesData {
    static var favorites = [POIType]() {
        didSet {
            NotificationCenter.default.post(name: .favAdded, object: nil)
        }
    }
    static var dining = [POIType]()
    static var events = [POIType]()
}
