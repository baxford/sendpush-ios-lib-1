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

class PushSendAPITests: BaseTest {
    
    var pushSendAPI: PushSendAPI!
    var endpoint: String!
    let token = "DeviceToken"
    let username = "push_username"
    let message = "push message"
    let tags = ["tag":"value"]
    let metadata = ["meta":"value"]
    
    override func setUp() {
        let rh = SendPushRESTHandler(apiUrl: apiURL, platformID: platformID, platformSecret: platformSecret)
        self.pushSendAPI = PushSendAPI(restHandler: rh)
        self.endpoint = "\(apiURL)/messages/users/\(username)"
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: PushSendAPI Tests
    
    func testSendPushSuccess() {
        let expectation = expectationWithDescription("wait for send push API Call")
        stub(http(.POST,uri: endpoint), builder: http(200))
        
        
        self.pushSendAPI.sendPushToUsername(username, pushMessage: message, tags: tags, metadata:metadata, onSuccess: expectSuccess(expectation, expectedStatus: 200), onFailure: dontExpectFailure(expectation))
        self.waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "PushSendAPI Error")
        }
    }
    
    func testSendPushFailure() {
        let expectation = expectationWithDescription("wait for send push API Call")
        stub(http(.POST,uri: endpoint), builder: http(500))
        
        
        self.pushSendAPI.sendPushToUsername(username, pushMessage: message, tags: tags, metadata:metadata, onSuccess: dontExpectSuccess(expectation), onFailure: expectFailure(expectation, expectedStatus: 500))
        self.waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "PushSendAPI Error")
        }
    }
    
    func testSendPushHTTPFailure() {
        let expectation = expectationWithDescription("wait for send push API Call")
        stub(http(.POST,uri: endpoint), builder: failure(NSError(domain:"Sendpush",code:1000, userInfo:["error":"true"])))
        
        
        self.pushSendAPI.sendPushToUsername(username, pushMessage: message, tags: tags, metadata:metadata, onSuccess: dontExpectSuccess(expectation), onFailure: expectFailure(expectation, expectedStatus: 503))
        self.waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "PushSendAPI Error")
        }
    }
    
    
}
