//
//  Root.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/13/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import Foundation
import Dip

final class Root {
    static let shared = Root()
    private init() {
        self.register()
    }
    
    var container = DependencyContainer()
    
    func register() {
        self.container.register(.singleton) { NetworkManagerImpl(dataLoader: DataLoaderImpl(urlSession: URLSession(configuration: .default))) as NetworkManager }
        self.container.register(.singleton) { MapManagerImpl(networkingManager: self.resolve()) as MapManager}
        
        self.container.register { selectedCity in MapViewModelImpl(mapManager: self.resolve(), networkManager: self.resolve(), selectedCity: selectedCity) }
        self.container.register { HomeViewModelImpl(mapManager: self.resolve()) }
        self.container.register { CitiesViewModelImpl(mapManager: self.resolve()) }
    }
    
    func resolve<T>() -> T {
        return try! self.container.resolve()
    }
    
    func resolveRuntime<T, Z>(arg1: Z) -> T {
        return try! self.container.resolve(arguments: arg1)
    }
    
    func resolveRuntime<T, Z, H>(arg1: Z, arg2: H) -> T {
        return try! self.container.resolve(arguments: arg1, arg2)
    }
    
    func resolveRuntime<T, Z, H, G>(arg1: Z, arg2: H, arg3: G) -> T {
        return try! self.container.resolve(arguments: arg1, arg2, arg3)
    }
}
