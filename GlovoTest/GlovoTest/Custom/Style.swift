//
//  Style.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/21/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import UIKit

struct Style {
    struct Color {
        static var textColor: UIColor { return UIColor(red:0.15, green:0.15, blue:0.15, alpha:1.00) }
        
        static var richElecticBlueButton: UIColor { return UIColor(red:0.08, green:0.54, blue:0.79, alpha:1.00) }
        static var marinerButton: UIColor { return UIColor(red:0.18, green:0.38, blue:0.79, alpha:1.00) }
        
        static var workingArea: UIColor { return UIColor(red:0.18, green:0.38, blue:0.79, alpha:0.60) }
    }
    
    struct Corner {
        static var `default`: CGFloat { return 5 }
    }
    
    struct Offset {
        static var `default`: CGFloat { return 8 }
    }
    
    struct Font {
        static var `default`: UIFont { return .systemFont(ofSize: 14) }
    }
}
