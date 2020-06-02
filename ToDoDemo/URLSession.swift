//
//  URLSession.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/15.
//  Copyright © 2020 Mars. All rights reserved.
//

import Foundation

extension URLSession: URLSessionProtocol {
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping DataTaskHandler)
        -> URLSessionDataTaskProtocol {
        return (dataTask(
            with: request,
            completionHandler: completionHandler)
            as URLSessionDataTask)
            as URLSessionDataTaskProtocol
    }
}
