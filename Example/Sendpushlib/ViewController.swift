//
//  ViewController.swift
//  Sendpushlib
//
//  Created by Bob Axford on 10/12/2015.
//  Copyright (c) 2015 Bob Axford. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var username: UITextField!

    @IBOutlet weak var sendToUsername: UITextField!

    @IBOutlet weak var pushContent: UITextField!

    @IBOutlet weak var badge: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        username.delegate=self
        sendToUsername.delegate=self
        pushContent.delegate=self
        badge.delegate=self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func registerForPush(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.registerForPush()
    }

    @IBAction func updateUsername(sender: AnyObject) {
        if let un = username.text {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let tags = ["tag":"value"]
            appDelegate.setUsername(un, tags: tags)
        }
    }
    
    @IBAction func clearUsername(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.clearUsername()
    }
    
    @IBAction func sendPushToUsername(sender: AnyObject) {
        var badgeVal = "0"
        if let bv = badge.text {
            badgeVal = bv
        }
        if let un = sendToUsername.text {
            if let pushMessage = pushContent.text {
                let appDelegate = UIApplication.sharedApplication().delegate as!AppDelegate
                let tags = ["badge":badgeVal]
                appDelegate.sendPushToUsername(un, pushMessage: pushMessage, tags: tags)
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
}

