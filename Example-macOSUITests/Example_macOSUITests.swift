//
//  Example_macOSUITests.swift
//  Example-macOSUITests
//
//  Created by Camden Webster on 6/26/24.
//  Copyright © 2024 Sergey Komarov. All rights reserved.
//

import XCTest

class Example_macOSUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOnePlusOneIsTwoOnMac() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        let window = app.windows.firstMatch
        app.launch()
        window.textFields["first"].click()
        window.textFields["first"].typeText("1")
        window.textFields["second"].click()
        window.textFields["second"].typeText("3")
        XCTAssertEqual(window.staticTexts["sum"].value as! String, "2", "1+1 did not equal 2")
    }
}
