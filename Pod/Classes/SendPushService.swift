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
    let sessionService: SessionService
    let userAPI: UserAPIDelegate
    let deviceAPI: DeviceAPIDelegate
    let pushSendAPI: PushSendAPIDelegate
    let uiApplication: UIApplication
    
    
    /*
    ** init
    ** This function initializes the SendPush library
    */
    convenience init(uiApplication: UIApplication) {
        let config = SendPushConfig()
        // setup our dependencies
        let restHandler = SendPushRESTHandler(apiUrl: config.apiUrl, platformID: config.platformID, platformSecret: config.platformSecret)
        let sessionService = SessionService(restHandler: restHandler)
        let userAPI = UserAPI(restHandler: restHandler)
        let deviceAPI = DeviceAPI(restHandler: restHandler)
        let pushSendAPI = PushSendAPI(restHandler: restHandler)
        self.init(config: config, uiApplication: uiApplication, sessionService: sessionService, userAPI: userAPI, deviceAPI: deviceAPI, pushSendAPI: pushSendAPI)
    }
    
    /*
    * Designated initialiser. This can be used in test cases and inject mock dependencies
    */
    init (config: SendPushConfig, uiApplication: UIApplication, sessionService: SessionService, userAPI: UserAPIDelegate, deviceAPI: DeviceAPIDelegate, pushSendAPI: PushSendAPIDelegate) {
        self.config = config
        self.uiApplication = uiApplication
        self.sessionService = sessionService
        self.userAPI = userAPI
        self.deviceAPI = deviceAPI
        self.pushSendAPI = pushSendAPI
    }
    
    func requestPush() {
        if (!config.valid) {
            NSLog("Sendpush not configured properly, ignoring requestPush")
            return
        }
        self.uiApplication.registerForRemoteNotifications()
        let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        self.uiApplication.registerUserNotificationSettings(settings)
    }
    
    /*
    * Called by the owning app when a user has accepted push notifications.
    */
    func registerDevice(deviceToken: NSData!) {
        if (!config.valid) {
            NSLog("Sendpush not configured properly, ignoring registerDevice")
            return
        }
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        
        let deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        
        func successHandler(statusCode: Int, data: NSData?) {
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setValue(deviceTokenString, forKey: SendPushConstants.DEVICE_TOKEN)
            
            // now if the user isn't registered, we need to do it now
            if !prefs.boolForKey(SendPushConstants.USER_REGISTERED), let username = prefs.stringForKey(SendPushConstants.USERNAME) as String?, let userTags = prefs.dictionaryForKey(SendPushConstants.USER_TAGS) as? Dictionary<String, String> {
                registerUser(username, tags: userTags)
            }
        }
        func failureHandler(statusCode: Int, message: String) {
            NSLog("Error in registerDevice, status: \(statusCode), message: \(message)")
        }
        self.deviceAPI.registerDevice(deviceTokenString, onSuccess: successHandler,  onFailure: failureHandler)
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
            self.userAPI.registerUser(username, deviceToken: token, tags: tags, onSuccess: successHandler,  onFailure: failureHandler)
        }
        
    }
    
    func unregisterUser() {
        if (!config.valid) {
            NSLog("Sendpush not configured properly, ignoring unregisterUser")
            return
        }
        let prefs = NSUserDefaults.standardUserDefaults()
        
        func successHandler(statusCode: Int, data: NSData?) {
            prefs.removeObjectForKey(SendPushConstants.USERNAME)
            prefs.removeObjectForKey(SendPushConstants.USER_REGISTERED)
        }
        func failureHandler(statusCode: Int, message: String) {
            NSLog("Error in unRegisterUser, status: \(statusCode), message: \(message)")
        }
        if let username = prefs.stringForKey(SendPushConstants.USERNAME) as String?, let deviceToken = prefs.stringForKey(SendPushConstants.DEVICE_TOKEN) as String? {
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
