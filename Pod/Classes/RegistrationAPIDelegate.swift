//
//  RegistrationAPIDelegate.swift
//  Pods
//
//  Created by Bob Axford on 4/03/2016.
//
//

import Foundation


protocol RegistrationAPIDelegate {
    
    /**
     * Register a user
     */
    func register(deviceToken: String, registration: Registration, onSuccess: (statusCode: Int, data: NSData?) -> Void, onFailure: (statusCode: Int, message: String) -> Void)
   
}
