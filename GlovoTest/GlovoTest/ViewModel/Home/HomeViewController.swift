//
//  HomeViewController.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/14/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import UIKit
import SnapKit

private struct Constant {
    static var buttonHorizontalOffset: CGFloat { return 32 }
    static var buttonHeight: CGFloat { return 45 }
    static var buttonVerrticalOffset: CGFloat { return 16 }
}

final class HomeViewController<T: HomeViewModel>: ViewController<T>,
    Settingable
{
    private lazy var grantPermissionButton = UIButton()
    private lazy var chooseCityButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.configureBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc func chooseCityTouchUpInside(sender: UIButton) {
        self.viewModel.chooseCity()
    }
    
    @objc func granPermissionTouchUpInsider(sender: UIButton) {
        self.viewModel.askPermission()
    }
}

// MARK: - Private
private extension HomeViewController {
    func configureUI() {
        [self.grantPermissionButton, self.chooseCityButton].forEach { button in
            self.view.addSubview(button)
            button.titleLabel?.font = Style.Font.default
            button.roundCorner(radius: Style.Corner.default)
            button.setTitleColor(.white, for: .normal)
            
            button.snp.makeConstraints { maker in
                maker.left.equalTo(Constant.buttonHorizontalOffset)
                maker.right.equalTo(-Constant.buttonHorizontalOffset)
                maker.height.equalTo(Constant.buttonHeight)
            }
        }
        
        self.chooseCityButton.snp.makeConstraints { maker in
            maker.bottom.equalTo(self.view.safeOrBottom).offset(-Constant.buttonVerrticalOffset)
        }
        
        self.grantPermissionButton.snp.makeConstraints { maker in
            maker.bottom.equalTo(self.chooseCityButton.snp.top).offset(-Constant.buttonVerrticalOffset)
        }
        
        self.grantPermissionButton.backgroundColor = Style.Color.richElecticBlueButton
        self.chooseCityButton.backgroundColor = Style.Color.marinerButton
        
        self.grantPermissionButton.setTitle(Strings.provideLocationButton, for: .normal)
        self.chooseCityButton.setTitle(Strings.chooseCityButton, for: .normal)
        
        self.chooseCityButton.addTarget(self, action: #selector(chooseCityTouchUpInside(sender:)), for: .touchUpInside)
        self.grantPermissionButton.addTarget(self, action: #selector(granPermissionTouchUpInsider(sender:)), for: .touchUpInside)
    }
    
    func configureBinding() {
        self.viewModel.shouldOpenSettings = { [weak self] in
            self?.askToOpenSettings(message: Strings.appNeedsLocation)
        }
    }
}
