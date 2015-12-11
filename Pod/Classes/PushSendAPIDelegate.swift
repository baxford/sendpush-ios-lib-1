//
//  PushSendAPIDelegate.swift
//  Pods
//
//  Created by Bob Axford on 11/12/2015.
//
//

protocol PushSendAPIDelegate {
    
    /**
    * Send a push to a given username
    */
    func sendPushToUsername(username: String, pushMessage: String, tags: [String:String], onSuccess: () -> Void, onFailure: (statusCode: Int, message: String) -> Void)
}
