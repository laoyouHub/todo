//
//  MockURLSession.swift
//  SkyTests
//
//  Created by wangxiangbo on 2020/5/15.
//  Copyright © 2020 Mars. All rights reserved.
//

import Foundation

@testable import ToDo

class MockURLSession: URLSessionProtocol {
    
    var responseData: Data?
    var responseHeader: HTTPURLResponse?
    var responseError: Error?
    
    var sessionDataTask = MockURLSessionDataTask()

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping DataTaskHandler)
        -> URLSessionDataTaskProtocol {
            completionHandler(responseData, responseHeader, responseError)
        return sessionDataTask
    }
}
