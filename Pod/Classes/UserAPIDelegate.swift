//
//  UserAPIDelegate.swift
//  Pods
//
//  Created by Bob Axford on 11/12/2015.
//
//

protocol UserAPIDelegate {
    
    /**
    * Register a user
    */
    func registerUser(username: String, deviceToken: String, tags: [String: String]?, onSuccess: () -> Void, onFailure: (statusCode: Int, message: String) -> Void)
    
    /**
    * Unregister the current user
    */
    func unregisterUser(onSuccess: () -> Void, onFailure: (statusCode: Int, message: String) -> Void)
}

