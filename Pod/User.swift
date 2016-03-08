//
//  User.swift
//  Pods
//
//  Created by Bob Axford on 4/03/2016.
//
//

import Foundation

public class User: NSObject, JSONable {

    let username: String?
    let tags: [String:String]?
    
    public init (username: String?, tags: [String: String]?) {
        self.username = username
        self.tags = tags
    }
    
    public required convenience init(json: NSDictionary) {
        let username = json.valueForKey("username") as! String?
        let tags = json.valueForKey("tags") as! [String:String]?
        self.init(username: username, tags: tags)
    }
    
    func asJson() -> NSDictionary {
        let json:NSMutableDictionary = [:]
        
        json.setValue(self.username, forKey: "username")
        json.setValue(self.tags, forKey: "tags")

        return json
    }
    
}