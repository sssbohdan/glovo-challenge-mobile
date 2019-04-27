//
//  ModuleCreator.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/13/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import UIKit

final class ViewControllerCreator {
    static func createMap(selectedCity: City?) -> MapViewController<MapViewModelImpl> {
        let vc = MapViewController<MapViewModelImpl>.init(viewModel: Root.shared.resolveRuntime(arg1: selectedCity))
        return vc
    }
    
    static func createHome() -> HomeViewController<HomeViewModelImpl> {
        let vc = HomeViewController<HomeViewModelImpl>.init(viewModel: Root.shared.resolve())
        return vc
    }
    
    static func createCities() -> CitiesViewController<CitiesViewModelImpl> {
        let vc = CitiesViewController<CitiesViewModelImpl>.init(viewModel: Root.shared.resolve())
        return vc
    }
}
