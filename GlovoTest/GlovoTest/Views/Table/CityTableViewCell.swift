//
//  CityTableViewCell.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/14/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import UIKit

final class CityTableViewCell: UITableViewCell, NibReusable {
    @IBOutlet private weak var cityNameLabel: UILabel!
    @IBOutlet private weak var selectedImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func update(cityName: String?, isSelected: Bool) {
        self.cityNameLabel.text = cityName
        self.selectedImageView.isHidden = !isSelected
    }
}
