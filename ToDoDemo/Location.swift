//
//  Location.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/15.
//  Copyright © 2020 Mars. All rights reserved.
//

import Foundation
import CoreLocation

struct Location :Equatable{
    var name: String
    var latitude: Double
    var longitude: Double
    
    static let empty = Location(
    name: "",
    latitude: 0,
    longitude: 0)
    
    static let invalid =
    Location(name: "n/a", latitude: 0, longitude: 0)
    
    private struct Keys {
        static let name = "name"
        static let latitude = "latitude"
        static let longitude = "longitude"
    }
    
    init(name: String, latitude: Double, longitude: Double) {
            self.name = name
            self.latitude = latitude
            self.longitude = longitude
    }

    init?(from dictionary: [String: Any]) {
        guard let name = dictionary[Keys.name]
            as? String else { return nil }
        guard let latitude = dictionary[Keys.latitude]
            as? Double else { return nil }
        guard let longitude = dictionary[Keys.longitude]
            as? Double else { return nil }

        self.init(name: name, latitude: latitude, longitude: longitude)
    }
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    var toDictionary: [String: Any] {
        return [
            "name": name,
            "latitude": latitude,
            "longitude": longitude
        ]
    }
}
