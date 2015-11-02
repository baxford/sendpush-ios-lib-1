//
//  ViewController.swift
//  Sendpushlib
//
//  Created by Bob Axford on 10/12/2015.
//  Copyright (c) 2015 Bob Axford. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var sendToUsername: UITextField!
    
    @IBOutlet weak var pushContent: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func updateUsername(sender: AnyObject) {
        if let un = username.text {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let tags = ["tag":"value"]
            appDelegate.setUsername(un, tags: tags)
        }
    }
    
    @IBAction func clearUsername(sender: AnyObject) {
        if let un = username.text {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let tags = ["tag":"value"]
            appDelegate.setUsername(un, tags: tags)
        }
    }
    
    @IBAction func sendPushToUsername(sender: AnyObject) {
        if let un = sendToUsername.text {
            if let pushMessage = pushContent.text {
                let appDelegate = UIApplication.sharedApplication().delegate as!AppDelegate
                let tags = ["tag":"value"]
                appDelegate.sendPushToUsername(un, pushMessage: pushMessage)
            }
        }
    }
}

