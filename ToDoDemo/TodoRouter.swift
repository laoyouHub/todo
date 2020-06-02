//
//  TodoRouter.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/15.
//  Copyright © 2020 Mars. All rights reserved.
//

import Foundation
import Alamofire

enum TodoRouter {
    static let baseURL: String =
            "https://jsonplaceholder.typicode.com/"
        /// 这里只定义了一个case get，它有一个Int?类型的关联值，为nil时，表示要获取所有todo的列表；为Int时，表示要获取某一个具体的todo信息
        case get(Int?)
        /// TODO: Add other HTTP methods here
        /// Such as case post([[String: Any]])
}


extension TodoRouter: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        
        var method: HTTPMethod {
            switch self {
            case .get:
                return .get
            /// TODO: Add other HTTP methods here
            }
        }
        
        var params: [String: Any]? {
            switch self {
            case .get:
                return nil
            /// TODO: Add other HTTP methods here
            }
        }
        
        var url: URL {
            var relativeUrl: String = "todos"

            switch self {
            case .get(let todoId):
                if todoId != nil {
                    relativeUrl = "todos/\(todoId!)"
                }
            /// TODO: Add other HTTP methods here
            }

            let url = URL(string: TodoRouter.baseURL)!
                .appendingPathComponent(relativeUrl)

            return url
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
//        request.headers = [String:String]
        let encoding = JSONEncoding.default

        return try encoding.encode(request, with: params)
        
    }
}
