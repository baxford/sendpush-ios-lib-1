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
    
    func setUsers(users: [User])
    
    func getUsers() -> [User]?

    func getUsernames() -> [String]?
    
    func optedInPushDeviceToken() -> String?
    
    func setDeviceToken(deviceToken: String)
    
    func getDevice() -> Device
    
}