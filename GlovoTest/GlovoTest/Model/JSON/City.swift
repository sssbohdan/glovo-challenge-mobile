//
//  Сшен.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/13/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import Foundation

final class City: Decodable {
    enum CodingKeys: String, CodingKey {
        case workingArea = "working_area",
        code,
        name,
        countryCode = "country_code"
    }
    
    let code: String?
    let name: String?
    let countryCode: String?
    var workingArea = [String]()
    var info: CityInfo?

    weak var country: Country?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.workingArea = try container.decodeIfPresent([String].self, forKey: CodingKeys.workingArea) ?? []
        self.code = try container.decodeIfPresent(String.self, forKey: CodingKeys.code)
        self.name = try container.decodeIfPresent(String.self, forKey: CodingKeys.name)
        self.countryCode = try container.decodeIfPresent(String.self, forKey: CodingKeys.countryCode)
    }
}

extension City: Hashable {
    public static func == (lhs: City, rhs: City) -> Bool {
        return lhs.code == rhs.code
    }
    
    var hashValue: Int {
        return code.orEmpty.hashValue
    }
}

