//
//  MockPushRegistrationDelegate.swift
//  Pods
//
//  Created by Bob Axford on 14/12/2015.
//
//

import Foundation
import UIKit

class MockPushRegistrationDelegate: PushRegistrationDelegate {
    private(set) public var didRegister = false
    private(set) public var notificationSettings: UIUserNotificationSettings?
    
    func registerForRemoteNotifications() {
        didRegister = true
    }
    
    func registerUserNotificationSettings(notificationSettings: UIUserNotificationSettings) {
        self.notificationSettings = notificationSettings
    }
}