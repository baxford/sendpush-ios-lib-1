//
//  BaseTest.swift
//  Pods
//
//  Created by Bob Axford on 14/12/2015.
//
//

import XCTest

class BaseTest: XCTestCase {

    let apiURL: String = "http://dummyapi.sendpush.co"
    let platformID = "pid"
    let platformSecret = "secret"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    //MARK: Reusable methods for testing async calls
    func expectSuccess(expectation: XCTestExpectation?, expectedStatus: Int) -> (statusCode: Int, data: NSData?) -> Void {
        func successHandler(statusCode: Int, data: NSData?) {
            XCTAssertEqual(statusCode, expectedStatus)
            expectation?.fulfill()
        }
        return successHandler
    }
    
    func dontExpectSuccess(expectation: XCTestExpectation?) -> (statusCode: Int, data: NSData?) -> Void {
        func successHandler(statusCode: Int, data: NSData?) {
            XCTAssertFalse(statusCode >= 200 && statusCode < 300)
            expectation?.fulfill()
        }
        return successHandler
    }
    
    func expectFailure(expectation: XCTestExpectation?, expectedStatus: Int) -> (statusCode: Int, message: String) -> Void {
        func failureHandler(statusCode: Int, message: String) {
            XCTAssertEqual(statusCode, expectedStatus)
            expectation?.fulfill()
        }
        return failureHandler
    }
    
    func dontExpectFailure(expectation: XCTestExpectation?) -> (statusCode: Int, message: String) -> Void {
        func failureHandler(statusCode: Int, message: String) {
            XCTAssertTrue(statusCode >= 200 && statusCode < 300)
            expectation?.fulfill()
        }
        return failureHandler
    }
}
