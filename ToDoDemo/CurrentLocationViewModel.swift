//
//  CurrentLocationViewModel.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/21.
//  Copyright © 2020 Mars. All rights reserved.
//

import Foundation

struct CurrentLocationViewModel {
    var location: Location

    var city: String {
        return location.name
    }

    static let empty = CurrentLocationViewModel(
        location: Location.empty)

    static let invalid =
        CurrentLocationViewModel(location: .invalid)

    var isInvalid: Bool {
        return self.location == Location.invalid
    }
    
    var isEmpty: Bool {
        return self.location == Location.empty
    }
}

/*
    一方面，我们希望Controllers可以感知到View Models中值的变化，并自动设置UI；
    另一方面，我们还需要根据外部的操作更新View Models中的值；
 */
