//
//  MapViewControllerViewController.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/13/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import UIKit
import GoogleMaps
import SnapKit

private struct Constants {
    static var flagSize: CGSize { return CGSize(width: 30, height: 30) }
    static var flagImageName: String { return "flag" }
    static var flagFilled: String { return "flag_filled" }
    static var cityInfoViewHeight: CGFloat { return 88 }
    static var changePositionThrottle: Int { return 200 }
    static var initialZoom: Float { return 7.0 }
}

final class MapViewController<T: MapViewModel>: ViewController<T>, GMSMapViewDelegate {
    private lazy var flagImageView = UIImageView()
    private lazy var cityInfoView = CityInfoView()
    private lazy var mapView: GMSMapView = {
        let camera = GMSCameraPosition()
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.delegate = self
        return mapView
    }()
    private lazy var changePositionDebounceFunction = debounce1(delay: DispatchTimeInterval.milliseconds(Constants.changePositionThrottle), action: { [weak self] position in
        self?.updateData(for: position)
    })
    
    private lazy var polygons = [WorkingArea: GMSPolygon]()
    private lazy var markers = [MarkerDescription: GMSMarker]()
    private lazy var previousMarkerDescription = Set<MarkerDescription>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.configureBinding()
        self.viewModel.loadCities()
    }
    
    override func performOnceInViewWillAppear() {
        if self.viewModel.selectedCity == nil {
            self.viewModel.startObservingLocation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - GMSMapViewDelegate
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let markerDescription = self.markers.first(where: { $0.value == marker })?.key else {
            return true
        }
        
        self.mapView.selectedMarker = marker
        self.viewModel.selectMarker(markerDescription)
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let zoom = Int(position.zoom)
        let coordinate = position.target
        self.viewModel.configure(for: coordinate, zoom: zoom)
        self.changePositionDebounceFunction(position)
    }
}

// MARK: - Private
private extension MapViewController {
    func configureUI() {
        [self.mapView, self.flagImageView, self.cityInfoView].forEach(self.view.addSubview)
        
        self.mapView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        self.flagImageView.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.centerX.equalToSuperview().offset(Constants.flagSize.width / 2)
            maker.size.equalTo(Constants.flagSize)
        }
        
        self.cityInfoView.snp.makeConstraints { maker in
            maker.bottom.equalTo(self.view.safeOrBottom).offset(-Style.Offset.default)
            maker.left.equalTo(Style.Offset.default)
            maker.right.equalTo(-Style.Offset.default)
            maker.height.equalTo(Constants.cityInfoViewHeight)
        }
        
        self.flagImageView.contentMode = .scaleAspectFit
        self.flagImageView.image = UIImage(named: Constants.flagImageName)
        self.cityInfoView.roundCorner(radius: Style.Corner.default)
    }
    
    func configureBinding() {
        self.viewModel.shouldUpdateCityInfo = { [weak self] info in
            self?.cityInfoView.configure(text: info)
        }
        
        self.viewModel.shouldDrawWorkingAreas = { [weak self] workingAreas in
            guard let self = self else { return }
            for area in workingAreas {
                let polygon = self.addPolygon(for: area)
                self.polygons[area] = polygon
            }
        }
        
        self.viewModel.shouldDrawMarkers = { [weak self] markersDescriptios in
            guard let self = self else { return }
            DispatchQueue.global().async {
                let markersDescriptios = Set(markersDescriptios)
                let remove = self.previousMarkerDescription.subtracting(markersDescriptios)
                let add = markersDescriptios.subtracting(self.previousMarkerDescription)
                DispatchQueue.main.async {
                    remove.forEach {
                        self.markers[$0]?.map = nil
                        self.markers[$0] = nil
                    }
                    
                    add.forEach {
                        let marker = self.addMarker(with: $0.coordinate, title: $0.title, snippet: $0.description)
                        self.markers[$0] = marker
                    }
                    
                    self.previousMarkerDescription = markersDescriptios
                }
            }
        }
        
        self.viewModel.onLocationChange = { [weak self] location in
            let coordinate = location.coordinate
            let cameraPosition = GMSCameraPosition(target: coordinate, zoom: Constants.initialZoom)
            self?.mapView.animate(to: cameraPosition)
        }
        
        self.viewModel.shouldMoveCamera = { [weak self] areas in
            var bounds = GMSCoordinateBounds()
            let coordinates = areas.flatMap { $0.coordinates }
            for coordinate in coordinates {
                bounds = bounds.includingCoordinate(coordinate)
            }
            let update = GMSCameraUpdate.fit(bounds, withPadding: 0)
            self?.mapView.animate(with: update)

        }
    }
    
    @discardableResult func addPolygon(for area: WorkingArea) -> GMSPolygon {
        let path = GMSMutablePath()
        area.coordinates.forEach(path.add(_:))
        let polygon = GMSPolygon(path: path)
        polygon.fillColor = Style.Color.workingArea
        polygon.map = self.mapView
        
        return polygon
    }
    
    @discardableResult func addMarker(with coordinate: CLLocationCoordinate2D, title: String?, snippet: String?) -> GMSMarker {
        let marker = GMSMarker()
        marker.position = coordinate
        marker.title = title
        marker.snippet = snippet
        marker.map = self.mapView
        
        return marker
    }
    
    func updateData(for position: GMSCameraPosition) {
        guard !self.polygons.isEmpty else { return }
        let coordinate = position.target
        var centerPolygon: GMSPolygon?
        
        for (area, polygon) in self.polygons {
            if polygon.contains(coordinate: coordinate) {
                centerPolygon = polygon
                self.viewModel.loadInfo(about: area)
                break
            }
        }
        
        if centerPolygon != nil {
            self.flagImageView.image = UIImage(named: Constants.flagFilled)
            
        } else {
            self.flagImageView.image = UIImage(named: Constants.flagImageName)
            self.cityInfoView.configure(text: "")
        }
    }
}
