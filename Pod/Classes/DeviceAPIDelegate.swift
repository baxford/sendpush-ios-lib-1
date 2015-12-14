//
//  DeviceAPIDelegate.swift
//  Pods
//
//  Created by Bob Axford on 11/12/2015.
//
//
import Foundation

protocol DeviceAPIDelegate {
    /**
    * Register a device with sendpush
    */
    func registerDevice(deviceToken: String, onSuccess: (statusCode: Int, data: NSData?) -> Void, onFailure: (statusCode: Int, message: String) -> Void)
}
