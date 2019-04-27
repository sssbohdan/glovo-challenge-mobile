//
//  CityInfo.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/13/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import Foundation

final class CityInfo: Decodable {
    enum CodingKeys: String, CodingKey {
        case code,
        name,
        currency,
        countryCode = "country_code",
        isEnabled = "enabled",
        timeZone = "time_zone",
        workingArea = "working_area",
        isBusy = "busy",
        languageCode = "language_code"
    }
    
    var code: String?
    var name: String?
    var currency: String?
    var countryCode: String?
    var isEnabled = false
    var timeZone: String?
    var workingArea = [String]()
    var isBusy = false
    var languageCode: String?
    
    weak var city: City?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decodeIfPresent(String.self, forKey: CodingKeys.code)
        self.name = try container.decodeIfPresent(String.self, forKey: CodingKeys.name)
        self.currency = try container.decodeIfPresent(String.self, forKey: CodingKeys.currency)
        self.countryCode = try container.decodeIfPresent(String.self, forKey: CodingKeys.countryCode)
        self.isEnabled = try container.decodeIfPresent(Bool.self, forKey: CodingKeys.isEnabled) ?? false
        self.timeZone = try container.decodeIfPresent(String.self, forKey: CodingKeys.timeZone)
        self.workingArea = try container.decodeIfPresent([String].self, forKey: CodingKeys.workingArea) ?? []
        self.isBusy = try container.decodeIfPresent(Bool.self, forKey: CodingKeys.isBusy) ?? false
        self.languageCode = try container.decodeIfPresent(String.self, forKey: CodingKeys.languageCode)
    }
}

// MARK: - CustomStringConvertible
extension CityInfo: CustomStringConvertible {
    var description: String {
        var description = ""
        self.city?.country?.name.map { description += "Country: " + $0 + "\n" }
        self.name.map { description += "Name: " + $0 + "\n" }
        self.currency.map { description += "Currency: " + $0 + "\n" }
        self.timeZone.map { description += "Time zone: " + $0 + "\n" }
        self.languageCode.map { description += "Language code: " + $0 + "\n" }
        
        description += "Enabled: " + isEnabled.yesOrNoString
        
        return description
    }
}
