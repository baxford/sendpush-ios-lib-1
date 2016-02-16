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
then add Keys for PlatformID and PlatformSecret in the info.plist file. 
The value for these should be strings and are available from the 'Manage Platforms' area of the Sendpush admin area.

## Bootstrapping

To bootstrap sendpush, import the library into your AppDelegate:

import Sendpushlib
    
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var sendpush: SendPush

    override init() {
        // setup the sendpush library
        self.sendpush = SendPush.sharedInstance
        // bootstrap the instance 
        self.sendpush.bootstrap()
        super.init()
    }
    ...
}

## Registering a device for push notifications

At a suitable place in your application flow, request push notifications from the user:
    func registerForPush() {
        // request push notifications
        sendpush.requestPush()
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Now that the user has registered for push, we need to register it with Sendpush
        sendpush.registerDevice(deviceToken)
    }


Once a user has accepted push notifications, you need to register their device token with the sendpush API:
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        if let sp = sendpush {
         sp.registerDevice(deviceToken)
        }
    }

## Registering a Username

When you have access to the current users name (eg on successful login), register this with the sendpush API.

    sendpush.registerUser(username, tags: tags)

If you want to allow more than one user to login on the same device, set allowMutipleUsersPerDevice to true

    sendpush.registerUser(username, tags: tags, allowMutipleUsersPerDevice: true)


## Clearing a username

When the user is no longer associated with this device (eg on logging out), de-register their  username with the sendpush API:

    sendpush.unregisterUser(username)
    
## Author

Bob Axford, bob@sendpush.co

## License

Sendpushlib is available under the Apache 2.0 license. See the LICENSE file for more info.


## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.