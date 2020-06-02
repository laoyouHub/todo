//
//  WeatherDataManager.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/15.
//  Copyright © 2020 Mars. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxRelay

internal struct Config {
    private static func isUITesting() -> Bool {
        return ProcessInfo.processInfo.arguments.contains("UI-TESTING")
    }

    static var urlSession: URLSessionProtocol = {
        if isUITesting() {
            return DarkSkyURLSession()
        }
        else {
            return URLSession.shared
        }
    }()
}

internal class DarkSkyURLSession
    : URLSessionProtocol {
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping DataTaskHandler)
        -> URLSessionDataTaskProtocol {
            return DarkSkyURLSessionDataTask(
                request: request,
                completion: completionHandler)
    }
}

internal class DarkSkyURLSessionDataTask
    : URLSessionDataTaskProtocol {
    private let request: URLRequest
    private let completion: DataTaskHandler

    init(request: URLRequest, completion: @escaping DataTaskHandler) {
        self.request = request
        self.completion = completion
    }

    func resume() {
        /*
            首先，我们通过ProcessInfo.processInfo.environment加载了测试时使用的JSON，这就是访问进程环境变量的方法；
            其次，我们直接调用了completion方法，这样就在测试过程中把异步回调函数，变成了同步的；
         */
        
        // How to implement it?
        let json = ProcessInfo
            .processInfo
            .environment["FakeJSON"]

        if let json = json {
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil)
            let data = json.data(using: .utf8)!

            completion(data, response, nil)
        }
    }
}

enum DataManagerError: Error {
    case failedRequest
    case invalidResponse
    case unknown
}

final class WeatherDataManager {
    private let baseURL: URL
    internal let urlSession: URLSessionProtocol

    internal init(baseURL: URL, urlSession: URLSessionProtocol) {
        self.baseURL = baseURL
        self.urlSession = urlSession
    }

    static let shared =
        WeatherDataManager(baseURL: API.authenticatedUrl, urlSession: Config.urlSession)
    
    typealias CompletionHandler =
        (WeatherData?, DataManagerError?) -> Void

    func weatherDataAt(latitude: Double, longitude: Double)
        -> Observable<WeatherData> {
        let url = baseURL.appendingPathComponent(
            "\(latitude),\(longitude)")
        var request = URLRequest(url: url)

        request.setValue("application/json",
            forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        let MAX_ATTEMPTS = 4
        
        return (self.urlSession as! URLSession)
            .rx.data(request: request).map {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                return try decoder.decode(WeatherData.self, from: $0)
            }
            .retryWhen { (error) -> Observable<Int> in
                return error.enumerated().flatMap({ (attempt,error) -> Observable<Int> in
                    if (attempt >= MAX_ATTEMPTS) {
                        print("------------- \(attempt + 1) attempt -------------")
                        return Observable.error(error)
                    }
                    else {
                        // How can we implement the back-off retry strategy?
                        print("-------- \(attempt + 1) Retry --------")
                        return Observable<Int>.timer(DispatchTimeInterval.seconds(Int(Double(attempt + 1))),
                            scheduler: MainScheduler.instance)
                            .take(1)
                    }
                })
            }
            .materialize()
            .do(onNext: { print("==== Materialize: \($0) ====") })
            .dematerialize()
            .catchErrorJustReturn(WeatherData.invalid)
            
            
    }
}
