//
//  Settingable.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/20/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import UIKit

protocol Settingable: class {
    func askToOpenSettings(title: String, message: String)
}

extension Settingable where Self: UIViewController {
    func askToOpenSettings(title: String = "", message: String) {
        Alerter.showAlert(title: title, message: message, buttonTitles: [Strings.openSettings, Strings.cancel], actions: [{
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
            }, {
                
            }], from: self)
    }
}
