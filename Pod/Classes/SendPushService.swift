//
//  RegistrationService.swift
//  Pods
//
//  Created by Bob Axford on 11/12/2015.
//
//

/**
* This class also implements SendPushDelegate as the main SendPush singleton delegates all calls to this class
*/
import UIKit
class SendPushService: SendPushDelegate {
    
    let config: SendPushConfig
    let sessionService: SessionServiceDelegate
    let registrationAPI: RegistrationAPIDelegate
    let pushSendAPI: PushSendAPIDelegate
    let pushNotificationDelegate: PushRegistrationDelegate
    let sendPushData: SendPushDataDelegate
    
    /*
    ** init
    ** This function initializes the SendPush library
    */
    convenience init(pushNotificationDelegate: PushRegistrationDelegate, prefix: String) {

        let config = SendPushConfig(prefix: prefix)
        let sendPushData = SendPushData()
        // setup our dependencies
        let restHandler = SendPushRESTHandler(apiUrl: config.apiUrl, platformID: config.platformID, platformSecret: config.platformSecret)
        let sessionService = SessionService(restHandler: restHandler, sendPushData: sendPushData)
        let registrationAPI = RegistrationAPI(restHandler: restHandler)
        let pushSendAPI = PushSendAPI(restHandler: restHandler)

        self.init(config: config, pushNotificationDelegate: pushNotificationDelegate, sessionService: sessionService,
            registrationAPI: registrationAPI, pushSendAPI: pushSendAPI, sendPushData: sendPushData)
    }
    
    /*
    * Designated initialiser. This can be used in test cases and inject mock dependencies
    */
    init (config: SendPushConfig, pushNotificationDelegate: PushRegistrationDelegate, sessionService: SessionServiceDelegate, registrationAPI: RegistrationAPIDelegate,
        pushSendAPI: PushSendAPIDelegate, sendPushData: SendPushDataDelegate) {
        self.config = config
        self.pushNotificationDelegate = pushNotificationDelegate
        self.sessionService = sessionService
        self.registrationAPI = registrationAPI
        self.pushSendAPI = pushSendAPI
        self.sendPushData = sendPushData
            
        // listen to app activate/inactivate
        NSNotificationCenter.defaultCenter().addObserver(self,selector: "applicationBecameActive:",
            name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: "applicationBecameInactive:",
            name: UIApplicationWillResignActiveNotification, object: nil)
            
    }
    
    @objc func applicationBecameActive(notification: NSNotification) {
        // if they've said ok to push, re-request push so we refresh the token
        if let _ = sendPushData.optedInPushDeviceToken() {
            self.requestPush()
        }
        self.sessionService.startHeartbeat()
    }
    
    @objc func applicationBecameInactive(notification: NSNotification) {
        self.sessionService.stopHeartbeat()
    }
    
    func restartSession() {
        self.sessionService.restartSession()
    }
    
    
    /*
    * Requeset push notifications from user
    */
    func requestPush() {
        if (!config.valid) {
            NSLog("Sendpush not configured properly, ignoring requestPush")
            return
        }
        self.pushNotificationDelegate.registerForRemoteNotifications()
        let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        self.pushNotificationDelegate.registerUserNotificationSettings(settings)
    }
    
    /*
    * Called by the owning app when a user has accepted push notifications.
    */
    func registerDevice(deviceToken: NSData!) {
        if (!config.valid) {
            NSLog("Sendpush not configured properly, ignoring registerDevice")
            return
        }
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for var i = 0; i < deviceToken.length; i++ {
            let char = tokenChars[i]
            tokenString += String(format: "%02.2hhx", arguments: [char])
        }
        var previousDeviceToken: String?
        if let previousToken = self.sendPushData.optedInPushDeviceToken() {
            if previousToken != tokenString {
                previousDeviceToken = previousToken
            }
        }

        self.sendPushData.setDeviceToken(tokenString)
        let device = self.sendPushData.getDevice()
        let users = self.sendPushData.getUsers()
        let registration = Registration(
            device: device,
            users: users,
            previousDeviceToken: previousDeviceToken
        )
        
        func successHandler(statusCode: Int, data: NSData?) {

        }
        func failureHandler(statusCode: Int, message: String) {
            NSLog("Error in registerDevice, status: \(statusCode), message: \(message)")
        }

        
        self.registrationAPI.register(registration, onSuccess: successHandler,  onFailure: failureHandler)
    }
    
    
    /*
    * Set the current usernames
    */
    func setCurrentUsers(users: [User]) {
        if (!config.valid) {
            NSLog("Sendpush not configured properly, ignoring registerUser")
            return
        }
        sendPushData.setUsers(users)
        // we can only register the user(s) once we have their device token, so let's check
        if let token = sendPushData.optedInPushDeviceToken() {

            func successHandler(statusCode: Int, data: NSData?) {
                
            }
            func failureHandler(statusCode: Int, message: String) {
                NSLog("Error in registerUser, status: \(statusCode), message: \(message)")
            }
            let device = self.sendPushData.getDevice()
            let registration = Registration(
                device: device,
                users: users,
                previousDeviceToken: nil
            )

            self.registrationAPI.register(registration, onSuccess: successHandler,  onFailure: failureHandler)
        }
    }
    
    /*
    * This is called as soon as the username is available (eg at Login)
    */
//    func registerUser(username: String, tags: [String: String]?, allowMutipleUsersPerDevice: Bool=false) {
//        if (!config.valid) {
//            NSLog("Sendpush not configured properly, ignoring registerUser")
//            return
//        }
//        let prefs = NSUserDefaults.standardUserDefaults()
//        prefs.setValue(username, forKey: SendPushConstants.USERNAME)
//        prefs.setValue(tags, forKey: SendPushConstants.USER_TAGS)
//        if let token = prefs.stringForKey(SendPushConstants.DEVICE_TOKEN) {
//            // we can only register this user once we have their device token, so let's check
//            func successHandler(statusCode: Int, data: NSData?) {
//                prefs.setValue(true, forKey: SendPushConstants.USER_REGISTERED)
//            }
//            func failureHandler(statusCode: Int, message: String) {
//                NSLog("Error in registerUser, status: \(statusCode), message: \(message)")
//                prefs.setValue(false, forKey: SendPushConstants.USER_REGISTERED)
//            }
//            self.userAPI.registerUser(username, deviceToken: token, allowMutipleUsersPerDevice: allowMutipleUsersPerDevice,
//                tags: tags, onSuccess: successHandler,  onFailure: failureHandler)
//        }
//        
//    }
//    
//    func unregisterUser(username: String) {
//        if (!config.valid) {
//            NSLog("Sendpush not configured properly, ignoring unregisterUser")
//            return
//        }
//        let prefs = NSUserDefaults.standardUserDefaults()
//        
//        func successHandler(statusCode: Int, data: NSData?) {
//            prefs.removeObjectForKey(SendPushConstants.USERNAME)
//            prefs.removeObjectForKey(SendPushConstants.USER_REGISTERED)
//            prefs.removeObjectForKey(SendPushConstants.USER_TAGS)
//        }
//        func failureHandler(statusCode: Int, message: String) {
//            NSLog("Error in unRegisterUser, status: \(statusCode), message: \(message)")
//        }
//        if let deviceToken = prefs.stringForKey(SendPushConstants.DEVICE_TOKEN) as String? {
//            self.userAPI.unregisterUser(username, deviceToken: deviceToken, onSuccess: successHandler, onFailure: failureHandler)
//        }
//    }
    
    func sendPushToUsername(username: String, pushMessage: String, tags: [String:String], metadata: [String:String]) {
        if (!config.valid) {
            NSLog("Sendpush not configured properly, ignoring sendPushToUsername")
            return
        }
        let prefs = NSUserDefaults.standardUserDefaults()
        func successHandler(statusCode: Int, data: NSData?) {
            NSLog("Successful sendPushToUsername")
        }
        func failureHandler(statusCode: Int, message: String) {
            NSLog("Error in sendPushToUsername, status: \(statusCode), message: \(message)")
        }
        self.pushSendAPI.sendPushToUsername(username, pushMessage: pushMessage, tags: tags, metadata: metadata, onSuccess: successHandler, onFailure: failureHandler)
    }
}
