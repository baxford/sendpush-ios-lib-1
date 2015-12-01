//
//  Heartbeat.swift
//  Pods
//
//  Created by Bob Axford on 26/11/2015.
//
//

import Foundation

public class Heartbeat: NSObject {

    var api: SendPushAPI
    var timer = NSTimer()
    var count = 1
    
    init(api: SendPushAPI) {
        self.api = api
    }
    
    func start() {
        let interval = Double(count) * 1.0
        delay(interval, closure: { [weak self] () -> () in
            
            if let strongSelf = self {
                strongSelf.heartbeatCallback()
            }
        })

    }
    func heartbeatCallback() {
        self.count++
        let interval = Double(count * count) * 1.0
        print("HEARTBEAT \(self.count), next at \(interval)")
        beat()
        delay(interval, closure: { [weak self] () -> () in
            if let strongSelf = self {
                strongSelf.heartbeatCallback()
            }
        })
    }

    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

    
    func stop() {
        self.timer.invalidate()
    }
    
    
    deinit {
        self.timer.invalidate()
    }
    
    private func beat() {
        
        let urlStr = "/app/session"

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
                            print("heartbeat Success: \(status)")
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