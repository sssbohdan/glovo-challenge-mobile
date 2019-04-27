//
//  Alerter.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/14/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import UIKit

final class Alerter {
    static func showError(_ error: String, title: String = "", from viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func showAlert(title: String, message: String, buttonTitles: [String], actions: [Handler?], styles: [UIAlertAction.Style] = [], from viewController: UIViewController) {
        let max = buttonTitles.count
        var actions = actions
        var styles = styles

        if actions.count < max {
            let diff = max - actions.count
            
            for _ in 0..<diff {
                actions.append({})
            }
        }
        
        if styles.count < max {
            let diff = max - styles.count
            
            for _ in 0..<diff {
                styles.append(.default)
            }
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        for ((title, action), style) in zip(zip(buttonTitles, actions), styles) {
            let alertAction = UIAlertAction(title: title, style: style, handler: { _ in action?() })
            alert.addAction(alertAction)
        }
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
