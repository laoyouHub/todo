//
//  CLLocation.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/20.
//  Copyright © 2020 Mars. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocation {
    var toString: String {
        let latitude = String(format: "%.3f", coordinate.latitude)
        let longitude = String(format: "%.3f", coordinate.longitude)

        return "\(latitude), \(longitude)"
    }
}
