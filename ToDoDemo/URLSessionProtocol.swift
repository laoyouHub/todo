//
//  URLSessionProtocol.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/15.
//  Copyright © 2020 Mars. All rights reserved.
//

import Foundation
/*
    在URLSessionProtocol中，我们定义了一个和URLSession.dataTask签名相同的方法
 */
typealias DataTaskHandler =
(Data?, URLResponse?, Error?) -> Void

protocol URLSessionProtocol {

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping DataTaskHandler)
        -> URLSessionDataTaskProtocol
}
