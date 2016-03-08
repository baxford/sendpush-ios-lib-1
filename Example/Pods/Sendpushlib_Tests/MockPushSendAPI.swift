//
//  MockSendPushAPI.swift
//  Pods
//
//  Created by Bob Axford on 14/12/2015.
//
//

import Foundation


class MockPushSendAPI: PushSendAPIDelegate {
    
    func sendPushToUsername(username: String, pushMessage: String, tags: [String:String], metadata: [String:String], onSuccess: (statusCode: Int, data: NSData?) -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
   
    }
}