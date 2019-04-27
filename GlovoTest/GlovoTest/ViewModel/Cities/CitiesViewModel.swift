//
//  CitiesViewModel.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/14/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import Foundation

protocol CitiesViewModel: ViewModel {
    var countries: [Country] { get }
    var selectedCity: City? { get }
    
    var onError: StringHandler? { get set }
    var onCountriesUpdate: Handler? { get set }

    func getCountries()
    func selectCity(_ city: City)
    func save()
}

final class CitiesViewModelImpl: BaseViewModel, CitiesViewModel {
    private let mapManager: MapManager
    
    var selectedCity: City?
    lazy var countries = [Country]()
    
    var onError: StringHandler?
    var onCountriesUpdate: Handler?

    
    init(mapManager: MapManager) {
        self.mapManager = mapManager
    }
    
    func getCountries() {
        self.mapManager.getFilledCountries { [weak self] result in
            guard let self = self else { return }
            self.onError.apply(result.error?.localizedDescription)
            self.countries = result.value ?? []
            self.onCountriesUpdate?()
        }
    }
    
    func selectCity(_ city: City) {
        self.selectedCity = city
    }
    
    func save() {
        guard let selectedCity = self.selectedCity else {
            self.onError?(Strings.selectCityErrorMessage)
            return
        }
        let vc = ViewControllerCreator.createMap(selectedCity: selectedCity)
        self.shouldSet?([vc], true)
    }
}
