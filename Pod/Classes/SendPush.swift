//
//  SendPush.swift
//  SendPush.co
//
//  Created by SendPush.co on 5/3/15.
//  Copyright (c) 2015 SendPush.co. All rights reserved.
//

import Foundation
import JWT
import CryptoSwift

public class SendPush {
    
    // Class vars
    public static let push = SendPush()

    var apiUrl: String?
    
    // Instance vars
    var platformToken: String?
    var platformSecret: String?
    
    /*
    ** bootstrap
    ** This function initializes the SendPush library
    ** It hooks into app lifecycle, validates the info.plist settings and registers for push
    */
    public func bootstrap() -> SendPush {
        
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
            
            if let platformToken = sendpushConfig?.valueForKey("PlatformToken") as? String {
                self.platformToken = platformToken
            } else {
                print("SendPush Exception: No PlatformToken in info.plist")
            }
            if let platformSecret = sendpushConfig?.valueForKey("PlatformSecret") as? String {
                self.platformSecret = platformSecret
            } else {
                print("SendPush Exception: No PlatformSecret in info.plist")
            }
        } else {
            debugPrint("Unable to get SendPush config from info.plist")
        }
        
        print("Init sendpush")
        // Return self for chainable interface
        return self
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
    
    public func registerDevice(deviceToken: NSData!) {
        let urlStr = "\(self.apiUrl!)/app/devices"
        let url = NSURL(string: urlStr)
        
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        
        let deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String

            
        let body = [
            "device_platform": "ios",
            "device_type": "TODO",
            "model":"TODO",
            "token": deviceTokenString,
            "timezone":"+1000",
            "language":"en"
        ]
        
        func postHandler (data: NSData?, response: NSURLResponse?, error: NSError?) {
            if let err = error {
                print("Error \(err)")
            }
            print("Response: \(response)")
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
        
        postBody(url!, body: body, method: "POST", completionHandler: postHandler)
        
    }
    
    
    public func registerUser(username: String, tags: [String: String]?) {
        let prefs = NSUserDefaults.standardUserDefaults()

        if let token = prefs.valueForKey("sendPushDeviceToken") {
            let urlStr = "\(self.apiUrl!)/app/users/\(username)/\(token)"
            let url = NSURL(string: urlStr)
            
            var body = [String: String]()
        
            func postHandler (data: NSData?, response: NSURLResponse?, error: NSError?) {
                if let err = error {
                    print("Error \(err)")
                }
                print("Response: \(response)")
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
            
            postBody(url!, body: body, method: "PUT", completionHandler: postHandler)
        }
    }
    
    public func unregisterUser() {
        let prefs = NSUserDefaults.standardUserDefaults()
        
        if let username = prefs.valueForKey("sendPushUsername") {
            if let token = prefs.valueForKey("sendPushDeviceToken") {
        
                let urlStr = "\(self.apiUrl!)/app/users/\(username)/\(token)"
                let url = NSURL(string: urlStr)
                
                var body = [String: String]()
            
                func postHandler (data: NSData?, response: NSURLResponse?, error: NSError?) {
                    if let err = error {
                        print("Error \(err)")
                    }
                    print("Response: \(response)")
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
            
                postBody(url!, body: body, method: "DELETE", completionHandler: postHandler)
        
            }
        }
    }
    
    public func sendPushToUsername(username: String, pushMessage: String, tags: [String:String]) {
        //localhost:3000/app/send/username/terry/test
        let urlStr = "\(self.apiUrl!)/app/users/\(username)/messages"
        let url = NSURL(string: urlStr.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        
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
                print("Error \(err)")
            }
            print("Response: \(response)")
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
                
        postBody(url!, body: body, method: "POST", completionHandler: postHandler)
                
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
    
    private func postBody(url: NSURL?, body: NSDictionary, method: String, completionHandler: ( (NSData?, NSURLResponse?, NSError?) -> Void)?) {
        var request = NSMutableURLRequest(URL: url!)
        var session = NSURLSession.sharedSession()
        
        do {
            let json =  try NSJSONSerialization.dataWithJSONObject(body, options: [])
            let authToken = signRequest(json)
            let dataString = NSString(data: json, encoding: NSUTF8StringEncoding)!
            request.HTTPBody = json
            request.HTTPMethod = method
            request.addValue("bearer \(authToken)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = session.dataTaskWithRequest(request, completionHandler: completionHandler!)
        
            task.resume()
        } catch {
            print("SendPush Exception: Serializing json \(error)")
            return
        }

    }
    
    /*
        This function creates a JWT to authenticate the request.
        It also calculates a sha256 of the request body and includes it as a claim in the JWT called 'hash'
    */
    func signRequest(body: NSData) -> String {
        
        let secret = platformSecret ?? ""
        let sub = platformToken ?? ""

        let sha256 = body.sha256()
        let hash = sha256!.toHexString()
        return JWT.encode(.HS256(secret)) { builder in
            builder.issuer = "co.sendpush"
            builder.expiration = NSDate(timeIntervalSinceNow: 60)
            builder["sub"] = sub
            builder["hash"] = hash
        }
    }
}