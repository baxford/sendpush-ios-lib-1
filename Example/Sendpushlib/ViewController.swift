//
//  ViewController.swift
//  Sendpushlib
//
//  Created by Bob Axford on 10/12/2015.
//  Copyright (c) 2015 Bob Axford. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate,  UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var username: UITextField!

    @IBOutlet weak var sendToUsername: UITextField!

    @IBOutlet weak var pushContent: UITextField!

    @IBOutlet weak var badge: UITextField!

    @IBOutlet weak var environment: UIPickerView!
    
    var environmentData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        username.delegate=self
        sendToUsername.delegate=self
        pushContent.delegate=self
        badge.delegate=self
        environment.delegate = self
        environment.dataSource = self
        environmentData = ["development", "test", "staging", "production"]
//        environmentData = ["staging", "production"]
        //check if we have a previous selection for environment
        let prefs = NSUserDefaults.standardUserDefaults()
        var selectedEnv: Int
//        if let index = prefs.objectForKey("sp_environment") {
//            selectedEnv = index as! Int
//        } else {
            // default to staging and remember this
            selectedEnv = 0
            prefs.setValue(selectedEnv, forKey: "sp_environment")
//        }
        environment.selectRow(selectedEnv, inComponent: 0, animated: true)
        let env = environmentData[selectedEnv]
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.bootstrapSendPush(env)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return environmentData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return environmentData[row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let env = environmentData[row]
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.bootstrapSendPush(env)
        
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
        if let un = username.text {
            appDelegate.clearUsername(un)
        }
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
}

