//
//  SendPushDataDelegate.swift
//  Pods
//
//  Created by Bob Axford on 15/12/2015.
//
//

import Foundation

protocol SendPushDataDelegate {
    
    func getDeviceUniqueId() -> String
    
    func addUser(username: String, tags: [String:String]?, allowMutipleUsersPerDevice: Bool)
    
    func setUserRegistered(username: String)

    func unregisterUser(username: String)
    
    func getUsernames() -> [String]
    
    func getUsernamesAndTags() -> [String:[String:String]]
    
    func optedInPushDeviceToken() -> String?
    
    func setDeviceToken(deviceToken: String)
    
}