//
//  WeekWeatherViewController.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/19.
//  Copyright © 2020 Mars. All rights reserved.
//

import UIKit

class WeekWeatherViewController: WeatherViewController {

    @IBOutlet weak var weekWeatherTableView: UITableView!
    
    var viewModel: WeekWeatherViewModel? {
        didSet {
            DispatchQueue.main.async { self.updateView() }
        }
    }

    func updateView() {
        activityIndicatorView.stopAnimating()

        if let _ = viewModel {
            updateWeatherDataContainer()

        } else {
            loadingFailedLabel.isHidden = false
            loadingFailedLabel.text = "Load Location/Weather failed!"
        }
    }
    
    func updateWeatherDataContainer() {
        weatherContainerView.isHidden = false
        weekWeatherTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

   

}

extension WeekWeatherViewController: UITableViewDataSource {
    func numberOfSections(
        in tableView: UITableView) -> Int {
        guard let viewModel = viewModel else { return 0 }
        return viewModel.numberOfSections
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        return viewModel.numberOfDays
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: WeekWeatherTableViewCell.reuseIdentifier,
                for: indexPath) as? WeekWeatherTableViewCell else {
            fatalError("Unexpected table view cell")
        }

        if let weatherDay = viewModel?.viewModel(
            for: indexPath.row) {
            cell.configure(with: weatherDay)
        }

        return cell
    }
    
    
    
    
}
