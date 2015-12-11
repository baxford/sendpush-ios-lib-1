//
//  DeviceAPI.swift
//  Pods
//
//  Created by Bob Axford on 11/12/2015.
//
//


class DeviceAPI: DeviceAPIDelegate {

    var restHandler: SendPushRESTHandler
    
    
    /*
    ** init
    ** This function initializes the SendPush library
    ** It hooks into app lifecycle, validates the info.plist settings and registers for push
    */
    init(restHandler: SendPushRESTHandler) {
        
        self.restHandler = restHandler
    }
    
    func registerDevice(deviceToken: String, onSuccess: () -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
        
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
        
        func postHandler (data: NSData?, response: NSURLResponse?, error: NSError?) {
            if let err = error {
                onFailure(statusCode: 500, message: err.description)
            }
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            if (statusCode != 200) {
                onFailure(statusCode: statusCode, message: response!.description)
            } else {
                onSuccess()
            }
        }
        
        restHandler.postBody("/app/devices", body: body, method: "POST", completionHandler: postHandler)
        
    }
    
}
