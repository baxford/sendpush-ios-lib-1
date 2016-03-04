//
//  SendPush.swift
//  SendPush.co
//
//  Created by SendPush.co on 5/3/15.
//  Copyright (c) 2015 SendPush.co. All rights reserved.
//

import Foundation
import JWT

public class SendPushRESTHandler {

    
    // Instance vars
    let platformID: String
    let platformSecret: String
    let apiUrl: String
   
    init(apiUrl: String, platformID: String, platformSecret: String) {
        self.platformID = platformID
        self.platformSecret = platformSecret
        self.apiUrl = apiUrl
    }
    
    func postBody(url: String, body: NSData, method: String, onSuccess: (statusCode: Int, data: NSData?) -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
        
        let urlStr = "\(self.apiUrl)\(url)"
        
        let url = NSURL(string: urlStr.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        let request = NSMutableURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        
        func completionHandler (data: NSData?, resp: NSURLResponse?, error: NSError?) {
            if let err = error {
                onFailure(statusCode: 503, message: err.description)
                return
            }
            if let response = resp {
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                if (statusCode >= 200 && statusCode < 300) {
                    onSuccess(statusCode: statusCode, data: data)
                } else {
                    onFailure(statusCode: statusCode, message: response.description)
                }
                return
            } else {
                onFailure(statusCode: 503, message: "No Response from server")
                return
            }
        }
        
        let authToken = signRequest(body)
        
        request.HTTPBody = body
        request.HTTPMethod = method
        request.addValue("bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: completionHandler)
        
        task.resume()
    }
    
    func postBody(url: String, body: NSDictionary, method: String, onSuccess: (statusCode: Int, data: NSData?) -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
        var json: NSData
        do {
            json =  try NSJSONSerialization.dataWithJSONObject(body, options: [])
            self.postBody(url, body: json, method: method, onSuccess: onSuccess, onFailure: onFailure)
        } catch {
            print("SendPush Exception: Serializing json \(error)")
            return
        }

 
        
    }
    
    /*
    This function creates a JWT to authenticate the request.
    It also calculates a sha256 of the request body and includes it as a claim in the JWT called 'hash'
    */
    func signRequest(body: NSData) -> String {
        
        let secret = platformSecret ?? ""
        let sub = platformID ?? ""
        
        let sha256 = body.sha256()
        let hash = sha256!.toHexString()
        return JWT.encode(.HS256(secret)) { builder in
            builder.issuer = "co.sendpush"
            builder.expiration = NSDate(timeIntervalSinceNow: 60)
            builder["sub"] = sub
            builder["hash"] = hash
        }
    }
}