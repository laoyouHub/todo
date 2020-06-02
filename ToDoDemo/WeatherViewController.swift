//
//  WeatherViewController.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/15.
//  Copyright © 2020 Mars. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {

    @IBOutlet weak var weatherContainerView: UIView!
    @IBOutlet weak var loadingFailedLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }
    

    

}

//MARK:- 帮助方法
extension WeatherViewController {
    
    private func setupView() {
        weatherContainerView.isHidden = true

        loadingFailedLabel.isHidden = true

        activityIndicatorView.startAnimating()
        activityIndicatorView.hidesWhenStopped = true
    }
}
