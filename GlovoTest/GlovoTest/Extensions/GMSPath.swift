//
//  GMSPath.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/24/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import CoreLocation
import GoogleMaps

extension GMSPath {
    func getCoordinates() -> [CLLocationCoordinate2D] {
        var counter: UInt = 0
        var coordinates = [CLLocationCoordinate2D]()
        while true {
            let coordinate = self.coordinate(at: counter)
            if coordinate == kCLLocationCoordinate2DInvalid {
                return coordinates
            }
            
            counter += 1
            coordinates.append(coordinate)
        }
    }
}
