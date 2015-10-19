//
//  SendPush.swift
//  SendPush.co
//
//  Created by SendPush.co on 5/3/15.
//  Copyright (c) 2015 SendPush.co. All rights reserved.
//

import Foundation
import JWT

public class SendPush {
    
    // Class vars
    public static let push = SendPush()
    class var apiUrl: String { return "http://10.0.1.7:3000/app" }
    
    // Instance vars
    var platformToken: String?
    var username: String?
    
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
            // Use your dict here
            let sendpushConfig = dict.valueForKey("SendPush")
            
            if let platformToken = dict.valueForKey("PlatformToken") as? String {
                self.jwt = platformToken
            } else {
                print("SendPush Exception: No PlatformToken in info.plist")
            }
            
        } else {
            debugPrint("Unable to get SendPush config from info.plist")
        }
        

        // Return self for chainable interface
        return self
    }
    
    public func setupPush() {
        let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    public func registerUser(username: String, tags: [String: String]?) {
        self.username = username
        if let token = token {
            
            let url = NSURL(string: "\(SendPush.apiUrl)/users")
            
            let body = [
                "token": token,
                "username": username
            ]
            
            postBody(url!, body: body) { (data, response, error) in
                let s = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("registerUser: \(s)")
            }
            
        }
    }
    
    public func unregisterUser() {
        if let username = username, token = token {
            
            let url = NSURL(string: "\(SendPush.apiUrl)/users/unregister")
            
            let body = [
                "token": token,
                "username": username
            ]
            
            postBody(url!, body: body) { (data, response, error) in
                
            }
            
        }
        username = nil
    }
    
    //MARK: NotificationDelegate Methods
    
    public func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: NSData) {
        
        let url = NSURL(string: "\(SendPush.apiUrl)/devices")
        
        // Clean up device token
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        token = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        
        let body = [
            "device_type": "ios", // TODO: Get the device_type
            "model": "", // TODO: Fill out the model
            "token": token!,
            "timezone": NSTimeZone.localTimeZone().abbreviation!,
            "language": NSLocale.preferredLanguages()[0]
        ]
        
        postBody(url!, body: body) { (data, response, error) in
            if let username = self.username {
                self.registerUser(username, tags: nil)
            }
        }
    }
    
    public func didFailToRegisterForRemoteNotificationsWithError(error: NSError) {
        println("Failed to register for remote with error \(error)")
    }
    
    public func didRegisterUserNotificationSettings(notificationSettings: UIUserNotificationSettings) {
        
    }
    
    public func didReceiveRemoteNotification(userInfo: [NSObject : AnyObject]) {
        
    }
    
    public func didReceiveRemoteNotification(userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        
    }
    
    private
    
    func postBody(url: NSURL?, body: [String: AnyObject], completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?) {
        
        var error: NSError?
        let json = NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions(0), error: &error)
        if let error = error {
            println("SendPush Exception: Serializing json \(error)")
            return
        }
        
        if let json = json {
            let authToken = signRequest(json)
            
            // Create a POST request with our JSON as a request body.
            var request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "POST"
            request.HTTPBody = json
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            var config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
            config.HTTPAdditionalHeaders = [
                "Authorization": "bearer \(authToken)"
            ]
            
            let task = NSURLSession(configuration: config).dataTaskWithRequest(request, completionHandler: completionHandler)
            task.resume()
        }
        
    }
    
    func signRequest(body: NSData) -> String {
        
        let secret = appKey ?? ""
        let sub = platformKey ?? ""
        
        return JWT.encode(.HS256(secret)) { builder in
            builder.issuer = "co.sendpush"
            builder.expiration = NSDate(timeIntervalSinceNow: 60)
            builder["sub"] = sub
            // TODO: Hash the body builder["hash"] = ""
        }
    }
}