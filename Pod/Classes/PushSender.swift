//
//  SendPush.swift
//  SendPush.co
//
//  Created by SendPush.co on 5/3/15.
//  Copyright (c) 2015 SendPush.co. All rights reserved.
//

import Foundation


public class PushSender {
    

    
    var api: SendPushAPI

    
    /*
    ** init
    ** This function initializes the SendPush library
    ** It hooks into app lifecycle, validates the info.plist settings and registers for push
    */
    init(api: SendPushAPI) {
        self.api = api
    }
    
    
    func sendPushToUsername(username: String, pushMessage: String, tags: [String:String]) {
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
        
        api.postBody(urlStr, body: body, method: "POST", completionHandler: postHandler)
        
    }
    
    
    
    
}