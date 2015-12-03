//
//  Registration.swift
//  Pods
//
//  Created by Bob Axford on 3/12/2015.
//
//

import Foundation
//
//  SendPush.swift
//  SendPush.co
//
//  Created by SendPush.co on 5/3/15.
//  Copyright (c) 2015 SendPush.co. All rights reserved.
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
    
    func registerDevice(deviceToken: NSData!) {
        
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        
        let deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        
        let model = UIDevice.currentDevice().model
        let devType = UIDevice.currentDevice().systemName
        
        let body = [
            "device_platform": "ios",
            "device_type": devType,
            "model":model,
            "token": deviceTokenString,
            "timezone":"+1000",
            "language":"en"
        ]
        
        func postHandler (data: NSData?, response: NSURLResponse?, error: NSError?) {
            if let err = error {
                NSLog("Error in registerDevice \(err)")
                return
            }
            print("Response: \(response)")
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            if (statusCode != 200) {
                // TODO BA - more handling here.
                NSLog("Error in registerDevice - HTTP status code: \(statusCode)");
                return;
            }
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the values out of it
                    if let jsonData = parseJSON["data"] {
                        let token = jsonData["token"] as? NSString
                        let prefs = NSUserDefaults.standardUserDefaults()
                        
                        prefs.setValue(token, forKey: "sendPushDeviceToken")
                        
                        NSLog("Success: \(token!)")
                    }
                } else {
                    // the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    NSLog("Error could not parse JSON: \(jsonStr)")
                }
            } catch {
                NSLog("SendPush Exception: Serializing json \(error)")
                return
            }
        }
        
        api.postBody("/app/devices", body: body, method: "POST", completionHandler: postHandler)
        
    }
    
    
    func registerUser(username: String, tags: [String: String]?) {
        let prefs = NSUserDefaults.standardUserDefaults()
        
        if let token = prefs.valueForKey("sendPushDeviceToken") {
            let urlStr = "/app/users/\(username)/\(token)"
            
            var body = [String: String]()
            
            func postHandler (data: NSData?, response: NSURLResponse?, error: NSError?) {
                if let err = error {
                    NSLog("Error in registerUser \(err)")
                    return
                }
                print("Response: \(response)")
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                if (statusCode != 200) {
                    // TODO BA - more handling here.
                    NSLog("Error in registerUser - HTTP status code: \(statusCode)");
                    return;
                }
                let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Body: \(strData)")
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                    
                    if let parseJSON = json {
                        // Okay, the parsedJSON is here, let's get the values out of it
                        if let jsonData = parseJSON["data"] {
                            let un = jsonData["username"] as? NSString
                            let prefs = NSUserDefaults.standardUserDefaults()
                            
                            prefs.setValue(un!, forKey: "sendPushUsername")
                            
                            print("Success: \(un!)")
                        }
                    } else {
                        // the json object was nil, something went worng. Maybe the server isn't running?
                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print("Error could not parse JSON: \(jsonStr)")
                    }
                } catch {
                    print("SendPush Exception: Serializing json \(error)")
                    return
                }
                
            }
            
            api.postBody(urlStr, body: body, method: "PUT", completionHandler: postHandler)
        }
    }
    
    func unregisterUser() {
        let prefs = NSUserDefaults.standardUserDefaults()
        
        if let username = prefs.valueForKey("sendPushUsername") {
            if let token = prefs.valueForKey("sendPushDeviceToken") {
                
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
                        // TODO BA - more handling here.
                        NSLog("Error in unregisterUser - HTTP status code: \(statusCode)");
                        return;
                    }
                    let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Body: \(strData)")
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                        
                        if let parseJSON = json {
                            // Okay, the parsedJSON is here, let's get the values out of it
                            if let jsonData = parseJSON["data"] {
                                let un = jsonData["username"] as? NSString
                                let prefs = NSUserDefaults.standardUserDefaults()
                                
                                prefs.setValue(un!, forKey: "sendPushUsername")
                                
                                print("Success: \(un!)")
                            }
                        } else {
                            // the json object was nil, something went worng. Maybe the server isn't running?
                            let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                            print("Error could not parse JSON: \(jsonStr)")
                        }
                    } catch {
                        print("SendPush Exception: Serializing json \(error)")
                        return
                    }
                    
                }
                
                api.postBody(urlStr, body: body, method: "DELETE", completionHandler: postHandler)
                
            }
        }
    }
    
}