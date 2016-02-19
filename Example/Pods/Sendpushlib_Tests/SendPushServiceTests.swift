//
//  SendPushServiceTests.swift
//  Pods
//
//  Created by Bob Axford on 14/12/2015.
//
//

import XCTest

class SendPushServiceTests: BaseTest {
    
    let prefs = NSUserDefaults.standardUserDefaults()
    let config = SendPushConfig(apiUrl:"APIURL", platformID: "PlatformID", platformSecret: "secret", valid: true);
    let pushRegistrationDelegate = MockPushRegistrationDelegate()
    let userAPI = MockUserAPI()
    let deviceAPI = MockDeviceAPI()
    let pushSendAPI = MockPushSendAPI()
    let sessionService = MockSessionService()
    let sendPushData = SendPushData(platformID: "pid")
    var service: SendPushService!
    let deviceTokenString = "1111222233334444555566667777888899990000aaaabbbbccccddddeeeeffff"
    let username = "username"
    let userTags = ["": ""]
    var deviceToken: NSMutableData?
    
    override func setUp() {
        super.setUp()
        
        userAPI.reset();
        deviceAPI.reset();
        
        prefs.removeObjectForKey(SendPushConstants.USER_REGISTERED)
        prefs.removeObjectForKey(SendPushConstants.USERNAME)
        prefs.removeObjectForKey(SendPushConstants.USER_TAGS)
        prefs.removeObjectForKey(SendPushConstants.DEVICE_TOKEN)
        
        service = SendPushService(config: config, pushNotificationDelegate: pushRegistrationDelegate,sessionService: sessionService, userAPI: userAPI, deviceAPI: deviceAPI, pushSendAPI: pushSendAPI, sendPushData: sendPushData)
        
        // make it look like the NSData we get for a device Token
        deviceToken = NSMutableData(capacity: deviceTokenString.characters.count / 2)
        for var index = deviceTokenString.startIndex; index < deviceTokenString.endIndex; index = index.successor().successor() {
            let byteString = deviceTokenString.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))
            let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
            deviceToken?.appendBytes([num] as [UInt8], length: 1)
        }

        
        
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
    
    func testRegisterDeviceBeforeUser() {
        // call our register function
        service.registerDevice(deviceToken)
        
        // ensure that the API is called
        XCTAssertEqual(deviceAPI.deviceToken, deviceTokenString)
        
        // as there is no user set yet, the userAPI shouldn't have been called
        XCTAssertNil(userAPI.username)
        XCTAssertNil(userAPI.deviceToken)
        
        // ensure it's saved properly
        let prefs = NSUserDefaults.standardUserDefaults()
        if let savedToken = prefs.stringForKey(SendPushConstants.DEVICE_TOKEN) {
            XCTAssertEqual(savedToken, deviceTokenString)
        } else {
            XCTFail("Expected saved device token")
        }
        
    }
    
    func testRegisterDeviceAfterUser() {

        prefs.setValue(false, forKey: SendPushConstants.USER_REGISTERED)
        prefs.setValue(username, forKey: SendPushConstants.USERNAME)
        prefs.setValue(userTags, forKey: SendPushConstants.USER_TAGS)

        // call our register function
        service.registerDevice(deviceToken)
        
        // ensure that the API is called
        XCTAssertEqual(deviceAPI.deviceToken, deviceTokenString)
        
        // as there is a user set , the userAPI should have been called
        XCTAssertEqual(userAPI.username, username)
        XCTAssertEqual(userAPI.deviceToken, deviceTokenString)
        
        // ensure it's saved properly
        if let savedToken = prefs.stringForKey(SendPushConstants.DEVICE_TOKEN) {
            XCTAssertEqual(savedToken, deviceTokenString)
        } else {
            XCTFail("Expected saved device token")
        }
        
    }
    
    
    func testRegisterUserBeforeDevice() {
        
        // call our register function
        service.registerUser(username, tags: userTags)
        
        // ensure that no API is called as we need both deviceToken and username to register the user with API
        XCTAssertNil(userAPI.username)
        XCTAssertNil(userAPI.deviceToken)

        
        // ensure it's saved properly
        if let savedUsername = prefs.stringForKey(SendPushConstants.USERNAME) {
            XCTAssertEqual(savedUsername, username)
        } else {
            XCTFail("Expected saved device token")
        }
        // ensure the registered flag is not yet set
        let registered = prefs.boolForKey(SendPushConstants.USER_REGISTERED)
        XCTAssertEqual(registered, false)
    }
    
    
    func testRegisterUserAfterDevice() {
        prefs.setValue(deviceTokenString, forKey: SendPushConstants.DEVICE_TOKEN)
        
        // call our register function
        service.registerUser(username, tags: userTags)
        
        // ensure that no API is called as we need both deviceToken and username to register the user with API
        XCTAssertEqual(userAPI.username, username)
        XCTAssertEqual(userAPI.deviceToken, deviceTokenString)
        
        
        // ensure it's saved properly
        if let savedUsername = prefs.stringForKey(SendPushConstants.USERNAME), savedUserTags = prefs.objectForKey(SendPushConstants.USER_TAGS) as! [String:String]? {
            XCTAssertEqual(savedUsername, username)
            XCTAssertEqual(savedUserTags, userTags)
        } else {
            XCTFail("Expected saved device token")
        }
        // ensure the registered flag is now set
        let registered = prefs.boolForKey(SendPushConstants.USER_REGISTERED)
        XCTAssertEqual(registered, true)

    }
    
    
    func testUnregisterUser() {
        prefs.setValue(true, forKey: SendPushConstants.USER_REGISTERED)
        prefs.setValue(username, forKey: SendPushConstants.USERNAME)
        prefs.setValue(userTags, forKey: SendPushConstants.USER_TAGS)
        prefs.setValue(deviceTokenString, forKey: SendPushConstants.DEVICE_TOKEN)
        
        // call our register function
        service.unregisterUser(username)
        
        // ensure that the API is called
        XCTAssertTrue(userAPI.unregisterCalled)

        // ensure it's cleared properly
        if let _ = prefs.stringForKey(SendPushConstants.USERNAME){
            XCTFail("Expected no saved username")
        }
        if let _ = prefs.objectForKey(SendPushConstants.USER_TAGS){
            XCTFail("Expected no saved tags")
        }
        // ensure the registered flag is not set
        let registered = prefs.boolForKey(SendPushConstants.USER_REGISTERED)
        XCTAssertEqual(registered, false)
        
        // token should remain set
        if let savedToken = prefs.stringForKey(SendPushConstants.DEVICE_TOKEN) {
            XCTAssertEqual(savedToken, deviceTokenString)
        } else {
            XCTFail("Expected saved device token")
        }
    }
}
