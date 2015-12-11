//
//  SendPushLib.swift
//  Pods
//
//  Created by Bob Axford on 11/12/2015.
//
//

public protocol SendPushDelegate {
    
    
    /*
    *    This is called by the owning app when they want the user to register for push notifications.
    */
    func requestPush()
    
    /*
    * Called by the owning app when a user has accepted push notifications.
    */
    func registerDevice(deviceToken: NSData!)
    
    
    /*
    * This is called as soon as the username is available (eg at Login)
    */
    func registerUser(username: String, tags: [String: String]?)
    
    /*
    * Unregister the current user
    */
    func unregisterUser()
    
    /*
    * Send a push to the given username
    */
    func sendPushToUsername(username: String, pushMessage: String, tags: [String:String])
    
}