//
//  MapViewModel.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/13/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import Foundation
import CoreLocation

protocol MapViewModel: ViewModel {
    var currentLocation: CLLocation? { get }
    var selectedCity: City? { get }

    var onLocationChange: CLLocationCompletion? { get set }
    var shouldUpdateCityInfo: StringHandler? { get set }
    var onError: StringHandler? { get set }
    var shouldDrawWorkingAreas: (([WorkingArea]) -> Void)? { get set }
    var shouldDrawMarkers: (([MarkerDescription]) -> Void)? { get set }
    var shouldMoveCamera: (([WorkingArea]) -> Void)? { get set }

    func startObservingLocation()
    func loadCities()
    func configure(for coordinate: CLLocationCoordinate2D, zoom: Int)
    func loadInfo(about workingArea: WorkingArea)
    func selectMarker(_ marker: MarkerDescription)
}

private struct Constants {
    static var clusterizationDictionary: [Int: Int] { return [3: 300000, 4: 80000, 5: 60000, 6: 30000, 7: 15000, 8: 8000] }
    static var maxZoom: Int { return 11 }
    static var minZoom: Int { return 3 }
    static var minZoomDistance: Int { return 500000 }
}

final class MapViewModelImpl: BaseViewModel, MapViewModel {
    private let mapManager: MapManager
    private let networkManager: NetworkManager
    private lazy var cityMarker = [City: MarkerDescription]()
    private lazy var cityWorkingArea = [City: [WorkingArea]]()
    private lazy var prevZoom = 0
    
    var selectedCity: City?
    var onLocationChange: CLLocationCompletion?
    var onError: StringHandler?
    var shouldDrawWorkingAreas: (([WorkingArea]) -> Void)?
    var shouldDrawMarkers: (([MarkerDescription]) -> Void)?
    var shouldMoveCamera: (([WorkingArea]) -> Void)?
    var shouldUpdateCityInfo: StringHandler?
    var currentLocation: CLLocation? {
        return self.mapManager.currentLocation
    }
    
    init(mapManager: MapManager, networkManager: NetworkManager, selectedCity: City?) {
        self.mapManager = mapManager
        self.networkManager = networkManager
        self.selectedCity = selectedCity
    }
    
    func startObservingLocation() {
        self.mapManager.startObservingLocation(onChange: { [weak self] in
            if self?.selectedCity != nil { return }
            self?.onLocationChange?($0)
        })
    }
    
    func loadCities() {
        let onFinishLoad = { [weak self] in
            guard let self = self else { return }
            self.calculateWorkingAreas { [weak self] in
                self?.calculateCityCoordinates()
            }
        }
        
        if self.mapManager.cities.isEmpty {
            self.mapManager.getFilledCountries { [weak self] result in
                guard let self = self else { return }
                self.onError.apply(result.error?.localizedDescription)
                onFinishLoad()
            }
        } else {
            onFinishLoad()
        }
    }
    
    func configure(for coordinate: CLLocationCoordinate2D, zoom: Int) {
        DispatchQueue.global().sync { [weak self] in
            if let markers = self?.getMarkerDescriptions(for: zoom) {
                DispatchQueue.main.async {
                    self?.shouldDrawMarkers?(markers)
                }
            }
        }
    }
    
    func selectMarker(_ marker: MarkerDescription) {
        let cityMarker = self.cityMarker
        let cityWorkingArea = self.cityWorkingArea
        
        DispatchQueue.global().async {
            guard let city = cityMarker.first(where: { $0.value == marker })?.key else { return }
            guard let areas = cityWorkingArea[city] else { return }
            DispatchQueue.main.async { [weak self] in
                self?.shouldMoveCamera?(areas)
            }
        }
    }
    
    func getMarkerDescriptions(for zoom: Int) -> [MarkerDescription]? {
        let allMarkers = Array(self.cityMarker.values)

        guard self.prevZoom != zoom, !allMarkers.isEmpty else { return nil }
        self.prevZoom = zoom
        
        if zoom >= Constants.maxZoom { return [] }
        
        var arr = [MarkerDescription]()
        var processedIndeces = Set<Int>([])
        
        guard let zoneRadius = zoom < Constants.minZoom ? Constants.minZoomDistance : Constants.clusterizationDictionary[zoom] else { return allMarkers }
        
        for (index, marker) in allMarkers.enumerated() {
            guard !processedIndeces.contains(index) else { continue }
            
            let coordinate = marker.coordinate
            var temporaryGrouped = [MarkerDescription]()
            temporaryGrouped.append(marker)
            
            for (innerIndex, innerMarker) in allMarkers.enumerated() {
                guard !processedIndeces.contains(index) else { continue }
                guard innerIndex != index else { continue }
                let innerCoordinate = innerMarker.coordinate
                let distance = Int(coordinate.distance(from: innerCoordinate))
                if distance < zoneRadius {
                    temporaryGrouped.append(innerMarker)
                    processedIndeces.insert(innerIndex)
                }
            }
            
            processedIndeces.insert(index)
            
            if temporaryGrouped.count == 1 {
                temporaryGrouped.first.map {
                    arr.append($0)
                }
                
                continue
            }
            
            let title = Strings.cities(count: temporaryGrouped.count)
            let newCoordinate = temporaryGrouped
                .map { $0.coordinate }
                .findHeuristicCenter()
            
            if let unwrappedCoordinate = newCoordinate {
                arr.append(MarkerDescription(coordinate: unwrappedCoordinate, title: title, description: ""))
            }
        }
        
        return arr
    }
    
    func loadInfo(about workingArea: WorkingArea) {
        guard
            let city = self.cityWorkingArea.first (where: { (city, workingAreas) in
                workingAreas.contains(workingArea)
            })?.key,
            let code = city.code
            else {
                self.shouldUpdateCityInfo?("")
                return
        }
        
        if let info = city.info {
            self.shouldUpdateCityInfo?(info.description)
            return
        }
        
        self.networkManager.getCityInfo(code) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let cityInfo):
                city.info = cityInfo
                self.shouldUpdateCityInfo?(cityInfo.description)
            case .failure(let error):
                self.onError?(error.localizedDescription)
            }
        }
    }
}

// MARK: - Private
extension MapViewModelImpl {
    func calculateCityCoordinates() {
        let cityWorkingArea = self.cityWorkingArea
        var cityMarker = [City: MarkerDescription]()
        var markers = [MarkerDescription]()
        
        DispatchQueue.global().async { [weak self] in
            for (city, workingAreas) in cityWorkingArea {
                let coordinate = workingAreas
                    .map { $0.coordinates }
                    .flatMap(Functions.id)
                    .findHeuristicCenter()
                guard let unwrappedCoordinate = coordinate else { continue }
                let marker = MarkerDescription(coordinate: unwrappedCoordinate, title: city.name)
                cityMarker[city] = marker
                markers.append(marker)
                
                if city == self?.selectedCity {
                    DispatchQueue.main.async {
                        self?.onLocationChange?(CLLocation(latitude: unwrappedCoordinate.latitude, longitude: unwrappedCoordinate.longitude))
                    }
                }
            }
            
            DispatchQueue.main.async {
                self?.cityMarker = cityMarker
                self?.shouldDrawMarkers?(markers)
            }
        }
    }
    
    func calculateWorkingAreas(completion: Handler?) {
        let cities = self.mapManager.cities
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let decoder = PolylineDecoder()
            var workingAreas = [WorkingArea]()
            for city in cities {
                for area in city.workingArea {
                    if let coordinates = decoder.decodePolyline(area) {
                        let workingArea = WorkingArea(coordinates: coordinates)
                        self.cityWorkingArea[city, default: []].append(workingArea)
                        workingAreas.append(workingArea)
                    }
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.shouldDrawWorkingAreas?(workingAreas)
                completion?()
            }
        }
    }
}

