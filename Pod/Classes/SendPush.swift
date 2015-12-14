//
//  SendPush.swift
//  SendPush.co
//
//  Created by SendPush.co on 5/3/15.
//  Copyright (c) 2015 SendPush.co. All rights reserved.
//

import Foundation
import UIKit

public class SendPush: SendPushDelegate {
    
    // make this a singleton
    public static let sharedInstance = SendPush()
    
    var service: SendPushService
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    /*
    ** init
    ** This function initializes the SendPush library
    ** It hooks into app lifecycle, validates the info.plist settings
    */
    private init() {
        // to enhance testability keep this as simple as possible and delegate all calls to the send push service
        self.service = SendPushService(uiApplication: UIApplication.sharedApplication())
    }
    
    
    // MARK: public functions
    
    /*
    *    This is called by the owning app when they want the user to register for push notifications.
    */
    @objc public func requestPush() {
        // request push notifications
        self.service.requestPush()
    }
    
    /*
    * Called by the owning app when a user has accepted push notifications.
    */
    @objc public func registerDevice(deviceToken: NSData!) {
        // do this in a background thread to avoid blocking main thread
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.service.registerDevice(deviceToken)
        }
    }
    
    
    /*
    * This is called as soon as the username is available (eg at Login)
    */
    @objc public func registerUser(username: String, tags: [String: String]?) {
        // do this in a background thread to avoid blocking main thread
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.service.registerUser(username, tags: tags)
        }
    }
    
    /*
    * Unregister the current user
    */
    @objc public func unregisterUser() {
        // do this in a background thread to avoid blocking main thread
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.service.unregisterUser()
        }
    }
    
    /*
    * Send a push to the given username
    */
    @objc public func sendPushToUsername(username: String, pushMessage: String, tags: [String:String]) {
        // do this in a background thread to avoid blocking main thread
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.service.sendPushToUsername(username, pushMessage: pushMessage, tags: tags)
        }
    }
    
    

}