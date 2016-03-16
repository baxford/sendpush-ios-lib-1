//
//  SendPush.swift
//  SendPush.co
//
//  Created by SendPush.co on 5/3/15.
//  Copyright (c) 2015 SendPush.co. All rights reserved.
//

import Foundation


public class PushSendAPI: PushSendAPIDelegate {
    

    
    var restHandler: SendPushRESTHandler

    
    /*
    ** init
    ** This function initializes the SendPush library
    ** It hooks into app lifecycle, validates the info.plist settings and registers for push
    */
    init(restHandler: SendPushRESTHandler) {
        self.restHandler = restHandler
    }
    
    // This uses the sendpush API to send a push to the specified username, if user is not registered or doesn't have a registered device, no push is sent.
    func sendPushToUsername(username: String, pushMessage: String, tags: [String:String], metadata: [String:String], onSuccess: (statusCode: Int, data: NSData?) -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
        let urlStr = "/messages/users/\(username)"

        let body = [
            "content": pushMessage,
            "tags": tags,
            "metadata": metadata
        ]
        
        restHandler.postBody(urlStr, body: body, method: "POST", onSuccess: onSuccess, onFailure: onFailure)
        
    }
    
    
    
    
}