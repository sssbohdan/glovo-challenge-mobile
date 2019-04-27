//
//  DataLoader.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

enum LoadingError: Swift.Error {
    case unknown
}

protocol DataLoader {
    @discardableResult
    func loadData(urlRequest: RequestConvertible, completion: @escaping (Result<Data>) -> Void) -> Cancelable
}

final class DataLoaderImpl: DataLoader {
    private let urlSession: URLSession
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    @discardableResult
    func loadData(urlRequest: RequestConvertible, completion: @escaping (Result<Data>) -> Void) -> Cancelable {
        let dataTask = urlSession.dataTask(with: urlRequest.request()) { (data, response, error) in
            if let error = error {
                completion(Result.failure(error))
            } else if let data = data {
                completion(Result.success(data))
            } else {
                completion(Result.failure(LoadingError.unknown))
            }
        }
        
        dataTask.resume()
        
        return dataTask
    }
}

protocol Cancelable {
    func cancel()
}

extension URLSessionTask: Cancelable { }
