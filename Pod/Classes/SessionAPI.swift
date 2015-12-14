//
//  SendPushSession.swift
//  Pods
//
//  Created by Bob Axford on 3/12/2015.
//
//
import Foundation
import UIKit

public class SessionAPI: SessionAPIDelegate {
    
    // intervals at which we post heartbeats - up to max of every 5 mins
    let restHandler: SendPushRESTHandler
    let deviceUniqueID: String
    /*
    ** init
    ** This function initializes the sessionAPI
    */
    init(restHandler: SendPushRESTHandler, deviceUniqueID: String) {
        
        self.restHandler = restHandler
        self.deviceUniqueID = deviceUniqueID
        
    }

    func buildSessionBody() -> NSDictionary {
        let prefs = NSUserDefaults.standardUserDefaults()
        
        let body: NSMutableDictionary = [
            "device_id": self.deviceUniqueID
        ]
        
        if let _ = prefs.stringForKey("sendPushUsername") {
//            body.setValue(username, forKey:"username")
            body.setValue(true, forKey: "loggedIn")
        } else {
            body.setValue(false, forKey: "loggedIn")
        }
        if let _ = prefs.stringForKey("sendPushDeviceToken") {
//            body.setValue(deviceToken, forKey:"device_token")
            body.setValue(true, forKey: "opt_in_push")
        } else {
            body.setValue(false, forKey: "opt_in_push")
        }

        return body
    }
    
    func startSession(onSuccess: (statusCode: Int, data: NSData?) -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
        self.restHandler.postBody("/app/session", body: buildSessionBody(), method: "POST", onSuccess: onSuccess, onFailure: onFailure)
    }
    
    func extendSession(onSuccess: (statusCode: Int, data: NSData?) -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
        self.restHandler.postBody("/app/session", body: buildSessionBody(), method: "PUT", onSuccess: onSuccess, onFailure: onFailure)
    }
    
    
}