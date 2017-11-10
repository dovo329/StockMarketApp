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
        app.typeText("\r")
        
        // could first wait for spinner to appear then disappear to know when it's done loading
        sleep(1)
        
        let symbolLbl = app.staticTexts["LookupVC SymbolLbl 2"]
        let companyNameLbl = app.staticTexts["LookupVC CompanyNameLbl"]
        let exchangeLbl = app.staticTexts["LookupVC ExchangeLbl"]
        
        
        XCTAssert(symbolLbl.exists, "Couldn't find Symbol Label")
        XCTAssertEqual(symbolLbl.label, "Symbol: LLL", "Wrong value for Symbol")
        
        XCTAssert(companyNameLbl.exists, "Couldn't find Company Name Label")
        XCTAssertEqual(companyNameLbl.label, "Company Name: L3 Technologies Inc", "Wrong value for Symbol")
        
        XCTAssert(exchangeLbl.exists, "Couldn't find Exchange Label")
        XCTAssertEqual(exchangeLbl.label, "Exchange: NYSE")
    }
    
}
