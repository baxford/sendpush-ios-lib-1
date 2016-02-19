//
//  MockUserAPI.swift
//  Pods
//
//  Created by Bob Axford on 14/12/2015.
//
//

import Foundation

class MockUserAPI: UserAPIDelegate {
 
    var username: String?
    var deviceToken: String?
    var respondWithStatus: Int = 200
    var unregisterCalled: Bool = false
    
    /**
     * Register a user
     */
    func registerUser(username: String, deviceToken: String, allowMutipleUsersPerDevice:Bool, tags: [String: String]?, onSuccess: (statusCode: Int, data: NSData?) -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
        self.username = username
        self.deviceToken = deviceToken
        if (respondWithStatus >= 200 && respondWithStatus < 300) {
            onSuccess(statusCode: respondWithStatus, data: nil)
        } else {
            onFailure(statusCode: respondWithStatus, message:"Error")
        }
    }
    
    /**
     * Unregister the current user
     */
    func unregisterUser(username: String, deviceToken: String, onSuccess: (statusCode: Int, data: NSData?) -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
        self.username = nil
        self.deviceToken = nil
        self.unregisterCalled = true
        if (respondWithStatus >= 200 && respondWithStatus < 300) {
            onSuccess(statusCode: respondWithStatus, data: nil)
        } else {
            onFailure(statusCode: respondWithStatus, message:"Error")
        }
    }
    
    func reset() {
        self.username = nil
        self.deviceToken = nil
        self.unregisterCalled = false
    }
}