//
//  ForecastData.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/19.
//  Copyright © 2020 Mars. All rights reserved.
//

import Foundation

struct ForecastData: Codable {
    let time: Date
    let temperatureLow: Double
    let temperatureHigh: Double
    let icon: String
    let humidity: Double
}
