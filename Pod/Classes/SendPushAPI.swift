//
//  SendPush.swift
//  SendPush.co
//
//  Created by SendPush.co on 5/3/15.
//  Copyright (c) 2015 SendPush.co. All rights reserved.
//

import Foundation
import JWT

public class SendPushAPI {

    
    // Instance vars
    var platformID: String?
    var platformSecret: String?
    var apiUrl: String?
   
    init(platformID: String?, platformSecret: String?, apiUrl: String?) {
        self.platformID = platformID
        self.platformSecret = platformSecret
        self.apiUrl = apiUrl
    }
    
    func postBody(url: String, body: NSDictionary, method: String, completionHandler: ( (NSData?, NSURLResponse?, NSError?) -> Void)?) {
        let urlStr = "\(self.apiUrl!)\(url)"

        let url = NSURL(string: urlStr.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        let request = NSMutableURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        
        do {
            let json =  try NSJSONSerialization.dataWithJSONObject(body, options: [])
            let authToken = signRequest(json)
           
            request.HTTPBody = json
            request.HTTPMethod = method
            request.addValue("bearer \(authToken)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = session.dataTaskWithRequest(request, completionHandler: completionHandler!)
            
            task.resume()
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