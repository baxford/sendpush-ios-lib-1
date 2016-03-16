//
//  Sendpushlib_Tests.swift
//  Sendpushlib_Tests
//
//  Created by Bob Axford on 11/12/2015.
//
//
import Foundation

import XCTest
import Quick
import Nimble
import Mockingjay
import Sendpushlib
import Foundation
import UIKit

class SessionAPITests: BaseTest {
    
    var sessionAPI: SessionAPI!
    var endpoint: String!
    let deviceUID = "deviceUID"

    
    override func setUp() {
        let rh = SendPushRESTHandler(apiUrl: apiURL, platformID: platformID, platformSecret: platformSecret)
        let sendPushData = SendPushData()
        self.sessionAPI = SessionAPI(restHandler: rh, sendPushData: sendPushData)
        self.endpoint = "\(apiURL)/app/session"
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: SessionAPI Tests
    
    func testStartSessionSuccess() {
        let expectation = expectationWithDescription("wait for sessionStart API Call")
        stub(http(.POST,uri: endpoint), builder: http(200))
        
        
        self.sessionAPI.startSession(expectSuccess(expectation, expectedStatus: 200), onFailure: dontExpectFailure(expectation))
        self.waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "SessionAPI Error")
        }
    }
    
    func testStartSessionFailure() {
        let expectation = expectationWithDescription("wait for sessionStart API Call")
        stub(http(.POST,uri: endpoint), builder: http(500))
        
        
        self.sessionAPI.startSession(dontExpectSuccess(expectation), onFailure: expectFailure(expectation, expectedStatus: 500))
        self.waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "SessionAPI Error")
        }
    }
    
    func testStartSessionHTTPFailure() {
        let expectation = expectationWithDescription("wait for sessionStart API Call")
        stub(http(.POST,uri: endpoint), builder: failure(NSError(domain:"Sendpush",code:1000, userInfo:["error":"true"])))
        
        
        self.sessionAPI.startSession(dontExpectSuccess(expectation), onFailure: expectFailure(expectation, expectedStatus: 503))
        self.waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "SessionAPI Error")
        }
    }
    
    func testEndSessionSuccess() {
        let expectation = expectationWithDescription("wait for sessionStart API Call")
        stub(http(.PUT,uri: endpoint), builder: http(200))
        
        
        self.sessionAPI.extendSession(expectSuccess(expectation, expectedStatus: 200), onFailure: dontExpectFailure(expectation))
        self.waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "SessionAPI Error")
        }
    }
    
    func testEndSessionFailure() {
        let expectation = expectationWithDescription("wait for sessionStart API Call")
        stub(http(.PUT,uri: endpoint), builder: http(500))
        
        
        self.sessionAPI.extendSession(dontExpectSuccess(expectation), onFailure: expectFailure(expectation, expectedStatus: 500))
        self.waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "SessionAPI Error")
        }
    }
    
    func testEndSessionHTTPFailure() {
        let expectation = expectationWithDescription("wait for sessionStart API Call")
        stub(http(.PUT,uri: endpoint), builder: failure(NSError(domain:"Sendpush",code:1000, userInfo:["error":"true"])))
        
        
        self.sessionAPI.extendSession(dontExpectSuccess(expectation), onFailure: expectFailure(expectation, expectedStatus: 503))
        self.waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "SessionAPI Error")
        }
    }
}
