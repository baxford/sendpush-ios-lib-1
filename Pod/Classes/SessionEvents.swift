//
//  SendPushSession.swift
//  Pods
//
//  Created by Bob Axford on 3/12/2015.
//
//

import Foundation
public class SessionEvents {
    
    // intervals at which we post heartbeats - up to max of every 5 mins
    let hearbeatIntervals = [1,5, 15, 30, 45, 60, 120, 180, 240, 300]
    var api: SendPushAPI
    var deviceUniqueID: String
    var heartbeatCount = 0
    var active = false;
    /*
    ** init
    ** This function initializes the SendPush library
    ** It hooks into app lifecycle, validates the info.plist settings and registers for push
    */
    init(api: SendPushAPI) {
        
        self.api = api

        let prefs = NSUserDefaults.standardUserDefaults()
        
        if let deviceId = prefs.stringForKey(SendPushConstants.DEVICE_UNIQUE_ID) {
            self.deviceUniqueID = deviceId
        } else {
            self.deviceUniqueID = "something"
            prefs.setValue(self.deviceUniqueID, forKey: SendPushConstants.DEVICE_UNIQUE_ID)
        }
    }
    
    func buildSessionBody() -> NSDictionary {
        let prefs = NSUserDefaults.standardUserDefaults()
        var loggedIn = false, optInPush = false;
        if let _ = prefs.stringForKey("sendPushUsername") {
            loggedIn = true
        }
        if let _ = prefs.stringForKey("sendPushDeviceToken") {
            optInPush = true
        }
        
        let body = [
            "device_id": self.deviceUniqueID,
            "opt_in_push": optInPush,
            "logged_in": loggedIn
        ]
        return body
    }
    
    func startSession() {
        
        let completionHandler = handleSession({
            NSLog("Session done, starting heartbeat")
            self.startHeartbeat()
        })
        
        api.postBody("/app/session", body: buildSessionBody(), method: "POST", completionHandler: completionHandler)
        
    }
    
    func endSession() {
        let completionHandler = handleSession({
            NSLog("Session done, starting heartbeat")
            self.stopHeartbeat()
        })
        api.postBody("/app/session", body: buildSessionBody(), method: "PUT", completionHandler: completionHandler)
    }
    
    // MARK: heartbeat
    
    func startHeartbeat() {
        self.active = true
        self.heartbeatCount = 0
        let interval = Double(hearbeatIntervals[heartbeatCount]) * 1.0
        delay(interval, closure: { [unowned self] () -> () in
            self.heartbeatCallback()
        })
    }
    
    func heartbeatCallback() {
        if (heartbeatCount < hearbeatIntervals.count - 1) {
            heartbeatCount += 1
        }
        let backoff = hearbeatIntervals[heartbeatCount]
        let interval = Double(backoff) * 1.0
        NSLog("HEARTBEAT \(self.heartbeatCount), next at \(interval)")
        if (self.active) {
            beat()
            delay(interval, closure: { [unowned self] () -> () in
                self.heartbeatCallback()
            })
        }
    }
    
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure
        )
    }
    
    
    func stopHeartbeat() {
        self.active = false
    }
    
    private func beat() {
        let urlStr = "/app/session"
        let ch = handleSession({
            NSLog("Session done")
        })
        api.postBody(urlStr, body: buildSessionBody(), method: "PUT", completionHandler: ch)
    }

    /*
    * This function returns a closure which is a completion handler, that executes the onSuccess function if successful
    */
    func handleSession(onSuccess: () -> Void) -> ((data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) {
        func sessionResponseHandler (data: NSData?, response: NSURLResponse?, error: NSError?) {
            if let err = error {
                NSLog("Error in session request \(err)")
                return
            }
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            if (statusCode != 200) {
                // TODO BA - more handling here.
                NSLog("Error in session request - HTTP status code: \(statusCode)");
                return
            }

            onSuccess()

        }
        return sessionResponseHandler
    }
    
}