//
//  CityInfoView.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/14/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import UIKit
import SnapKit

final class CityInfoView: UIView {
    private lazy var textView = UITextView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.configure()
    }
    
    func configure(text: String) {
        self.textView.text = text
    }
}

// MARK: - Private
private extension CityInfoView {
    func configure() {
        self.addSubview(self.textView)
        self.textView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        self.textView.backgroundColor = .white
        self.textView.textColor = Style.Color.textColor
        self.textView.isEditable = false
    }
}
