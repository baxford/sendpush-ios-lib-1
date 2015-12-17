//
//  SendPushDataDelegate.swift
//  Pods
//
//  Created by Bob Axford on 15/12/2015.
//
//

import Foundation

protocol SendPushDataDelegate {
    
    func storeValue(key: String, value: String)

    func getValue(key: String) -> String?
}