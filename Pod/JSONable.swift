//
//  JsonExtension.swift
//  Pods
//
//  Created by Bob Axford on 8/03/2016.
//
//

import Foundation

/*
* Simple protocol to allow marshalling/unmarshalling to/from JSON
*/
protocol JSONable {
    
    init(json: NSDictionary)

    func asJson() -> NSDictionary
}

