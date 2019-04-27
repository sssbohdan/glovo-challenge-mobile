//
//  Array.swift
//  Rolique
//
//  Created by Bohdan Savych on 8/22/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation
import CoreLocation

extension Array {
    subscript(safe index: Int) -> Element? {
        get {
            return index < count && index >= 0 ? self[index] : nil
        } set {
            if let element = newValue, index < count {
                self[index] = element
            }
        }
    }
    
    func getRandomElements(amount: Int) -> [Element] {
        assert(amount <= self.count, "You can't get more elements that are currently in array")
        var indices = Set<Int>(0..<self.count)
        var randomElements = [Element]()
        for _ in 0..<amount {
            let index = indices.randomElement()!
            randomElements.append(self[index])
            indices.remove(index)
        }
        
        return randomElements
    }
}

extension Array where Element == CLLocationCoordinate2D {
    func findHeuristicCenter() -> CLLocationCoordinate2D? {
        guard let first = self.first else { return nil }
        var minLongitude = first.longitude
        var maxLongitude = first.longitude
        var minLatitude = first.latitude
        var maxLatitude = first.latitude
        
        for coordinate in self {
            let latitude = coordinate.latitude
            let longitude = coordinate.longitude
            
            if latitude > maxLatitude {
                maxLatitude = latitude
            } else if latitude < minLatitude {
                minLatitude = latitude
            }
            
            if longitude > maxLongitude {
                maxLongitude = longitude
            } else if longitude < minLongitude {
                minLongitude = longitude
            }
        }
        
        let heuristicCenter = CLLocationCoordinate2D(latitude: (minLatitude + maxLatitude) / 2, longitude: (minLongitude + maxLongitude) / 2)
        
        return heuristicCenter
    }
}

extension Array where Element: Equatable {
    mutating func changeExistence(_ element: Element) {
        if contains(element) {
            remove(at: index(of: element)!)
        } else {
            append(element)
        }
    }
    
    mutating func remove(_ element: Element) {
        var indeces = [Int]()
        
        for (index, el) in self.enumerated() where el == element {
            indeces.append(index)
        }
        
        indeces.forEach { remove(at: $0) }
    }
    
    ///
    /// Returns Array which consist of elements which are meets 2 or more times.
    ///
    var duplicatedElements: [Element] {
        var arr = [Element]()
        
        for (index, element) in self.enumerated() {
            if arr.contains(element) { continue }
            for (innerIndex, innerElement) in self.enumerated() {
                if innerIndex == index { continue }
                if arr.contains(element) { break }
                
                if element == innerElement {
                    arr.append(element)
                }
            }
        }
        
        return arr
    }
}
