# Sendpushlib

[![Version](https://img.shields.io/cocoapods/v/Sendpushlib.svg?style=flat)](http://cocoapods.org/pods/Sendpushlib)
[![License](https://img.shields.io/cocoapods/l/Sendpushlib.svg?style=flat)](http://cocoapods.org/pods/Sendpushlib)
[![Platform](https://img.shields.io/cocoapods/p/Sendpushlib.svg?style=flat)](http://cocoapods.org/pods/Sendpushlib)



## Requirements

## Installation

Sendpushlib is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Sendpushlib"
```
## Configuration

In your Info.plist file, create a Dictionary with a key of 'Sendpush',
then add Keys for APIUrl, PlatformID and PlatformSecret in the info.plist file. 
The value for these should be strings and are available from the 'Manage Platforms' area of the Sendpush admin area.

## Bootstrapping

To bootstrap sendpush, import the library into your AppDelegate:

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

## Registering a device for push notifications

At a suitable place in your application flow, request push notifications from the user:

    
    func registerForPush() {
        // request push notifications
        if let sp = sendpush {
            sp.setupPush()
        }
    }


Once a user has accepted push notifications, you need to register their device token with the sendpush API:
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        if let sp = sendpush {
         sp.registerDevice(deviceToken)
        }
    }

## Registering a Username

When you have access to the current users name (eg on successful login), register this with the sendpush API

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

## Clearing a username

When the user is no longer associated with this device (eg on logging out), de-register their  username with the sendpush API:

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

## Author

Bob Axford, bob@sendpush.co

## License

Sendpushlib is available under the Apache 2.0 license. See the LICENSE file for more info.


## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.