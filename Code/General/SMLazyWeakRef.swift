//
//  SMLazyWeakRef.swift
//  SMCoreLib
//
//  Created by Christopher Prince on 6/11/16.
//  Copyright © 2016 Spastic Muffin, LLC. All rights reserved.
//

import Foundation

// Similar to the WeakRef type, but with stronger typing and a callback that gets called just before the getter returns the value-- to provide a new value.

public class SMLazyWeakRef<T: AnyObject> {
    private weak var _lazyRef:T?
    
    public weak var lazyRef:T? {
        self._lazyRef = self.willGetCallback()
        return self._lazyRef
    }
    
    private var willGetCallback:(()->(T?))
    
    public init(willGetCallback:(()->(T?))) {
        self.willGetCallback = willGetCallback
    }
}