//
//  JsonExtension.swift
//  Pods
//
//  Created by Bob Axford on 8/03/2016.
//
//

import Foundation

protocol JSONable {
    
    init(json: NSDictionary)

    func asJson() -> NSDictionary
}

