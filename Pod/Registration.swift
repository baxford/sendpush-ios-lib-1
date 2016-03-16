//
//  Registration.swift
//  Pods
//
//  Created by Bob Axford on 4/03/2016.
//
//

import Foundation

public class Registration: NSObject, JSONable {
    let device: Device
    let users: [User]?
    let previousDeviceToken: String?
    
    init(device: Device, users: [User]?, previousDeviceToken: String?) {
        self.device = device
        self.users = users
        self.previousDeviceToken = previousDeviceToken
    }
    
    public required convenience init(json: NSDictionary) {
        let devJson = json.objectForKey("device") as! NSDictionary
        let device = Device(json: devJson)
        let usersJson = json.objectForKey("users") as! NSArray
        var users = Array<User>()
        for userJson in usersJson {
            let userJsonDictionary = userJson as! NSDictionary
            let user = User(json: userJsonDictionary)
            users.append(user)
        }
        let previousDeviceToken = json.valueForKey("previousDeviceToken") as? String
        self.init(device: device, users: users, previousDeviceToken: previousDeviceToken)
        
    }
    
    func asJson() -> NSDictionary {
        let json:NSMutableDictionary = [:]
        let deviceJson = device.asJson()
        var usersJson = Array<NSDictionary>()
        if let anyUsers = self.users {
            for user:User in anyUsers {
                usersJson.append(user.asJson())
            }
            json.setValue(usersJson, forKey: "users")
        }
        json.setValue(deviceJson, forKey: "device")

        json.setValue(previousDeviceToken, forKey: "previousDeviceToken")
        return json
    }
}