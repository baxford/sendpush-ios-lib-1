//
//  SendPushData.swift
//  Pods
//
//  Created by Bob Axford on 15/12/2015.
//
//

import Foundation
import UIKit

class SendPushData: SendPushDataDelegate {
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    
    init() {
        
    }
    
    func getDevice() -> Device {
        let model = UIDevice.currentDevice().model
        let devType = UIDevice.currentDevice().systemName
        let tz = NSTimeZone.localTimeZone().abbreviation as String!
        let langId = NSLocale.preferredLanguages().first as String!
        let device = Device(
            token: self.optedInPushDeviceToken(),
            uid: self.getDeviceUniqueId(),
            platform: "ios",
            type: devType,
            model: model,
            timezone: tz,
            language: langId
        )
        return device
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
    
    func getUsernames() -> [String]? {
        var usernames = [String]()
        if let users = self.getUsers() {
            for user in users {
                if let username = user.username {
                    usernames.append(username)
                }
            }
        }
        return usernames
    }
    
    func getUsers() -> [User]? {
        if let usersJson = prefs.valueForKey(SendPushConstants.USERS) as? NSArray {
            var users = Array<User>()
            for userJson:AnyObject in usersJson {
                if let uj = userJson as? NSDictionary {
                    users.append(User(json: uj))
                }
            }
            return users
        }
        
        return nil
    }
    
    func setUsers(users: [User]) {
        var usersJson = NSMutableArray()
        for user:User in users {
            usersJson.addObject(user.asJson())
        }
        prefs.setValue(usersJson, forKey: SendPushConstants.USERS)
    }
    
    func setDeviceToken(deviceToken: String) {
        prefs.setValue(deviceToken, forKey: SendPushConstants.DEVICE_TOKEN)
    }
    
    func optedInPushDeviceToken() -> String? {
        return prefs.valueForKey(SendPushConstants.DEVICE_TOKEN) as? String
    }
}