//
//  MockSessionAPI.swift
//  Pods
//
//  Created by Bob Axford on 14/12/2015.
//
//

import Foundation

class MockSessionAPI: SessionAPIDelegate {
    
    func startSession(onSuccess: (statusCode: Int, data: NSData?) -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
    
    }
    
    func extendSession(onSuccess: (statusCode: Int, data: NSData?) -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
    
    }
    
}