//
//  CurrentWeatherUITests.swift
//  ToDoUITests
//
//  Created by wangxiangbo on 2020/5/19.
//  Copyright © 2020 Mars. All rights reserved.
//

import XCTest

class CurrentWeatherUITests: XCTestCase {

    // 为了UI测试，我们要把App运行起来，因此，在测试用例中，我们必然需要一个表示正在执行的App的对象
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let json = """
        {
            "longitude" : 100,
            "latitude" : 52,
            "currently" : {
                "temperature" : 23,
                "humidity" : 0.91,
                "icon" : "snow",
                "time" : 1507180335,
                "summary" : "Light Snow"
            }
        }
        """
        app.launchEnvironment["FakeJSON"] = json
        app.launchArguments += ["UI-TESTING"]
        // 调用app.launch()方法启动Sky
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_location_button_exists() {
        // 通过app.button得到了App中所有的按钮
        // 通过["LocationBtn"]索引到了编辑位置的按钮，最后访问它的exists属性判断它是否存在
//        XCTAssert(app.buttons["LocationBtn"].exists)
        
        /*
            使用了expectation的第二种用法，让它针对locationBtn对象，设置一个期望条件，这个条件是通过NSPredicate表达的。
            由于我们要测试的目标是按钮存在，因此，在创建NSPredicate对象的时候，我们传递了exists == true。
            然后，同样是使用waitForExpectations设置一个满足期望的时间
         */
//        let locationBtn = app.buttons["LocationBtn"]
//        let exists = NSPredicate(format: "exists == true")
//
//        expectation(for: exists,
//            evaluatedWith: locationBtn,
//            handler: nil)
//        waitForExpectations(timeout: 5, handler:nil)
//
//        XCTAssert(locationBtn.exists)
        
        let locationBtn = app.buttons["LocationBtn"]
        XCTAssert(locationBtn.exists)
    }
    
    func test_currently_weather_display() {
        XCTAssert(app.images["snow"].exists)
        XCTAssert(app.staticTexts["Light Snow"].exists)
        // More tests here
    }

}

/*
    最后一种方法，就是借鉴我们在MockURLSession时候的思路，为UI测试再创建一套Mock出来的API，然后只要让这些API返回特定的数据就好了。为此，我们需要完成两个事情：
    Mock出来一套按照DarkSky规格返回数据的API；
    Sky中，网络请求的部分要对生产环境和测试环境的切换提供支持
 
    # 设置App的执行环境
    设置App执行参数和执行环境的方法，这是我们能够顺利执行UI测试的关键
    当我们创建了一个XCUIApplication对象之后，这个对象有两个属性，一个是launchArguments，它是一个[String]，通过它我们可以给程序添加自定义的执行参数
    app.launchArguments += ["UI-TESTING"]
 
    另外一个属性，是launchEnvironment，它是一个[String: String]，通过它我们可以给程序添加自定义的执行变量，例如：
    let json = """
    {
        "longitude" : 100,
        "latitude" : 52,
        "currently" : {
            "temperature" : 23,
            "humidity" : 0.91,
            "icon" : "snow",
            "time" : 1507180335,
            "summary" : "Light Snow"
        }
    }
    """
    app.launchEnvironment["FakeJSON"] = json
    这两个属性的设置，必须要在调用app.launch()方法之前
 */
