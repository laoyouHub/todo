//
//  WeatherData.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/15.
//  Copyright © 2020 Mars. All rights reserved.
//

import Foundation

struct WeatherData: Codable {
    let latitude: Double
    let longitude: Double
    let currently: CurrentWeather
    let daily: WeekWeatherData
    
    static let empty = WeatherData(
        latitude: 0,
        longitude: 0,
        currently: CurrentWeather(
            time: Date.from(string: "1970-01-01"),
            summary: "",
            icon: "",
            temperature: 0,
            humidity: 0),
        daily: WeekWeatherData(data: []))
    
    static let invalid = WeatherData(
    latitude: 0,
    longitude: 0,
    currently: CurrentWeather(
        time: Date.from(string: "1970-01-01"),
        summary: "n/a", icon: "n/a",
        temperature: -274, humidity: -1),
    daily: WeekWeatherData(data: []))
    
    struct WeekWeatherData: Codable {
        let data: [ForecastData]
    }
    struct CurrentWeather: Codable {
        let time: Date
        let summary: String
        let icon: String
        let temperature: Double
        let humidity: Double
    }
}

extension WeatherData.CurrentWeather: Equatable {
    static func ==(
        lhs: WeatherData.CurrentWeather,
        rhs: WeatherData.CurrentWeather) -> Bool {
        return lhs.time == rhs.time &&
            lhs.summary == rhs.summary &&
            lhs.icon == rhs.icon &&
            lhs.temperature == rhs.temperature &&
            lhs.humidity == rhs.humidity
    }
}

extension WeatherData: Equatable {
    static func ==(lhs: WeatherData,
                   rhs: WeatherData) -> Bool {
        return lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude &&
            lhs.currently == rhs.currently &&
            lhs.daily == rhs.daily
    }
}

extension WeatherData.WeekWeatherData: Equatable {
    static func ==(
        lhs: WeatherData.WeekWeatherData,
        rhs: WeatherData.WeekWeatherData) -> Bool {
        return lhs.data == rhs.data
    }
}

extension ForecastData: Equatable {
    static func ==(
        lhs: ForecastData,
        rhs: ForecastData) -> Bool {
        return lhs.time == rhs.time &&
            lhs.temperatureLow == rhs.temperatureLow &&
            lhs.temperatureHigh == rhs.temperatureHigh &&
            lhs.icon == rhs.icon &&
            lhs.humidity == rhs.humidity
    }
}
