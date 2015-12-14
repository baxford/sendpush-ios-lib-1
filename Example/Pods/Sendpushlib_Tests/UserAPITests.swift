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

class UserAPITests: BaseTest {
    
    var userAPI: UserAPI!

    let token = "DeviceToken"
    let username = "Some_user"
    let tags = ["tag":"value"]
    var endpoint : String!
    
    override func setUp() {
        let rh = SendPushRESTHandler(apiUrl: apiURL, platformID: platformID, platformSecret: platformSecret)
        self.userAPI = UserAPI(restHandler: rh)
        self.endpoint = "\(apiURL)/app/users/\(username)/\(token)"
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: Register User Tests
    
    func testRegisterUserSuccess() {
        let expectation = expectationWithDescription("wait for register user API Call")
        stub(http(.PUT,uri: endpoint), builder: http(200))
        
        
        self.userAPI.registerUser(username, deviceToken: token, tags:tags, onSuccess: expectSuccess(expectation, expectedStatus: 200), onFailure: dontExpectFailure(expectation))
        self.waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "userAPI Error")
        }
    }
    
    func testRegisterUserFailure() {
        let expectation = expectationWithDescription("wait for register user API Call")
        stub(http(.PUT,uri: endpoint), builder: http(500))
        
        
        self.userAPI.registerUser(username, deviceToken: token, tags:tags, onSuccess: dontExpectSuccess(expectation), onFailure: expectFailure(expectation, expectedStatus: 500))
        self.waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "userAPI Error")
        }
    }
    
    func testRegisterUserHTTPFailure() {
        let expectation = expectationWithDescription("wait for register user API Call")
        stub(http(.PUT,uri: endpoint), builder: failure(NSError(domain:"Sendpush",code:1000, userInfo:["error":"true"])))
        
        
        self.userAPI.registerUser(username, deviceToken: token, tags:tags, onSuccess: dontExpectSuccess(expectation), onFailure: expectFailure(expectation, expectedStatus: 503))
        self.waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "userAPI Error")
        }
    }
    
    // MARK: Unregister User Tests
    
    func testUnregisterUserSuccess() {
        let expectation = expectationWithDescription("wait for unregister user API Call")
        stub(http(.DELETE,uri: endpoint), builder: http(200))
        
        
        self.userAPI.unregisterUser(username, deviceToken: token, onSuccess: expectSuccess(expectation, expectedStatus: 200), onFailure: dontExpectFailure(expectation))
        self.waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "userAPI Error")
        }
    }
    
    func testUnregisterUserFailure() {
        let expectation = expectationWithDescription("wait for unregister user API Call")
        stub(http(.DELETE,uri: endpoint), builder: http(500))
        
        
        self.userAPI.unregisterUser(username, deviceToken: token, onSuccess: dontExpectSuccess(expectation), onFailure: expectFailure(expectation, expectedStatus: 500))
        self.waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "userAPI Error")
        }
    }
    
    func testUnregisterUserHTTPFailure() {
        let expectation = expectationWithDescription("wait for unregister user API Call")
        stub(http(.DELETE,uri: endpoint), builder: failure(NSError(domain:"Sendpush",code:1000, userInfo:["error":"true"])))
        
        
        self.userAPI.unregisterUser(username, deviceToken: token, onSuccess: dontExpectSuccess(expectation), onFailure: expectFailure(expectation, expectedStatus: 503))
        self.waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "userAPI Error")
        }
    }
    
}
