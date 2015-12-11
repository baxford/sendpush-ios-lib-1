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
    func sendPushToUsername(username: String, pushMessage: String, tags: [String:String], onSuccess: () -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
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
                onFailure(statusCode: -1, message: err.description)
                return
            }
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            if (statusCode != 200) {
                onFailure(statusCode: statusCode, message: response!.description)
            } else {
                onSuccess()
            }
        }
    
        restHandler.postBody(urlStr, body: body, method: "POST", completionHandler: postHandler)
        
    }
    
    
    
    
}