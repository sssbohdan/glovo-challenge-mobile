//
//  Country.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/13/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import Foundation

final class Country: Decodable {
    enum CodingKeys: String, CodingKey {
        case code,
        name
    }
    
    var code: String?
    var name: String?
    lazy var cities = [City]()
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decodeIfPresent(String.self, forKey: CodingKeys.code)
        self.name = try container.decodeIfPresent(String.self, forKey: CodingKeys.name)
    }
}
