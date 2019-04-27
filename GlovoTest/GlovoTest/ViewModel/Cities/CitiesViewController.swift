//
//  CitiesViewController.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/14/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static var rowHeight: CGFloat { return 50 }
    static var sectionHeight: CGFloat { return 30 }
}

final class CitiesViewController<T: CitiesViewModel>: ViewController<T>,
    UITableViewDelegate,
    UITableViewDataSource
{
    private lazy var tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.getCountries()
        self.configureUI()
        self.configureBinding()
        self.configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc func refresh() {
        self.viewModel.getCountries()
    }
    
    @objc func save() {
        self.viewModel.save()
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.countries.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.countries[section].cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(type: CityTableViewCell.self, indexPath: indexPath)
        let city = self.viewModel.countries[indexPath.section].cities[indexPath.row]
        cell.update(cityName: city.name, isSelected: self.viewModel.selectedCity === city)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let country = self.viewModel.countries[section]
        return country.cities.isEmpty ? 0 : Constants.sectionHeight
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let country = self.viewModel.countries[section]
        return country.name
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = self.viewModel.countries[indexPath.section].cities[indexPath.row]
        self.viewModel.selectCity(city)
        self.tableView.reloadData()
    }
}

// MARK: - Private
private extension CitiesViewController {
    func configureUI() {
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        self.title = Strings.chooseCityTitle
        self.configureSaveBarButton()
    }
    
    func configureSaveBarButton() {
        let saveBarButton = UIBarButtonItem(title: Strings.save, style: .done, target: self, action: #selector(save))
        self.navigationItem.setRightBarButton(saveBarButton, animated: true)
    }
    
    func configureTableView() {
        self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(self.refreshControl)
        self.tableView.setDelegateAndDataSource(self)
        self.tableView.register(CityTableViewCell.self)
    }
    
    func configureBinding() {
        self.viewModel.onError = { [weak self] error in
            guard let self = self else { return }
            
            Alerter.showError(error, from: self)
        }
        
        self.viewModel.onCountriesUpdate = { [weak self] in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
}
