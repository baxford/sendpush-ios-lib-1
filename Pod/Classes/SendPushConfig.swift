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
    
    convenience init() {
        var valid = true;
        var apiUrl: String
        var platformID: String
        var platformSecret: String
        var myDict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        
        // read configuration for sendpush
        if let dict = myDict {
            let sendpushConfig = dict.valueForKey("SendPush")
            
            if let url = sendpushConfig?.valueForKey("APIUrl") as? String {
                apiUrl = url
            } else {
                NSLog("SendPush Exception: No APIUrl in info.plist")
                apiUrl = "invalid"
                valid = false
            }
            
            if let pid = sendpushConfig?.valueForKey("PlatformID") as? String {
                platformID = pid
            } else {
                NSLog("SendPush Exception: No PlatformID in info.plist")
                platformID = "invalid"
                valid = false
            }
            if let secret = sendpushConfig?.valueForKey("PlatformSecret") as? String {
                platformSecret = secret
            } else {
                NSLog("SendPush Exception: No PlatformSecret in info.plist")
                platformSecret = "invalid"
                valid = false
            }
        } else {
            NSLog("Unable to get SendPush config from info.plist")
            apiUrl = "invalid"
            platformID = "invalid"
            platformSecret = "invalid"
            valid = false
        }
        self.init(apiUrl: apiUrl, platformID: platformID, platformSecret: platformSecret, valid: valid)
    }
    
    /**
    * Initialiser
    */
    init(apiUrl: String, platformID: String, platformSecret: String, valid: Bool) {
        self.apiUrl = apiUrl
        self.platformID = platformID
        self.platformSecret = platformSecret
        self.valid = valid
    }
}
