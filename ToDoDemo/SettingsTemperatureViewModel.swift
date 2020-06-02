//
//  SettingsTemperatureViewModel.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/20.
//  Copyright © 2020 Mars. All rights reserved.
//

import UIKit

struct SettingsTemperatureViewModel:SettingsRepresentable {
    let temperatureMode: TemperatureMode

    var labelText: String {
        return temperatureMode == .celsius ? "Celsius" : "Fahrenhait"
    }

    var accessory: UITableViewCell.AccessoryType {
        if UserDefaults.temperatureMode() == temperatureMode {
            return .checkmark
        }
        else {
            return .none
        }
    }
}
