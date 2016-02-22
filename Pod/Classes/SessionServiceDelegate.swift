//
//  SendPushServiceDelegate.swift
//  Pods
//
//  Created by Bob Axford on 14/12/2015.
//
//

import Foundation

protocol SessionServiceDelegate {
    
    func startHeartbeat()
    
    func stopHeartbeat()
    
    func restartSession()
}