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
    let registrationAPI = MockRegistrationAPI()
    let pushSendAPI = MockPushSendAPI()
    let sessionService = MockSessionService()

    let deviceTokenString = "1111222233334444555566667777888899990000aaaabbbbccccddddeeeeffff"
    var device: Device!
    
    let sendPushData = MockSendPushData()
    var service: SendPushService!

    
    var users: [User] = []
    var deviceToken: NSMutableData?
    

    override func setUp() {
        super.setUp()
        
        let user1 = User(username: "user1", tags: ["tag1": "value1"])
        let user2 = User(username: "user2", tags: ["tag2": "value2"])
        self.users = [user1, user2]
        
        self.device = Device(
            token: deviceTokenString,
            uid:"uid",
            platform: "ios",
            type: "type",
            model: "model",
            timezone: "GMT",
            language: "en"
        )
        
        registrationAPI.reset();
        sendPushData.reset(device)
        service = SendPushService(config: config, pushNotificationDelegate: pushRegistrationDelegate,sessionService: sessionService, registrationAPI: registrationAPI,
            pushSendAPI: pushSendAPI, sendPushData: sendPushData)
        
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
    
    func testRegisterDeviceBeforeUsers() {
        // call our register function
        service.registerDevice(deviceToken)
        
        // ensure that the API is called with just the device
        XCTAssertEqual(registrationAPI.registration?.device.token!, device.token)
        // as there is no user set yet, the users should be nil
//        XCTAssertNil(registrationAPI.registration?.users!)
        
        // ensure it's saved properly
        if let savedToken = sendPushData.optedInPushDeviceToken() {
            XCTAssertEqual(savedToken, deviceTokenString)
        } else {
            XCTFail("Expected saved device token")
        }
        
    }
    
    func testRegisterDeviceAfterUser() {
        sendPushData.setUsers(users)

        // call our register function
        service.registerDevice(deviceToken)
        
        // ensure that the API is called
        XCTAssertEqual(registrationAPI.registration?.device.token, device.token)
        
        // as there is a user set , the userAPI should have been called
//        XCTAssertEqual(registrationAPI.registration!.users!, users)

        // ensure it's saved properly
        if let savedToken = sendPushData.optedInPushDeviceToken() {
            XCTAssertEqual(savedToken, deviceTokenString)
        } else {
            XCTFail("Expected saved device token")
        }
        
    }
    
    
    func testRegisterUsersBeforeDevice() {
        
        // call our register function
        service.setCurrentUsers(users)
        
        // ensure that no API is called as we need both deviceToken and username to register the user with API
        XCTAssertNil(registrationAPI.registration)

        
        // ensure it's saved properly

    }
    
    
    func testRegisterUsersAfterDevice() {
        sendPushData.setDeviceToken(deviceTokenString)
        
        // call our register function
        service.setCurrentUsers(users)
        
        // ensure that no API is called as we need both deviceToken and username to register the user with API
        XCTAssertEqual(registrationAPI.registration!.users!, users)
        XCTAssertEqual(registrationAPI.registration!.device.token, deviceTokenString)
        
        
        // ensure it's saved properly
        let savedUsers = sendPushData.getUsers()!
//        XCTAssertEqual(savedUsers, users)
    }
    
    
}
