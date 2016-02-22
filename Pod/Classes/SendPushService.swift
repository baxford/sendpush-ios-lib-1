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
    let userAPI: UserAPIDelegate
    let deviceAPI: DeviceAPIDelegate
    let pushSendAPI: PushSendAPIDelegate
    let pushNotificationDelegate: PushRegistrationDelegate
    let sendPushData: SendPushDataDelegate
    
    /*
    ** init
    ** This function initializes the SendPush library
    */
    convenience init(pushNotificationDelegate: PushRegistrationDelegate, prefix: String) {
        
        let config = SendPushConfig(prefix: prefix, allowMutipleUsersPerDevice: true)
        let sendPushData = SendPushData()
        // setup our dependencies
        let restHandler = SendPushRESTHandler(apiUrl: config.apiUrl, platformID: config.platformID, platformSecret: config.platformSecret)
        let sessionService = SessionService(restHandler: restHandler, sendPushData: sendPushData,debug: config.debug)
        let userAPI = UserAPI(restHandler: restHandler)
        let deviceAPI = DeviceAPI(restHandler: restHandler)
        let pushSendAPI = PushSendAPI(restHandler: restHandler)
        self.init(config: config, pushNotificationDelegate: pushNotificationDelegate, sessionService: sessionService, userAPI: userAPI, deviceAPI: deviceAPI, pushSendAPI: pushSendAPI, sendPushData: sendPushData)
    }
    
    /*
    * Designated initialiser. This can be used in test cases and inject mock dependencies
    */
    init (config: SendPushConfig, pushNotificationDelegate: PushRegistrationDelegate, sessionService: SessionServiceDelegate, userAPI: UserAPIDelegate, deviceAPI: DeviceAPIDelegate, pushSendAPI: PushSendAPIDelegate, sendPushData: SendPushDataDelegate) {
        self.config = config
        self.pushNotificationDelegate = pushNotificationDelegate
        self.sessionService = sessionService
        self.userAPI = userAPI
        self.deviceAPI = deviceAPI
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
        
        func successHandler(statusCode: Int, data: NSData?) {
            var refreshUsers = false
            if let previousDeviceToken = sendPushData.optedInPushDeviceToken() {
                if tokenString != previousDeviceToken {
                    refreshUsers = true
                }
            }
            sendPushData.setDeviceToken(tokenString)
            // now if the user isn't registered, we need to do it now
            let userData = sendPushData.getUsernamesAndTags()
            //if multiple users are in there, we need to register them all
            if (refreshUsers) {
                for (username, userTags) in userData {
                    registerUser(username as! String, tags: userTags as? [String:String])
                }
            }
    
        }
        func failureHandler(statusCode: Int, message: String) {
            NSLog("Error in registerDevice, status: \(statusCode), message: \(message)")
        }
        self.deviceAPI.registerDevice(tokenString, onSuccess: successHandler,  onFailure: failureHandler)
        
    }
    
    
    /*
    * This is called as soon as the username is available (eg at Login)
    */
    func registerUser(username: String, tags: [String: String]?) {
        if (!config.valid) {
            NSLog("Sendpush not configured properly, ignoring registerUser")
            return
        }
        // store this user details, we may not be able to register them straight away.
        sendPushData.addUser(username, tags:tags, allowMutipleUsersPerDevice: config.allowMutipleUsersPerDevice)
        // we can only register this user once we have their device token, so let's check
        if let token = sendPushData.optedInPushDeviceToken() {
            
            func successHandler(statusCode: Int, data: NSData?) {
                // we can now flag that they're registered
                sendPushData.setUserRegistered(username)
            }
            func failureHandler(statusCode: Int, message: String) {
                NSLog("Error in registerUser, status: \(statusCode), message: \(message)")
            }
            self.userAPI.registerUser(username, deviceToken: token, allowMutipleUsersPerDevice: config.allowMutipleUsersPerDevice,
                tags: tags, onSuccess: successHandler,  onFailure: failureHandler)
        }
        
    }
    
    func unregisterUser(username: String) {
        if (!config.valid) {
            NSLog("Sendpush not configured properly, ignoring unregisterUser")
            return
        }
        
        func successHandler(statusCode: Int, data: NSData?) {
            sendPushData.unregisterUser(username)
        }
        func failureHandler(statusCode: Int, message: String) {
            NSLog("Error in unRegisterUser, status: \(statusCode), message: \(message)")
        }
        if let deviceToken = sendPushData.optedInPushDeviceToken() {
            self.userAPI.unregisterUser(username, deviceToken: deviceToken, onSuccess: successHandler, onFailure: failureHandler)
        }
    }
    
    func sendPushToUsername(username: String, pushMessage: String, tags: [String:String], metadata: [String:String]) {
        if (!config.valid) {
            NSLog("Sendpush not configured properly, ignoring sendPushToUsername")
            return
        }
                func successHandler(statusCode: Int, data: NSData?) {
            if (config.debug) {
                NSLog("Successful sendPushToUsername")
            }
        }
        func failureHandler(statusCode: Int, message: String) {
            NSLog("Error in sendPushToUsername, status: \(statusCode), message: \(message)")
        }
        self.pushSendAPI.sendPushToUsername(username, pushMessage: pushMessage, tags: tags, metadata: metadata, onSuccess: successHandler, onFailure: failureHandler)
    }
}
