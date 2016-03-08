//
//  SendPushLib.swift
//  Pods
//
//  Created by Bob Axford on 11/12/2015.
//
//

import Foundation

public protocol SendPushDelegate {
    
    
    /*
    * called to restart the current users session
    */
    func restartSession()
    
    /*
    *    This is called by the owning app when they want the user to register for push notifications.
    */
    func requestPush()
    
    /*
    * Called by the owning app when a user has accepted push notifications.
    */
    func registerDevice(deviceToken: NSData!)
    
    /*
    * Set the current usernames
    */
    func setCurrentUsers(username: [User])
    
    /*
    * Send a push to the given username
    */
    func sendPushToUsername(username: String, pushMessage: String, tags: [String:String], metadata: [String:String])
    
}