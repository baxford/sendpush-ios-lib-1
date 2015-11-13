//
//  AppDelegate.swift
//  Sendpushlib
//
//  Created by Bob Axford on 10/12/2015.
//  Copyright (c) 2015 Bob Axford. All rights reserved.
//

import UIKit
import Sendpushlib

import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var sendpush: SendPush?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // start Fabric
        Fabric.with([Crashlytics.self])
        // setup the sendpush library
        let sendpush = SendPush.push.bootstrap()

        self.sendpush = sendpush

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // implemented in your application delegate
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        if let sp = sendpush {
         sp.registerDevice(deviceToken)
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError!) {
        print("Couldn't register: \(error)")
    }
    
    // If a push is received while the app is in foreground, alert the user
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]){
        let notifiAlert = UIAlertView()
        if let aps = userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSDictionary {
                if let message = alert["message"] as? NSString {
                    notifiAlert.message = "\"\(message)\"" as String
                }
            } else if let alert = aps["alert"] as? NSString {
                notifiAlert.message = "\"\(alert)\"" as String
            }
        }

        notifiAlert.title = "Received Push"
        
        notifiAlert.addButtonWithTitle("OK")
        notifiAlert.show()
    }
    
    func registerForPush() {
        // request push notifications
        if let sp = sendpush {
            sp.setupPush()
        }
    }

    func setUsername(username: String, tags: [String: String]) {
        if (username.isEmpty) {
            let notifiAlert = UIAlertView()
            notifiAlert.title = "Username Required"
            notifiAlert.message = "Please enter a username"
            notifiAlert.addButtonWithTitle("OK")
            notifiAlert.show()
        } else {
            if let sp = sendpush {
                sp.registerUser(username, tags: tags)
                let notifiAlert = UIAlertView()
                notifiAlert.title = "User Set"
                notifiAlert.message = "User Set to \(username)"
                notifiAlert.addButtonWithTitle("OK")
                notifiAlert.show()
            }
        }
    }
    func clearUsername() {
        if let sp = sendpush {
            sp.unregisterUser()
            let notifiAlert = UIAlertView()
            notifiAlert.title = "User Cleared"
            notifiAlert.message = "User cleared"
            notifiAlert.addButtonWithTitle("OK")
            notifiAlert.show()
        }
    }
    func sendPushToUsername(username: String, pushMessage: String, tags: [String:String]) {
        if (username.isEmpty) {
            let notifiAlert = UIAlertView()
            notifiAlert.title = "Username Required"
            notifiAlert.message = "Please enter a username"
            notifiAlert.addButtonWithTitle("OK")
            notifiAlert.show()
        } else if (pushMessage.isEmpty) {
            let notifiAlert = UIAlertView()
            notifiAlert.title = "Message Required"
            notifiAlert.message = "Please enter a Push Message"
            notifiAlert.addButtonWithTitle("OK")
            notifiAlert.show()
        } else {
            if let sp = sendpush {
                sp.sendPushToUsername(username, pushMessage: pushMessage, tags: tags)
                let notifiAlert = UIAlertView()
                notifiAlert.title = "Push Sent"
                notifiAlert.message = "Push sent: \"\(pushMessage)\""
                notifiAlert.addButtonWithTitle("OK")
                notifiAlert.show()
            }
        }
    }
}

