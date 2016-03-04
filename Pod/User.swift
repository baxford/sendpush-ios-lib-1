//
//  User.swift
//  Pods
//
//  Created by Bob Axford on 4/03/2016.
//
//

import Foundation

class User {

    let username: String
    let tags: [String:String]
    
    init (username: String, tags: [String:String]) {
        self.username = username
        self.tags = tags
    }
    
}