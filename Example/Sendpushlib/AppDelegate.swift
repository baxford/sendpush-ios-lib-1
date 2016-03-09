	//
//  AppDelegate.swift
//  Sendpushlib
//
//  Created by Bob Axford on 10/12/2015.
//  Copyright (c) 2015 Bob Axford. All rights reserved.
//

import UIKit

import Fabric
import Crashlytics

import Sendpushlib
    
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var sendpush: SendPush

    override init() {
        // setup the sendpush library
        self.sendpush = SendPush.sharedInstance
        super.init()
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // start Fabric
        Fabric.with([Crashlytics.self])
        
        return true
    }

    func bootstrapSendPush(prefix:String) {
        // bootstrap sendpush with whatever environment is default
        self.sendpush.bootstrap(prefix)
        self.sendpush.restartSession()
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
        // Now that the user has registered for push, we need to register it with Sendpush
        sendpush.registerDevice(deviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
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
    
    func setSendpushEnvironment(environment: String) {
        
    }
    
    /*
    * Call this when we want to ask our user to accept push notifications (at the right time)
    */
    func registerForPush() {
        // request push notifications
        sendpush.requestPush()
    }

    /*
    * This simulates a user logging in
    */
    func setUsername(username: String, tags: [String: String]) {
        if (username.isEmpty) {
            let notifiAlert = UIAlertView()
            notifiAlert.title = "Username Required"
            notifiAlert.message = "Please enter a username"
            notifiAlert.addButtonWithTitle("OK")
            notifiAlert.show()
        } else {
            var users = [User]()
            if let currentUsers = sendpush.getCurrentUsers() {
                users = currentUsers
            }
            let user = User(username: username, tags: tags)
            var userExists = false
            
            for existingUser in users as [User] {
                if (existingUser.username == user.username) {
                    userExists =  true
                }
            }
            if (!userExists) {
                users.append(user)
            }
            sendpush.setCurrentUsers(users)
            
            let notifiAlert = UIAlertView()
            notifiAlert.title = "User Set"
            notifiAlert.message = "User Set to \(username)"
            notifiAlert.addButtonWithTitle("OK")
            notifiAlert.show()
        }
    }
    
    /*
    * This simulates a user logging out
    */
    func clearUsername(username: String) {
        if (username.isEmpty) {
            let notifiAlert = UIAlertView()
            notifiAlert.title = "Username Required"
            notifiAlert.message = "Please enter a username"
            notifiAlert.addButtonWithTitle("OK")
            notifiAlert.show()
        } else {
            var newUsers = [User]()
            if let currentUsers = sendpush.getCurrentUsers() {
                for existingUser in currentUsers as [User] {
                    if (existingUser.username != username) {
                        newUsers.append(existingUser)
                    }
                }
            }
            sendpush.setCurrentUsers(newUsers)
            let notifiAlert = UIAlertView()
            notifiAlert.title = "User Cleared"
            notifiAlert.message = "User cleared"
            notifiAlert.addButtonWithTitle("OK")
            notifiAlert.show()
        }
    }
    
    /*
    * Simple function to send a push to another username
    */
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
            // set some dummy metadata
            let metadata = ["metaKey": "metaValue"]
            sendpush.sendPushToUsername(username, pushMessage: pushMessage, tags: tags, metadata: metadata)
            let notifiAlert = UIAlertView()
            notifiAlert.title = "Push Sent"
            notifiAlert.message = "Push sent: \"\(pushMessage)\""
            notifiAlert.addButtonWithTitle("OK")
            notifiAlert.show()
        }
    }
}

