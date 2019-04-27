//
//  Result.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/13/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(Error)
    
    init(closure: () throws -> T) {
        do {
            self = .success(try closure())
        } catch {
            self = .failure(error)
        }
    }
    
    var value: T? {
        switch self {
        case .success(let value):
            return value
        default:
            return nil
        }
    }
    
    var error: Error? {
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
}
