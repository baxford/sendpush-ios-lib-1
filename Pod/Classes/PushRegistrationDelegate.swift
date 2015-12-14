//
//  PushNotification.swift
//  Pods
//
//  Created by Bob Axford on 14/12/2015.
//
//

import Foundation
import UIKit

/*
* This protocol conforms to the functions within UIApplication that we need to test
* By extending UIApplication with this protocol, we can mock it out in our tests
*/
protocol PushRegistrationDelegate {
    
    func registerForRemoteNotifications()
    
    func registerUserNotificationSettings(notificationSettings: UIUserNotificationSettings)
    
    
}

/*
* By extending this, it lets us mock UIApplication really easily
*/
extension UIApplication: PushRegistrationDelegate {}