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

class DeviceAPITests: BaseTest {

    var deviceAPI: DeviceAPI!
    var endpoint: String!
    let token = "DeviceToken"
    
    override func setUp() {
        let rh = SendPushRESTHandler(apiUrl: apiURL, platformID: platformID, platformSecret: platformSecret)
        self.deviceAPI = DeviceAPI(restHandler: rh)
        self.endpoint = "\(apiURL)/app/devices"
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: DeviceAPI Tests
    
    func testRegisterDeviceSuccess() {
        let expectation = expectationWithDescription("wait for register device API Call")
        stub(http(.POST,uri: endpoint), builder: http(200))
        
        
        self.deviceAPI.registerDevice(token, onSuccess: expectSuccess(expectation, expectedStatus: 200), onFailure: dontExpectFailure(expectation))
        self.waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "DeviceAPI Error")
        }
    }
    
    func testRegisterDeviceFailure() {
        let expectation = expectationWithDescription("wait for register device API Call")
        stub(http(.POST,uri: endpoint), builder: http(500))
        
        
        self.deviceAPI.registerDevice(token, onSuccess: dontExpectSuccess(expectation), onFailure: expectFailure(expectation, expectedStatus: 500))
        self.waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "DeviceAPI Error")
        }
    }
    
    func testRegisterDeviceHTTPFailure() {
        let expectation = expectationWithDescription("wait for register device API Call")
        stub(http(.POST,uri: endpoint), builder: failure(NSError(domain:"Sendpush",code:1000, userInfo:["error":"true"])))
        
        
        self.deviceAPI.registerDevice(token, onSuccess: dontExpectSuccess(expectation), onFailure: expectFailure(expectation, expectedStatus: 503))
        self.waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "DeviceAPI Error")
        }
    }
    
    
}
