//
//  Strings.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/20/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import Foundation

struct Strings {
    static var chooseCityButton: String { return "Choose city manually".localized }
    static var provideLocationButton: String { return "Provide location".localized }
    
    static var selectCityErrorMessage: String { return "Please, select city".localized }
    static var save: String { return "Save".localized }
    static var chooseCityTitle: String { return "Choose City".localized }
    
    static var cancel: String { return "Cancel".localized }
    static var openSettings: String { return "Open Settings".localized }
    static var appNeedsLocation: String { return "App needs location to provide you a better user experience.".localized }
    
    static func cities(count: Int) -> String { return "%@ cities".localized(arguments: "\(count)") }
}
