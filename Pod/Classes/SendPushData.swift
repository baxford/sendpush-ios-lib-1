//
//  SendPushData.swift
//  Pods
//
//  Created by Bob Axford on 15/12/2015.
//
//

import Foundation

class SendPushData: SendPushDataDelegate {
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    
    init() {

    }
    
    func getDeviceUniqueId() -> String {
        if let deviceId = prefs.stringForKey(SendPushConstants.DEVICE_UNIQUE_ID) {
            return deviceId
        } else {
            let deviceUid = NSUUID().UUIDString
            prefs.setValue(deviceUid, forKey: SendPushConstants.DEVICE_UNIQUE_ID)
            return deviceUid
        }

    }
    func addUser(username: String, tags: [String:String]?, allowMutipleUsersPerDevice: Bool) {
        var userMap: NSMutableDictionary
        if let userData = prefs.objectForKey(SendPushConstants.USERNAMES) as? NSDictionary {
            userMap = userData.mutableCopy() as! NSMutableDictionary
        } else {
            userMap = NSMutableDictionary()
        }
        userMap.setValue(false, forKey: username)
        prefs.setValue(userMap, forKey: SendPushConstants.USERNAMES)
        // set tags as well
        var tagMap: NSMutableDictionary
        if let tagData = prefs.objectForKey(SendPushConstants.USER_TAGS) as? NSDictionary {
            tagMap = tagData.mutableCopy() as! NSMutableDictionary
        } else {
            tagMap = NSMutableDictionary()
        }
        tagMap.setValue(tags, forKey: username)
        prefs.setValue(tagMap, forKey: SendPushConstants.USER_TAGS)

    }
    
    func setUserRegistered(username: String) {
        if let userData = prefs.objectForKey(SendPushConstants.USERNAMES) as? NSDictionary {
            let userMap = userData.mutableCopy() as! NSMutableDictionary
            userMap.setValue(true, forKey: username)
            prefs.setValue(userMap, forKey: SendPushConstants.USERNAMES)
        }
    }
    
    func unregisterUser(username: String) {
        var userMap: NSMutableDictionary
        if let userData = prefs.objectForKey(SendPushConstants.USERNAMES) as? NSDictionary {
            userMap = userData.mutableCopy() as! NSMutableDictionary
        } else {
            userMap = NSMutableDictionary()
        }
        userMap.removeObjectForKey(username)
        prefs.setValue(userMap, forKey: SendPushConstants.USERNAMES)
        // unset tags as well
        var tagMap: NSMutableDictionary
        if let tagData = prefs.objectForKey(SendPushConstants.USER_TAGS) as? NSDictionary {
            tagMap = tagData.mutableCopy() as! NSMutableDictionary
        } else {
            tagMap = NSMutableDictionary()
        }
        tagMap.removeObjectForKey(username)
        prefs.setValue(tagMap, forKey: SendPushConstants.USER_TAGS)
    }
    
    func getUsernames() -> [String] {
        var users = [String]()
        if let userData = prefs.objectForKey(SendPushConstants.USERNAMES) as? NSDictionary {
            for (username, _) in userData {
                users.append(username as! String)
            }
        }
        return users
    }
    func getUsernamesAndTags() -> [String:[String:String]] {
        var result = [String:[String:String]]()
        if let userData = prefs.objectForKey(SendPushConstants.USER_TAGS) as? NSDictionary {
            for (username, tags ) in userData {
                result[username as! String] = tags as! [String:String];
            }
        }
        
        return result
    }
    
    func setDeviceToken(deviceToken: String) {
        prefs.setValue(deviceToken, forKey: SendPushConstants.DEVICE_TOKEN)
    }
    
    func optedInPushDeviceToken() -> String? {
        return prefs.valueForKey(SendPushConstants.DEVICE_TOKEN) as? String
    }
}