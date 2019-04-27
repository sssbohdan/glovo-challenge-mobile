//
//  FeedRequest.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

struct GetCityInfoRequest: RequestConvertible {
    let cityCode: String
    
    var path: String {
        return "/api/cities/\(cityCode)"
    }
}
