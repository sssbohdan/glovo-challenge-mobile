//
//  GMSPolygon.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/22/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import CoreLocation
import GoogleMaps

extension GMSPolygon {
    func contains(polygon: GMSPolygon) -> Bool {
        let allCoordinatesInPolygon = polygon.path?.getCoordinates()
            .map { self.contains(coordinate: $0) }
            .reduce(true, { $0 && $1 })
        return allCoordinatesInPolygon ?? true
    }
    
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        if self.path != nil {
            return GMSGeometryContainsLocation(coordinate, self.path!, true)
        } else {
            return false
        }
    }
}
