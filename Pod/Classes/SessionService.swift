//
//  SendPushSession.swift
//  Pods
//
//  Created by Bob Axford on 3/12/2015.
//
//
import Foundation
import UIKit

public class SessionService: SessionServiceDelegate {
    
    // intervals at which we post heartbeats - up to max of every 5 mins
    let hearbeatIntervals: [Int]
    var sessionAPI: SessionAPIDelegate
    var heartbeatCount = 0
    var sessionInProgress = false
    var heartbeatActive = false
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    let sendPushData: SendPushDataDelegate
    let debug:Bool
    
    /*
    ** init
    ** This function initializes the SendPush library
    ** It hooks into app lifecycle, validates the info.plist settings and registers for push
    */
    init(restHandler: SendPushRESTHandler, sendPushData: SendPushDataDelegate, intervals: [Int] = [0, 2, 5, 15, 30, 45, 60, 120, 180, 240, 300], debug: Bool = false) {
        self.sendPushData = sendPushData
        self.hearbeatIntervals = intervals
        self.debug = debug
        
        self.sessionAPI = SessionAPI(restHandler: restHandler, sendPushData: sendPushData)
    }
    
    func restartSession() {
        // if we stop the current heartbeat process and start a new one it will start a new session
        self.startHeartbeat()
    }
    
    // MARK: heartbeat
    
    func startHeartbeat() {
        self.heartbeatActive = true
        self.heartbeatCount = 0
        self.sessionInProgress = false
        
        self.beat()
    }
    
    func stopHeartbeat() {
        if (debug) {
            NSLog("Stopping session heartbeat")
        }
        self.heartbeatActive = false
        self.sessionInProgress = false
        // fire off a final call to extendSession
        func successHandler(statusCode: Int, data: NSData?) {
            if (debug) {
                NSLog("Session ended")
            }
        }
        func failureHandler(statusCode: Int, message: String) {
            NSLog("Error in endSession, status: \(statusCode), message: \(message)")
        }
        sessionAPI.extendSession(successHandler, onFailure: failureHandler)
    }
    
    func queueNextHeartbeat() {
        if (heartbeatCount < hearbeatIntervals.count - 1) {
            heartbeatCount += 1
        }
        let backoff = hearbeatIntervals[heartbeatCount]
        let interval = Double(backoff) * 1.0
        if (debug) {
            NSLog("Session heartbeat \(self.heartbeatCount), next at \(interval)")
        }
        if (self.heartbeatActive) {
            delay(interval, closure: { [weak self] () -> () in
                self?.beat()
                })
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_global_queue(priority, 0),
            closure
        )
    }
    
    private func beat() {
        func failureHandler(statusCode: Int, message: String) {
            let msg = sessionInProgress ? "Error in extendSession" :  "Error in startSession"
            //NSLog("\(msg): \(statusCode), message: \(message)")
            
            self.queueNextHeartbeat()
        }
        if (!self.sessionInProgress) {
            func successHandler(statusCode: Int, data: NSData?) {
                if (debug) {
                    NSLog("Session started")
                }
                // set to true so that once the first success (ie startSession) succeeds, from then on we'll call extendSession
                self.sessionInProgress = true
                self.queueNextHeartbeat()
            }
            sessionAPI.startSession(successHandler, onFailure: failureHandler)
        } else {
            func successHandler(statusCode: Int, data: NSData?) {
                if (debug) {
                    NSLog("Session extended")
                }
                self.queueNextHeartbeat()
            }
            sessionAPI.extendSession(successHandler, onFailure: failureHandler)
        }
    }
    
    
}