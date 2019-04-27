//
//  MapManager.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/14/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import Foundation
import CoreLocation

protocol MapManager {
    var countries: [Country] { get }
    var cities: [City] { get }
    var currentLocation: CLLocation? { get }
    
    func askPermission(onChange: CLAuthorizationStatusCompletion?)
    func startObservingLocation(onChange: CLLocationCompletion?)
    func getFilledCountries(completion: ((Result<[Country]>) -> Void)?)
    func getCoordinates(by city: String, completion: ((CLLocationCoordinate2D?, Error?) -> Void)?)
}


private struct Constants {
    static var precision: Double { return 1e3 }
}

typealias CLLocationCompletion = (CLLocation) -> Void
typealias CLAuthorizationStatusCompletion = (CLAuthorizationStatus) -> Void

final class MapManagerImpl: NSObject, MapManager {
    private lazy var locationManager = CLLocationManager()
    private var onLocationChange: CLLocationCompletion?
    private var onStatusChange: CLAuthorizationStatusCompletion?
    private let networkingManager: NetworkManager
    private var status: CLAuthorizationStatus?
    
    var countries = [Country]() {
        didSet {
            self.cities = self.countries.flatMap { $0.cities }
        }
    }
    lazy var cities = [City]()
    var currentLocation: CLLocation?

    init(networkingManager: NetworkManager) {
        self.networkingManager = networkingManager

        super.init()
    }
    
    func startObservingLocation(onChange: CLLocationCompletion?) {
        self.onLocationChange = onChange
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        self.locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func askPermission(onChange: CLAuthorizationStatusCompletion?) {
        self.status.apply(self.onStatusChange)
        self.onStatusChange = onChange
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func getFilledCountries(completion: ((Result<[Country]>) -> Void)?) {
        let group = DispatchGroup()
        var countries = [Country]()
        var cities = [City]()
        var errorOccurred = false
        self.networkingManager.showNetworkIndicator(true)
        
        group.enter()
        self.networkingManager.getCountries { result in
            defer { group.leave() }
            
            switch result {
            case .success(let value):
                countries = value
            case .failure:
                if errorOccurred {
                    return
                }
                
                errorOccurred = true
                completion?(result)
            }
        }
        
        group.enter()
        self.networkingManager.getCities { result in
            defer { group.leave() }
            
            switch result {
            case .success(let value):
                cities = value
            case .failure(let error):
                if errorOccurred {
                    return
                }

                completion?(.failure(error))
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            defer { self.networkingManager.showNetworkIndicator(false) }
            guard !errorOccurred else { return }
            
            for city in cities {
                for country in countries {
                    if city.countryCode == country.code {
                        city.country = country
                        country.cities.append(city)
                        break
                    }
                }
            }
            
            self.countries = countries
            completion?(.success(countries))
        }
    }
    
    func getCoordinates(by city: String, completion: ((CLLocationCoordinate2D?, Error?) -> Void)?) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(city) { (placemarks, error) in
            guard let placemark = placemarks?.first else {
                return
            }
            
            completion?(placemark.location?.coordinate, error)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MapManagerImpl: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if let currentLocation = self.currentLocation, currentLocation.distance(from: location) < Constants.precision {
            return
        }
        
        self.currentLocation = locations.last
        self.currentLocation.apply(self.onLocationChange)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.onStatusChange?(status)
        self.status = status
    }
}
