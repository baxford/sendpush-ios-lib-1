//
//  SendPush.swift
//  SendPush.co
//
//  Created by SendPush.co on 5/3/15.
//  Copyright (c) 2015 SendPush.co. All rights reserved.
//

import Foundation


public class SendPush {
    
    // Class vars
    public static let push = SendPush()

    var apiUrl: String?
    
    // Instance vars
    var platformID: String?
    var platformSecret: String?
    
    var api: SendPushAPI?
    
    var heartbeat: Heartbeat?
    
    /*
    ** init
    ** This function initializes the SendPush library
    ** It hooks into app lifecycle, validates the info.plist settings and registers for push
    */
    init() {
        
        var myDict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = myDict {
            let sendpushConfig = dict.valueForKey("SendPush")
            
            if let apiUrl = sendpushConfig?.valueForKey("APIUrl") as? String {
                self.apiUrl = apiUrl
            } else {
                print("SendPush Exception: No APIUrl in info.plist")
            }
            
            if let platformID = sendpushConfig?.valueForKey("PlatformID") as? String {
                self.platformID = platformID
            } else {
                print("SendPush Exception: No PlatformID in info.plist")
            }
            if let platformSecret = sendpushConfig?.valueForKey("PlatformSecret") as? String {
                self.platformSecret = platformSecret
            } else {
                print("SendPush Exception: No PlatformSecret in info.plist")
            }
        } else {
            debugPrint("Unable to get SendPush config from info.plist")
        }
        self.api = SendPushAPI(platformID: self.platformID, platformSecret: self.platformSecret, apiUrl: self.apiUrl)
        self.heartbeat = Heartbeat(api: self.api!)
        // listen to some events
        NSNotificationCenter.defaultCenter().addObserver(self,selector: "applicationBecameActive:",
            name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: "applicationBecameInactive:",
            name: UIApplicationWillResignActiveNotification, object: nil)

        
        print("Init sendpush")
        // Return self for chainable interface

    }
    
    public func bootstrap() -> SendPush {
        return self
    }
    
    @objc func applicationBecameActive(notification: NSNotification) {
        startSession()
    }
    
    @objc func applicationBecameInactive(notification: NSNotification) {
        endSession()
    }
    
    public func setupPush() {
        let prefs = NSUserDefaults.standardUserDefaults()
        let optedInForPush = prefs.boolForKey("sendPushOptedIn")
        if (optedInForPush) {

        } else {
            // request push notifications
            UIApplication.sharedApplication().registerForRemoteNotifications()
            let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        }
    }
    
    private func startSession() {

        let body = [
            "device_id": "something",
            
        ]
        
        func postHandler (data: NSData?, response: NSURLResponse?, error: NSError?) {
            if let err = error {
                NSLog("Error in startSession \(err)")
                return
            }
            print("Response: \(response)")
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            if (statusCode != 200) {
                // TODO BA - more handling here.
                NSLog("Error in startSession - HTTP status code: \(statusCode)");
                return
            }
            // TODO BA - handle connection errors or different responses etc
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the values out of it
                    if let jsonData = parseJSON["data"] {
                        if let status = jsonData as? String {
                            print("Success: \(status)")
                        }
                        
                        self.heartbeat!.start()
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
        
        api!.postBody("/app/session", body: body, method: "POST", completionHandler: postHandler)
        
    }
    
    private func endSession() {
        self.heartbeat!.stop()

        let body = [
            "device_id": "something",
            
        ]
        
        func postHandler (data: NSData?, response: NSURLResponse?, error: NSError?) {
            if let err = error {
                NSLog("Error in startSession \(err)")
                return
            }
            print("Response: \(response)")
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            if (statusCode != 200) {
                // TODO BA - more handling here.
                NSLog("Error in startSession - HTTP status code: \(statusCode)");
                return
            }
            // TODO BA - handle connection errors or different responses etc
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the values out of it
                    if let jsonData = parseJSON["data"] {
                        if let status = jsonData as? String {
                            print("Success: \(status)")
                        }
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
        
        api!.postBody("/app/session", body: body, method: "PUT", completionHandler: postHandler)
        
    }
    
    public func registerDevice(deviceToken: NSData!) {
        
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
                        let id = jsonData["id"] as? NSString
                        let token = jsonData["token"] as? NSString
                        let prefs = NSUserDefaults.standardUserDefaults()
                    
                        prefs.setValue(id!, forKey: "sendPushDeviceId")
                        prefs.setValue(token, forKey: "sendPushDeviceToken")

                        print("Success: \(id!)")
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
        
        api!.postBody("/app/devices", body: body, method: "POST", completionHandler: postHandler)
        
    }
    
    
    public func registerUser(username: String, tags: [String: String]?) {
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
            
            api!.postBody(urlStr, body: body, method: "PUT", completionHandler: postHandler)
        }
    }
    
    public func unregisterUser() {
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
            
                api!.postBody(urlStr, body: body, method: "DELETE", completionHandler: postHandler)
        
            }
        }
    }
    
    public func sendPushToUsername(username: String, pushMessage: String, tags: [String:String]) {
        //localhost:3000/app/send/username/terry/test
        let urlStr = "/app/users/\(username)/messages"
        
        var tagDict = [Dictionary<String, String>]()
        for (tag,value) in tags {
            tagDict.append(["tag":tag,"value":value])

        }
        let body = [
            "content": pushMessage,
            "tags": tagDict
        ]
        
        func postHandler (data: NSData?, response: NSURLResponse?, error: NSError?) {
            if let err = error {
                NSLog("Error in sendPushToUsername \(err)")
                return
            }
            print("Response: \(response)")
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            if (statusCode != 200) {
                // TODO BA - more handling here.
                NSLog("Error in sendPushToUsername - HTTP status code: \(statusCode)");
                return
            }
            // TODO BA - handle connection errors or different responses etc
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                        
                if let parseJSON = json {
                            // Okay, the parsedJSON is here, let's get the values out of it
                    if let jsonData = parseJSON["data"] {
                        if let status = jsonData as? String {
                            print("Success: \(status)")
                        }
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
                
        api!.postBody(urlStr, body: body, method: "POST", completionHandler: postHandler)
                
    }
    
    
    //MARK: NotificationDelegate Methods
    

    
    public func didRegisterUserNotificationSettings(notificationSettings: UIUserNotificationSettings) {
        print("didRegisterUserNotificationSettings")
    }
    
    public func didReceiveRemoteNotification(userInfo: [NSObject : AnyObject]) {
        print("didReceiveRemoteNotification")
    }
    
    public func didReceiveRemoteNotification(userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("didReceiveRemoteNotification")
    }
    

}