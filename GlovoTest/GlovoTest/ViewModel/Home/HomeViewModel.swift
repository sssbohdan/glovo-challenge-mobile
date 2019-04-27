//
//  HomeViewController.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/14/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import Foundation

protocol HomeViewModel: ViewModel {
    func askPermission()
    func chooseCity()
    
    var shouldOpenSettings: Handler? { get set }
}

final class HomeViewModelImpl: BaseViewModel, HomeViewModel {
    private let mapManager: MapManager

    var shouldOpenSettings: Handler?
    
    init(mapManager: MapManager) {
        self.mapManager = mapManager
    }
    
    func askPermission() {
        mapManager.askPermission { [weak self] status in
            switch status {
            case .denied:
                self?.shouldOpenSettings?()
            case .authorizedWhenInUse, .authorizedAlways:
                self?.showMap()
                
            default:break
            }
        }
    }
    
    
    func showMap() {
        let vc = ViewControllerCreator.createMap(selectedCity: nil)
        self.shouldSet?([vc], true)
    }
    
    func chooseCity() {
        let vc = ViewControllerCreator.createCities()
        self.shouldPush?(vc, true)
    }
}
