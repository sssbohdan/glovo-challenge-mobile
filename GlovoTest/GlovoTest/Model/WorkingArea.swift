//
//  WorkingArea.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/25/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import CoreLocation

final class WorkingArea {
    var coordinates = [CLLocationCoordinate2D]() {
        didSet {
            self.estimatedCenter = coordinates.findHeuristicCenter()
        }
    }
    private(set) var estimatedCenter: CLLocationCoordinate2D?
    
    init(coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = coordinates
        self.estimatedCenter = coordinates.findHeuristicCenter()
    }
}

extension WorkingArea: Hashable {
    static func == (lhs: WorkingArea, rhs: WorkingArea) -> Bool {
        return lhs.estimatedCenter == rhs.estimatedCenter
    }
    
    var hashValue: Int {
        guard let estimatedCenter = self.estimatedCenter else { return 0 }
        return estimatedCenter.toString().hashValue
    }
}
