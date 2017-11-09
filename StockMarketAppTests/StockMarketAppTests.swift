//
//  StockMarketAppTests.swift
//  StockMarketAppTests
//
//  Created by Douglas Voss on 11/12/16.
//  Copyright © 2016 VossWareLLC. All rights reserved.
//

import XCTest
@testable import StockMarketApp

class StockMarketAppTests: XCTestCase {
    
    var lookupViewController: LookupViewController!
//    var quoteViewController: QuoteViewController!
//    var chartViewController: ChartViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        lookupViewController = LookupViewController()
//        quoteViewController = QuoteViewController()
//        chartViewController = ChartViewController()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        lookupViewController = nil
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
       
        print("starting testExample")
        let promise = expectation(description: "Test Lookup API Call")
        lookupViewController.doLookup(searchText: "LLL") { (alert: (title: String, message: String)?) in
            if let alert = alert {
                XCTFail("Got alert error back from callback \(alert.title):\(alert.message)");
            }
            XCTAssert(true) // test passed
            print("gonna fulfill promise")
            promise.fulfill()
            print("fulfilled promise")
        }
        
        waitForExpectations(timeout: 10.0) { (error: Error?) in
            print("expection callback happened")
            if let error = error {
                XCTFail("\(promise) Timed out with error \(error)")
            }
        }
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
}
