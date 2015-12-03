//
//  Registration.swift
//  Pods
//
//  Created by Bob Axford on 3/12/2015.
//
//

import Foundation


public class Registration {
    
    
    var api: SendPushAPI
    
    
    /*
    ** init
    ** This function initializes the SendPush library
    ** It hooks into app lifecycle, validates the info.plist settings and registers for push
    */
    init(api: SendPushAPI) {
        
        self.api = api
    }
    
    func registerDevice(deviceToken: String, onSuccess: () -> Void, onFailure: (statusCode: Int) -> Void) {
        
        let model = UIDevice.currentDevice().model
        let devType = UIDevice.currentDevice().systemName
        let tz = NSTimeZone.localTimeZone().abbreviation as String!
        let langId = NSLocale.preferredLanguages().first
        let body = [
            "device_platform": "ios",
            "device_type": devType,
            "model":model,
            "token": deviceToken,
            "timezone": tz,
            "language": langId
        ]
        
        func postHandler (data: NSData?, response: NSURLResponse?, error: NSError?) {
            if let err = error {
                NSLog("Error in registerDevice \(err)")
                return
            }
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            if (statusCode != 200) {
                onFailure(statusCode: statusCode)
            } else {
                onSuccess()
            }
        }
        
        api.postBody("/app/devices", body: body, method: "POST", completionHandler: postHandler)
        
    }
    
    
    func registerUser(username: String, deviceToken: String, tags: [String: String]?, onSuccess: () -> Void, onFailure: (statusCode: Int) -> Void) {
        
        let urlStr = "/app/users/\(username)/\(deviceToken)"
        
        var body = [String: String]()
        
        func postHandler (data: NSData?, response: NSURLResponse?, error: NSError?) {
            if let err = error {
                NSLog("Error in registerUser \(err)")
                return
            }

            let statusCode = (response as! NSHTTPURLResponse).statusCode
            if (statusCode != 200) {
                // TODO BA - more handling here.
                onFailure(statusCode: statusCode)
            } else {
                onSuccess()
            }
            
        }
            
        api.postBody(urlStr, body: body, method: "PUT", completionHandler: postHandler)
        
    }
    
    func unregisterUser(onSuccess: () -> Void, onFailure: (statusCode: Int) -> Void) {
        let prefs = NSUserDefaults.standardUserDefaults()
        
        if let username = prefs.stringForKey(SendPushConstants.USERNAME) as String?, let token = prefs.stringForKey(SendPushConstants.DEVICE_TOKEN) as String? {
                
            let urlStr = "/app/users/\(username)/\(token)"
            let url = NSURL(string: urlStr)
            
            var body = [String: String]()
            
            func postHandler (data: NSData?, response: NSURLResponse?, error: NSError?) {
                if let err = error {
                    NSLog("Error in unregisterUser \(err)")
                    return
                }
                print("Response: \(response)")
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                if (statusCode != 200) {
                    onFailure(statusCode: statusCode)
                } else {
                    onSuccess()
                }
            }
            api.postBody(urlStr, body: body, method: "DELETE", completionHandler: postHandler)
        }
        
    }
    
}