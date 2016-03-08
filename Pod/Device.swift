//
//  Device.swift
//  Pods
//
//  Created by Bob Axford on 4/03/2016.
//
//

import Foundation

public class Device: NSObject, JSONable {
    let token: String?
    let uid: String?
    let platform: String?
    let type: String?
    let model: String?
    let timezone: String?
    let language: String?
    
    init(token: String?, uid: String?, platform: String?, type: String?, model: String?, timezone: String?, language: String?) {
        self.token = token
        self.uid = uid
        self.platform = platform
        self.type = type
        self.model = model
        self.timezone = timezone
        self.language = language
    }
    
    public required convenience init(json: NSDictionary) {
        let token = json.valueForKey("token") as? String
        let uid = json.valueForKey("uid") as? String
        let platform = json.valueForKey("platform") as? String
        let type = json.valueForKey("type") as? String
        let model = json.valueForKey("model") as? String
        let timezone = json.valueForKey("timezone") as? String
        let language = json.valueForKey("language") as? String
        self.init(token: token, uid: uid, platform: platform, type: type, model: model, timezone: timezone, language: language)
    }
    
    func asJson() -> NSDictionary {
        let json:NSMutableDictionary = [:]
        json.setValue(token, forKey: "token")
        json.setValue(uid, forKey: "uid")
        json.setValue(platform, forKey: "platform")
        json.setValue(type, forKey: "type")
        json.setValue(model, forKey: "model")
        json.setValue(timezone, forKey: "timezone")
        json.setValue(language, forKey: "language")
        return json
    }
}
