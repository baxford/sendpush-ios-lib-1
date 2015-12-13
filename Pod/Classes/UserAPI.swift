//
//  UserAPI.swift
//  Pods
//
//  Created by Bob Axford on 11/12/2015.
//
//
import Foundation

class UserAPI: UserAPIDelegate {

    
    var restHandler: SendPushRESTHandler
    
    /*
    ** init
    ** This function initializes the SendPush library
    ** It hooks into app lifecycle, validates the info.plist settings and registers for push
    */
    init(restHandler: SendPushRESTHandler) {
        
        self.restHandler = restHandler
    }
    
    func registerUser(username: String, deviceToken: String, tags: [String: String]?, onSuccess: () -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
        
        let urlStr = "/app/users/\(username)/\(deviceToken)"
        
        let body = [String: String]()
       
        restHandler.postBody(urlStr, body: body, method: "PUT", onSuccess: onSuccess, onFailure: onFailure)
        
    }
    
    func unregisterUser(onSuccess: () -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
        let prefs = NSUserDefaults.standardUserDefaults()
        
        if let username = prefs.stringForKey(SendPushConstants.USERNAME) as String?, let token = prefs.stringForKey(SendPushConstants.DEVICE_TOKEN) as String? {
            
            let urlStr = "/app/users/\(username)/\(token)"
            
            let body = [String: String]()
            
            restHandler.postBody(urlStr, body: body, method: "DELETE", onSuccess: onSuccess, onFailure: onFailure)
        }
        
    }

}
