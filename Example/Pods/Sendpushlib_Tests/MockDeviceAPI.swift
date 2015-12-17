//
//  MockDeviceAPI.swift
//  Pods
//
//  Created by Bob Axford on 14/12/2015.
//
//

import Foundation

class MockDeviceAPI: DeviceAPIDelegate {
    
    var deviceToken: String?
    var respondWithStatus: Int = 200
    
    func registerDevice(deviceToken: String, onSuccess: (statusCode: Int, data: NSData?) -> Void, onFailure: (statusCode: Int, message: String) -> Void) {
        self.deviceToken = deviceToken
        if (respondWithStatus >= 200 && respondWithStatus < 300) {
            onSuccess(statusCode: respondWithStatus, data: nil)
        } else {
            onFailure(statusCode: respondWithStatus, message:"Error")
        }
    }
    
    func reset() {
        self.deviceToken = nil
    }
}