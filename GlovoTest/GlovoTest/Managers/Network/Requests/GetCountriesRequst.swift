//
//  FeedSearchRequst.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/10/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

struct GetCountriesRequest: RequestConvertible {
    var path: String {
        return "/api/countries/"
    }
}
