    //
//  SendPushConfig.swift
//  Pods
//
//  Created by Bob Axford on 11/12/2015.
//
//
import Foundation

class SendPushConfig {
    
    let apiUrl: String
    
    // Instance vars
    let platformID: String
    let platformSecret: String
    let valid: Bool
    let allowMutipleUsersPerDevice: Bool
    
    convenience init(sendpushConfig: NSDictionary) {
        var valid = true;
        var apiUrl: String
        var platformID: String
        var platformSecret: String
        var allowMutipleUsersPerDevice: Bool
        
        if let url = sendpushConfig.valueForKey("APIUrl") as? String {
            apiUrl = url
        } else {
            NSLog("SendPush Exception: No APIUrl in info.plist")
            apiUrl = "invalid"
            valid = false
        }
        
        if let pid = sendpushConfig.valueForKey("PlatformID") as? String {
            platformID = pid
        } else {
            NSLog("SendPush Exception: No PlatformID in info.plist")
            platformID = "invalid"
            valid = false
        }
        if let secret = sendpushConfig.valueForKey("PlatformSecret") as? String {
            platformSecret = secret
        } else {
            NSLog("SendPush Exception: No PlatformSecret in info.plist")
            platformSecret = "invalid"
            valid = false
        }
        
        if let secret = sendpushConfig.valueForKey("PlatformSecret") as? String {
            platformSecret = secret
        } else {
            NSLog("SendPush Exception: No PlatformSecret in info.plist")
            platformSecret = "invalid"
            valid = false
        }
        
        if let allowMultipleUsers = sendpushConfig.valueForKey("MultipleUsersPerDevice") as? Bool {
            allowMutipleUsersPerDevice = allowMultipleUsers
        } else {
            allowMutipleUsersPerDevice = false
        }
        
        self.init(apiUrl: apiUrl, platformID: platformID, platformSecret: platformSecret, valid: valid,
            allowMutipleUsersPerDevice: allowMutipleUsersPerDevice)
    }
    
    /**
     * Initialiser
     */
    init(apiUrl: String, platformID: String, platformSecret: String, valid: Bool, allowMutipleUsersPerDevice: Bool) {
        self.apiUrl = apiUrl
        self.platformID = platformID
        self.platformSecret = platformSecret
        self.valid = valid
        self.allowMutipleUsersPerDevice = allowMutipleUsersPerDevice
    }
}
