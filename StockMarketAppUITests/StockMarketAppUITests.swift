//
//  StockMarketAppUITests.swift
//  StockMarketAppUITests
//
//  Created by Douglas Voss on 11/12/16.
//  Copyright © 2016 VossWareLLC. All rights reserved.
//

import XCTest

class StockMarketAppUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        let lookupSymbolOrCompanyNameSearchField = app.searchFields["Lookup Symbol or Company Name"]
        lookupSymbolOrCompanyNameSearchField.tap()
        lookupSymbolOrCompanyNameSearchField.typeText("LLL")
        
        let spinner = app.activityIndicators["In progress"]
        
//        if (spinner.exists) {
//            print("spinner shown")
//        } else {
//            print("spinner hidden")
//        }
        
        XCTAssert(!spinner.exists)
        app.typeText("\r")
        
        Thread.sleep(forTimeInterval: 0.5)
//        expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: spinner, handler: nil)
//        waitForExpectations(timeout: 5.0) { (error: Error?) in
//            if let error = error {
//                XCTFail("Error waiting for spinner to be shown \(error)")
//            }
//        }
        
        expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: spinner, handler: nil)
        waitForExpectations(timeout: 5.0) { (error: Error?) in
            if let error = error {
                XCTFail("Error waiting for spinner to be hidden \(error)")
            }
        }
        
        let symbolLbl = app.staticTexts["LookupVC SymbolLbl 2"]
        let companyNameLbl = app.staticTexts["LookupVC CompanyNameLbl"]
        let exchangeLbl = app.staticTexts["LookupVC ExchangeLbl"]
        
        XCTAssert(symbolLbl.exists, "Couldn't find Symbol Label")
        XCTAssertEqual(symbolLbl.value as! String, "Symbol: LLL", "Wrong value for Symbol")
        
        XCTAssert(companyNameLbl.exists, "Couldn't find Company Name Label")
        XCTAssertEqual(companyNameLbl.value as! String, "Company Name: L3 Technologies Inc", "Wrong value for Symbol")
        
        XCTAssert(exchangeLbl.exists, "Couldn't find Exchange Label")
        XCTAssertEqual(exchangeLbl.value as! String, "Exchange: NYSE")
    }
    
}
