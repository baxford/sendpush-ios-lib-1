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
    let sendPushData:SendPushDataDelegate
    /*
    ** init
    ** This function initializes the sessionAPI
    */
    init(restHandler: SendPushRESTHandler, sendPushData: SendPushDataDelegate, deviceUniqueID: String) {
        
        self.restHandler = restHandler
        self.sendPushData = sendPushData
        self.deviceUniqueID = deviceUniqueID
        
    }

    func buildSessionBody() -> NSDictionary {
        
        let body: NSMutableDictionary = [
            "device_id": self.deviceUniqueID
        ]
        
        let usernames = sendPushData.getUsernames()
        let usernameStr = usernames.joinWithSeparator(",")
        body.setValue(usernameStr, forKey: "username")
        
        if let deviceToken = sendPushData.optedInPushDeviceToken() {
            body.setValue(deviceToken, forKey:"device_token")
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