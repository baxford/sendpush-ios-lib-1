//
//  UserAPI.swift
//  Pods
//
//  Created by Bob Axford on 11/12/2015.
//
//

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
        
        var body = [String: String]()
        
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
        
        restHandler.postBody(urlStr, body: body, method: "PUT", completionHandler: postHandler)
        
    }
    
    func unregisterUser(onSuccess: () -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
        let prefs = NSUserDefaults.standardUserDefaults()
        
        if let username = prefs.stringForKey(SendPushConstants.USERNAME) as String?, let token = prefs.stringForKey(SendPushConstants.DEVICE_TOKEN) as String? {
            
            let urlStr = "/app/users/\(username)/\(token)"
            let url = NSURL(string: urlStr)
            
            var body = [String: String]()
            
            func postHandler (data: NSData?, response: NSURLResponse?, error: NSError?) {
                if let err = error {
                    onFailure(statusCode: -1, message: err.description)

                    return
                }
                print("Response: \(response)")
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                if (statusCode != 200) {
                    onFailure(statusCode: statusCode, message: response!.description)
                } else {
                    onSuccess()
                }
            }
            restHandler.postBody(urlStr, body: body, method: "DELETE", completionHandler: postHandler)
        }
        
    }

}
