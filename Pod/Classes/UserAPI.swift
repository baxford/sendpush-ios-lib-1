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
    
    func registerUser(username: String, deviceToken: String, allowMutipleUsersPerDevice: Bool, tags: [String: String]?, onSuccess: (statusCode: Int, data: NSData?) -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
        
        
        let urlStr = "/app/users/\(username)/\(deviceToken)"
        
        let body = [String: String]()
       
        restHandler.postBody(urlStr, body: body, method: allowMutipleUsersPerDevice ? "POST" : "PUT", onSuccess: onSuccess, onFailure: onFailure)
        
    }
    
    func unregisterUser(username: String, deviceToken: String, onSuccess: (statusCode: Int, data: NSData?) -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
        
        let urlStr = "/app/users/\(username)/\(deviceToken)"
            
        let body = [String: String]()
        
        restHandler.postBody(urlStr, body: body, method: "DELETE", onSuccess: onSuccess, onFailure: onFailure)
    }

}
