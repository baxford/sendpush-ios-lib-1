//
//  SendPushData.swift
//  Pods
//
//  Created by Bob Axford on 15/12/2015.
//
//

import Foundation

class SendPushData: SendPushDataDelegate {
    
    let platformID: String
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    
    init(platformID: String) {
        self.platformID = platformID
    }
    
    func storeValue(key: String, value: String) {
        let platformKey = "\(key)_\(platformID)"
        prefs.setValue(value, forKey: platformKey)
    }
    
    func getValue(key: String) -> String? {
        let platformKey = "\(key)_\(platformID)"
        return prefs.stringForKey(platformKey)
    }
    
}