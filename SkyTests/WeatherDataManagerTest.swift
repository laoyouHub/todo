//
//  WeatherDataManagerTest.swift
//  SkyTests
//
//  Created by wangxiangbo on 2020/5/15.
//  Copyright © 2020 Mars. All rights reserved.
//

import XCTest
@testable import ToDo

class WeatherDataManagerTest: XCTestCase {
    /// 公共部分
    let url = URL(string: "https://darksky.net")!
    var session: MockURLSession!
    var manager: WeatherDataManager!
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // 可以把所有的测试前要准备的代码，写在setUp方法里
        self.session = MockURLSession()
        self.manager = WeatherDataManager(baseURL: url, urlSession: session)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        // 把测试后需要清理的代码，写在tearDown方法里
    }

    func test_weatherDataAt_starts_the_session() {
        let dataTask = MockURLSessionDataTask()
        session.sessionDataTask = dataTask

        manager.weatherDataAt(
            latitude: 52,
            longitude: 100,
            completion: { _, _ in  })
        
        XCTAssert(session.sessionDataTask.isResumeCalled)
    }

    func test_weatherDataAt_handle_invalid_request() {

        var error: DataManagerError? = nil
        manager.weatherDataAt(
            latitude: 52,
            longitude: 100,
            completion: {
            (_, e) in
            error = e
        })

        XCTAssertEqual(error, DataManagerError.failedRequest)
    }
    
    
    func test_weatherDataAt_handle_statuscode_not_equal_to_200() {
       
        let data = "{}".data(using: .utf8)!
        session.responseData = data
        var error: DataManagerError? = nil
        manager.weatherDataAt(
            latitude: 52,
            longitude: 100,
            completion: {
            (_, e) in
            error = e
        })

        XCTAssertEqual(error, DataManagerError.failedRequest)
    }
    
    func test_weatherDataAt_handle_invalid_response() {
        session.responseHeader = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)

        /// Make a invalid JSON response here
        let data = "{".data(using: .utf8)!
        session.responseData = data

        var error: DataManagerError? = nil
        let manager = WeatherDataManager(
            baseURL: url, urlSession: session)

        manager.weatherDataAt(
            latitude: 52,
            longitude: 100,
            completion: {
            (_, e) in
            error = e
        })

        XCTAssertEqual(error, DataManagerError.invalidResponse)
    }
    
    func test_weatherDataAt_handle_response_decode() {
            session.responseHeader = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)

        let data = """
        {
            ...
            "daily": {
                "data": [
                    {
                        "time": 1507180335,
                        "icon": "clear-day",
                        "temperatureLow": 66,
                        "temperatureHigh": 82,
                        "humidity": 0.25
                    }
                ]
            }
        }
        """.data(using: .utf8)!
        session.responseData = data

        var decoded: WeatherData? = nil
        manager.weatherDataAt(
            latitude: 52,
            longitude: 100,
            completion: {
                (d, _) in
                decoded = d
        })

       let expectedWeekData = WeatherData.WeekWeatherData(data: [
            ForecastData(
                time: Date(timeIntervalSince1970: 1507180335),
                temperatureLow: 66,
                temperatureHigh: 82,
                icon: "clear-day",
                humidity: 0.25)
            ])
        let expected = WeatherData(
            latitude: 52,
            longitude: 100,
            currently: WeatherData.CurrentWeather(
                time: Date(timeIntervalSince1970: 1507180335),
                summary: "Light Snow",
                icon: "snow",
                temperature: 23,
                humidity: 0.91),
            daily: expectedWeekData)

        XCTAssertEqual(decoded, expected)
    }
}
