//
//  DeviceAPI.swift
//  Pods
//
//  Created by Bob Axford on 11/12/2015.
//
//
import UIKit

class DeviceAPI: DeviceAPIDelegate {

    let restHandler: SendPushRESTHandler
    
    
    /*
    ** init
    ** This function initializes the SendPush library
    ** It hooks into app lifecycle, validates the info.plist settings and registers for push
    */
    init(restHandler: SendPushRESTHandler) {
        
        self.restHandler = restHandler
    }
    
    func registerDevice(deviceToken: String, onSuccess: (statusCode: Int, data: NSData?) -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
        
        let model = UIDevice.currentDevice().model
        let devType = UIDevice.currentDevice().systemName
        let tz = NSTimeZone.localTimeZone().abbreviation as String!
        let langId = NSLocale.preferredLanguages().first
        let body = [
            "device_platform": "ios",
            "device_type": devType,
            "model":model,
            "token": deviceToken,
            "timezone": tz,
            "language": langId
        ]
        
        restHandler.postBody("/app/devices", body: body, method: "POST", onSuccess: onSuccess, onFailure: onFailure)
        
    }
    
}
