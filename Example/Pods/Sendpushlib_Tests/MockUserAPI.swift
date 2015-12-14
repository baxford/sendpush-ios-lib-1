//
//  MockUserAPI.swift
//  Pods
//
//  Created by Bob Axford on 14/12/2015.
//
//

import Foundation

class MockUserAPI: UserAPIDelegate {
 
    /**
     * Register a user
     */
    func registerUser(username: String, deviceToken: String, tags: [String: String]?, onSuccess: (statusCode: Int, data: NSData?) -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
        
    }
    
    /**
     * Unregister the current user
     */
    func unregisterUser(username: String, deviceToken: String, onSuccess: (statusCode: Int, data: NSData?) -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
        
    }
    
}