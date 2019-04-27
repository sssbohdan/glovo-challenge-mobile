//
//  MarkerDescription.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/25/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import Foundation
import CoreLocation

final class MarkerDescription {
    var coordinate: CLLocationCoordinate2D
    
    var title: String?
    var description: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String? = nil, description: String? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.description = description
    }
}

// MARK: - Hashable
extension MarkerDescription: Hashable {
    public var hashValue: Int { return coordinate.toString().hashValue }
    
    static func == (lhs: MarkerDescription, rhs: MarkerDescription) -> Bool {
        return lhs.coordinate == rhs.coordinate
    }
}
