//
//  WeekWeatherViewModel.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/19.
//  Copyright © 2020 Mars. All rights reserved.
//

import UIKit

struct WeekWeatherViewModel {
    let weatherData: [ForecastData]
    
    
    var numberOfSections: Int {
        return 1
    }
    
    var numberOfDays: Int {
        return weatherData.count
    }
    
    func viewModel(for index: Int)
        -> WeekWeatherDayViewModel {
            return WeekWeatherDayViewModel(
                weatherData: weatherData[index])
    }
    
}
