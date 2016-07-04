//
//  NetOp.swift
//  WhatDidILike
//
//  Created by Christopher Prince on 9/28/14.
//  Copyright (c) 2014 Spastic Muffin. All rights reserved.
//

// Represents a running AFNetworking operation.

import Foundation

public class NetOp {
    private var operation: AFHTTPRequestOperation
    
    init(operation: AFHTTPRequestOperation) {
        self.operation = operation
    }
    
    func cancel() {
        self.operation.cancel()
    }
}