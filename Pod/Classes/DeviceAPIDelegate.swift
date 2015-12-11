//
//  DeviceAPIDelegate.swift
//  Pods
//
//  Created by Bob Axford on 11/12/2015.
//
//

protocol DeviceAPIDelegate {
    /**
    * Register a device with sendpush
    */
    func registerDevice(deviceToken: String, onSuccess: () -> Void, onFailure: (statusCode: Int, message: String) -> Void)
}
