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
    convenience init(pushNotificationDelegate: PushRegistrationDelegate, sendpushConfig: NSDictionary) {
        let config = SendPushConfig(sendpushConfig: sendpushConfig)
        // setup our dependencies
        let restHandler = SendPushRESTHandler(apiUrl: config.apiUrl, platformID: config.platformID, platformSecret: config.platformSecret)
        let sessionService = SessionService(restHandler: restHandler)
        let userAPI = UserAPI(restHandler: restHandler)
        let deviceAPI = DeviceAPI(restHandler: restHandler)
        let pushSendAPI = PushSendAPI(restHandler: restHandler)
        let sendPushData = SendPushData(platformID: config.platformID)
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
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setValue(tokenString, forKey: SendPushConstants.DEVICE_TOKEN)
            
            // now if the user isn't registered, we need to do it now
            if !prefs.boolForKey(SendPushConstants.USER_REGISTERED), let username = prefs.stringForKey(SendPushConstants.USERNAME) as String?, let userTags = prefs.dictionaryForKey(SendPushConstants.USER_TAGS) as? Dictionary<String, String> {
                registerUser(username, tags: userTags)
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
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(username, forKey: SendPushConstants.USERNAME)
        prefs.setValue(tags, forKey: SendPushConstants.USER_TAGS)
        if let token = prefs.stringForKey(SendPushConstants.DEVICE_TOKEN) {
            // we can only register this user once we have their device token, so let's check
            func successHandler(statusCode: Int, data: NSData?) {
                prefs.setValue(true, forKey: SendPushConstants.USER_REGISTERED)
            }
            func failureHandler(statusCode: Int, message: String) {
                NSLog("Error in registerUser, status: \(statusCode), message: \(message)")
                prefs.setValue(false, forKey: SendPushConstants.USER_REGISTERED)
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
        let prefs = NSUserDefaults.standardUserDefaults()
        
        func successHandler(statusCode: Int, data: NSData?) {
            prefs.removeObjectForKey(SendPushConstants.USERNAME)
            prefs.removeObjectForKey(SendPushConstants.USER_REGISTERED)
            prefs.removeObjectForKey(SendPushConstants.USER_TAGS)
        }
        func failureHandler(statusCode: Int, message: String) {
            NSLog("Error in unRegisterUser, status: \(statusCode), message: \(message)")
        }
        if let deviceToken = prefs.stringForKey(SendPushConstants.DEVICE_TOKEN) as String? {
            self.userAPI.unregisterUser(username, deviceToken: deviceToken, onSuccess: successHandler, onFailure: failureHandler)
        }
    }
    
    func sendPushToUsername(username: String, pushMessage: String, tags: [String:String]) {
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
        self.pushSendAPI.sendPushToUsername(username, pushMessage: pushMessage, tags: tags, onSuccess: successHandler, onFailure: failureHandler)
    }
}
