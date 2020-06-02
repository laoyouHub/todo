//
//  Configuratioin.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/15.
//  Copyright © 2020 Mars. All rights reserved.
//

import Foundation

struct API {
    static let key = "1d27751872b9e419ec66eb2b0ffb6ff9"
    static let baseUrl = URL(string: "https://api.darksky.net/forecast")!
    static let authenticatedUrl = baseUrl.appendingPathComponent(key)
}
