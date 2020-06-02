//
//  MockURLSessionDataTask.swift
//  SkyTests
//
//  Created by wangxiangbo on 2020/5/15.
//  Copyright © 2020 Mars. All rights reserved.
//

import Foundation

@testable import ToDo

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    private (set) var isResumeCalled = false

    func resume() {
        self.isResumeCalled = true
    }
}
