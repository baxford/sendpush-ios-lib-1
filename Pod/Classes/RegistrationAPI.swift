//
//  RegistrationAPI.swift
//  Pods
//
//  Created by Bob Axford on 4/03/2016.
//
//

import Foundation

class RegistrationAPI: RegistrationAPIDelegate {
    var restHandler: SendPushRESTHandler
    
    /*
    ** init
    ** This function initializes the SendPush library
    ** It hooks into app lifecycle, validates the info.plist settings and registers for push
    */
    init(restHandler: SendPushRESTHandler) {
        
        self.restHandler = restHandler
    }
    
    func register(registration: Registration, onSuccess: (statusCode: Int, data: NSData?) -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
        
        
        let urlStr = "/app/devices/\(registration.device.token!)"
        
        let json = registration.asJson()
        restHandler.postBody(urlStr, body: json, method: "PUT", onSuccess: onSuccess, onFailure: onFailure)
        
    }
}