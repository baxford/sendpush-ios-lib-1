//
//  SendPushSession.swift
//  Pods
//
//  Created by Bob Axford on 3/12/2015.
//
//

import Foundation
public class SessionEvents {
    
    
    var api: SendPushAPI
    var heartbeat: Heartbeat
    var deviceUniqueID: String
    /*
    ** init
    ** This function initializes the SendPush library
    ** It hooks into app lifecycle, validates the info.plist settings and registers for push
    */
    init(api: SendPushAPI) {
        
        self.api = api
        self.heartbeat = Heartbeat(api: api)
        let prefs = NSUserDefaults.standardUserDefaults()
        
        if let deviceId = prefs.stringForKey("sendPushDeviceUuniqueID") {
            self.deviceUniqueID = deviceId
        } else {
            self.deviceUniqueID = "something"
            prefs.setValue(self.deviceUniqueID, forKey: "sendPushDeviceUuniqueID")
        }
    }
    
    
    func startSession() {
        
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
                        
                        self.heartbeat.start()
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
        
        api.postBody("/app/session", body: body, method: "POST", completionHandler: postHandler)
        
    }
    
    func endSession() {
        self.heartbeat.stop()
        
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
        
        api.postBody("/app/session", body: body, method: "PUT", completionHandler: postHandler)
    }
}