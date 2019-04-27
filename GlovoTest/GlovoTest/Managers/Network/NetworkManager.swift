//
//  NetworkManager.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/10/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

protocol NetworkManager {
    @discardableResult
    func getCountries(completion: ((Result<[Country]>) -> Void)?) -> Cancelable
    
    @discardableResult
    func getCities(completion: ((Result<[City]>) -> Void)?) -> Cancelable
    
    @discardableResult
    func getCityInfo(_ cityCode: String, completion: ((Result<CityInfo>) -> Void)?) -> Cancelable
}

extension NetworkManager {
    func showNetworkIndicator(_ value: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = value
    }
}

final class NetworkManagerImpl: NetworkManager {
    private let dataLoader: DataLoader
    private let decoder = JSONDecoder()
    
    init(dataLoader: DataLoader) {
        self.dataLoader = dataLoader
    }
    
    @discardableResult
    func getCountries(completion: ((Result<[Country]>) -> Void)?) -> Cancelable {
        let request = GetCountriesRequest()
        let cancelable = dataLoader.loadData(urlRequest: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let value):
                do {
                    let countries = try self.decoder.decode([Country].self, from: value)
                    completion?(.success(countries))
                } catch let error {
                    completion?(.failure(error))
                }
            case .failure(let error):
                completion?(.failure(error))
            }
        }
        
        return cancelable
    }
    
    @discardableResult
    func getCities(completion: ((Result<[City]>) -> Void)?) -> Cancelable {
        let request = GetCitiesRequest()
        let cancelable = dataLoader.loadData(urlRequest: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let value):
                do {
                    let countries = try self.decoder.decode([City].self, from: value)
                    completion?(.success(countries))
                } catch let error {
                    completion?(.failure(error))
                }
            case .failure(let error):
                completion?(.failure(error))
            }
        }
        
        return cancelable
    }
    
    @discardableResult
    func getCityInfo(_ cityCode: String, completion: ((Result<CityInfo>) -> Void)?) -> Cancelable {
        let request = GetCityInfoRequest(cityCode: cityCode)
        let cancelable = dataLoader.loadData(urlRequest: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let value):
                do {
                    let countries = try self.decoder.decode(CityInfo.self, from: value)
                    DispatchQueue.main.async {
                        completion?(.success(countries))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion?(.failure(error))
                }
            }
        }
        
        return cancelable
    }
}
