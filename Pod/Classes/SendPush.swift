//
//  SendPush.swift
//  SendPush.co
//
//  Created by SendPush.co on 5/3/15.
//  Copyright (c) 2015 SendPush.co. All rights reserved.
//

import Foundation


public class SendPush {
    
    // make this a singleton
    public static let sharedInstance = SendPush()

    var apiUrl: String?
    
    // Instance vars
    var platformID: String?
    var platformSecret: String?
    
    var api: SendPushAPI
    var sessionEvents: SessionEvents
    var registration: Registration
    var pushSender: PushSender
    

    
    /*
    ** init
    ** This function initializes the SendPush library
    ** It hooks into app lifecycle, validates the info.plist settings
    */
    private init() {
        
        var myDict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        
        // read configuration for sendpush
        if let dict = myDict {
            let sendpushConfig = dict.valueForKey("SendPush")
            
            if let apiUrl = sendpushConfig?.valueForKey("APIUrl") as? String {
                self.apiUrl = apiUrl
            } else {
                NSLog("SendPush Exception: No APIUrl in info.plist")
            }
            
            if let platformID = sendpushConfig?.valueForKey("PlatformID") as? String {
                self.platformID = platformID
            } else {
                NSLog("SendPush Exception: No PlatformID in info.plist")
            }
            if let platformSecret = sendpushConfig?.valueForKey("PlatformSecret") as? String {
                self.platformSecret = platformSecret
            } else {
                NSLog("SendPush Exception: No PlatformSecret in info.plist")
            }
        } else {
            NSLog("Unable to get SendPush config from info.plist")
        }
        // setup our dependencies
        self.api = SendPushAPI(platformID: self.platformID, platformSecret: self.platformSecret, apiUrl: self.apiUrl)
        self.sessionEvents = SessionEvents(api: self.api)
        self.registration = Registration(api: self.api)
        self.pushSender = PushSender(api: self.api)

        // listen to some events for session start/end
        NSNotificationCenter.defaultCenter().addObserver(self,selector: "applicationBecameActive:",
            name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: "applicationBecameInactive:",
            name: UIApplicationWillResignActiveNotification, object: nil)


    }
    
    @objc func applicationBecameActive(notification: NSNotification) {
        self.sessionEvents.startSession()
    }
    
    @objc func applicationBecameInactive(notification: NSNotification) {
        self.sessionEvents.endSession()
    }
    
    
    // MARK: public functions
    
    /*
        This is called by the owning app when they want the user to register for push notifications.
    */
    public func requestPush() {
        // request push notifications
        UIApplication.sharedApplication().registerForRemoteNotifications()
        let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    /*
    * Called by the owning app when a user has accepted push notifications.
    */
    public func registerDevice(deviceToken: NSData!) {
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        
        let deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String

        func successHandler() {
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setValue(deviceTokenString, forKey: SendPushConstants.DEVICE_TOKEN)

            // now if the user isn't registered, we need to do it now
            if !prefs.boolForKey(SendPushConstants.USER_REGISTERED), let username = prefs.stringForKey(SendPushConstants.USERNAME) as String?, let userTags = prefs.dictionaryForKey(SendPushConstants.USER_TAGS) as? Dictionary<String, String> {
                registerUser(username, tags: userTags)
                
            }
        }
        func failureHandler(statusCode: Int) {
            
        }
        self.registration.registerDevice(deviceTokenString, onSuccess: successHandler,  onFailure: failureHandler)
    }
    
    
    /*
    * This is called as soon as the username is available (eg at Login)
    */
    public func registerUser(username: String, tags: [String: String]?) {
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(username, forKey: SendPushConstants.USERNAME)
        prefs.setValue(tags, forKey: SendPushConstants.USER_TAGS)
        if let token = prefs.stringForKey(SendPushConstants.DEVICE_TOKEN) {
            // we can only register this user once we have their device token, so let's check
            func successHandler() {
                prefs.setValue(true, forKey: SendPushConstants.USER_REGISTERED)
            }
            func failureHandler(statusCode: Int) {
                prefs.setValue(false, forKey: SendPushConstants.USER_REGISTERED)
            }
            self.registration.registerUser(username, deviceToken: token, tags: tags, onSuccess: successHandler,  onFailure: failureHandler)
        }

    }
    
    public func unregisterUser() {
        let prefs = NSUserDefaults.standardUserDefaults()
        
        func successHandler() {
            prefs.removeObjectForKey(SendPushConstants.USERNAME)
            prefs.removeObjectForKey(SendPushConstants.USER_REGISTERED)
        }
        func failureHandler(statusCode: Int) {
            
        }
        self.registration.unregisterUser(successHandler, onFailure: failureHandler)
    }
    
    public func sendPushToUsername(username: String, pushMessage: String, tags: [String:String]) {
        self.pushSender.sendPushToUsername(username, pushMessage: pushMessage, tags: tags)
    }
    
    

}