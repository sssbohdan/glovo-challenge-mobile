//
//  RequestConvertible.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

protocol RequestConvertible {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var port: Int { get }
    
    func request() -> URLRequest
}

extension RequestConvertible {
    var scheme: String {
        return "http"
    }
    var host: String {
        return "localhost"
    }
    var path: String {
        return "api/"
    }
    
    var port: Int {
        return 3000
    }
    
    var components: URLComponents {
        var urlComponents = URLComponents()
        
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.port = port
        
        return urlComponents
    }
    
    func request() -> URLRequest {
        let url = components.url!
        return URLRequest(url: url)
    }
}
