//
//  SendPushServiceTests.swift
//  Pods
//
//  Created by Bob Axford on 14/12/2015.
//
//

import XCTest

class SendPushServiceTests: BaseTest {

    let config = SendPushConfig(apiUrl:"APIURL", platformID: "PlatformID", platformSecret: "secret", valid: true);
    let pushRegistrationDelegate = MockPushRegistrationDelegate()
    let userAPI = MockUserAPI()
    let deviceAPI = MockDeviceAPI()
    let pushSendAPI = MockPushSendAPI()
    let sessionService = MockSessionService()
    
    var service: SendPushService!
    
    override func setUp() {
        super.setUp()

        service = SendPushService(config: config, pushNotificationDelegate: pushRegistrationDelegate,sessionService: sessionService, userAPI: userAPI, deviceAPI: deviceAPI, pushSendAPI: pushSendAPI)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRegisterForPush() {
        service.requestPush()
        XCTAssertTrue(pushRegistrationDelegate.didRegister)
        let expected =  UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        XCTAssertEqual(pushRegistrationDelegate.notificationSettings, expected)
    }
    
    func testRegisterDevice() {
        let token = ("<abc123>" as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        service.registerDevice(token)
        let prefs = NSUserDefaults.standardUserDefaults()
        if let savedToken = prefs.stringForKey(SendPushConstants.DEVICE_TOKEN) {
            let expectedDeviceToken = NSString(data: token!, encoding: NSUTF8StringEncoding)

            XCTAssertEqual(savedToken, expectedDeviceToken)
        } else {
            XCTFail("Expected saved device token")
        }
        

    }


   
}
