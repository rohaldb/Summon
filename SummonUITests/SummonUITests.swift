//
//  SummonUITests.swift
//  SummonUITests
//
//  Created by Benjamin Rohald on 10/4/20.
//  Copyright © 2020 Benjamin Rohald. All rights reserved.
//

import XCTest

class SummonUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStatusBarButtonIsInstantiated() {
        let app = XCUIApplication()
        app.launch()
        
        let statusBarElement = app.statusItems.element(matching: NSPredicate(format: "title = 'SummonButton'"))
        XCTAssert(statusBarElement.exists)
    }
}
