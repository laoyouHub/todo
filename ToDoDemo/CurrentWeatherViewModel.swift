//
//  CurrentWeatherViewModel.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/19.
//  Copyright © 2020 Mars. All rights reserved.
//

import UIKit

struct CurrentWeatherViewModel {
    
    static let empty = CurrentWeatherViewModel(
        weather: WeatherData.empty)

    static let invalid =
        CurrentWeatherViewModel(weather: .invalid)

    var isInvalid: Bool {
        return self.weather == WeatherData.invalid
    }
    
    var isEmpty: Bool {
        return self.weather == WeatherData.empty
    }
    
    var location: Location! {
        didSet {
            if location != nil {
                self.isLocationReady = true
            }
            else {
                self.isLocationReady = false
            }
        }
    }

    var weather: WeatherData! {
        didSet {
            if weather != nil {
                self.isWeatherReady = true
            }
            else {
                self.isWeatherReady = false
            }
        }
    }

    var isLocationReady = false
    var isWeatherReady = false

    var isUpdateReady: Bool {
        return isLocationReady && isWeatherReady
    }
    
    //MARK:- computed properties
    /*
        基本就是从Model直接取值，并格式化之后返回
     */
    
    
//    var city: String {
//        return location.name
//    }

    var temperature: String {
        
        let value = weather.currently.temperature

        switch UserDefaults.temperatureMode() {
        case .fahrenheit:
            return String(format: "%.1f °F", value)
        case .celsius:
            return String(format: "%.1f °C", value.toCelcius())
        }
    }

    var humidity: String {
        return String(
            format: "%.1f %%",
            weather.currently.humidity * 100)
    }

    var summary: String {
        return weather.currently.summary
    }

    var date: String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = UserDefaults.dateMode().format

        return formatter.string(from: weather.currently.time)
    }
    
    var weatherIcon: UIImage {
        return UIImage.weatherIcon(
            of: weather.currently.icon)!
    }
}

extension UIImage {
    class func weatherIcon(of name: String) -> UIImage? {
        switch name {
        case "clear-day":
            return UIImage(named: "clear-day")
        case "clear-night":
            return UIImage(named: "clear-night")
        case "rain":
            return UIImage(named: "rain")
        case "snow":
            return UIImage(named: "snow")
        case "sleet":
            return UIImage(named: "sleet")
        case "wind":
            return UIImage(named: "wind")
        case "cloudy":
            return UIImage(named: "cloudy")
        case "partly-cloudy-day":
            return UIImage(named: "partly-cloudy-day")
        case "partly-cloudy-night":
            return UIImage(named: "partly-cloudy-night")
        default:
            return UIImage(named: "clear-day")
        }
    }
}
