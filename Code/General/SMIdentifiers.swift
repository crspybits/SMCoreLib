//
//  SMIdentifiers.swift
//  Catsy
//
//  Created by Christopher Prince on 7/12/15.
//  Copyright (c) 2015 Spastic Muffin, LLC. All rights reserved.
//

// Common identifiers.

import Foundation

// @objc so we can access static properties from Objective-C.
@objc public class SMIdentifiers : NSObject {
    // You can make a subclass that assigns to this.
    public static var _session:SMIdentifiers?
    
    private static var appVersionString:String!
    private static var appBundleIdentifier:String!
    private static var appBuildString:String!

    // Exclusive property of SMShowingHints.swift
    public static let SHOWING_HINTS_FILE = "ShowingHints.dat"
    
    public static let SM_SUPPORT_EMAIL = "support@SpasticMuffin.biz"
    
    public static let LARGE_IMAGE_DIRECTORY = "largeImages"
    public static let SMALL_IMAGE_DIRECTORY = "smallImages"
    
    public class func session() -> SMIdentifiers {
        if self._session == nil {
            self._session = SMIdentifiers()
        }
        return self._session!
    }
    
    public override init() {
        super.init()
        SMIdentifiers.appVersionString = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        SMIdentifiers.appBundleIdentifier = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleIdentifier") as! String
        SMIdentifiers.appBuildString = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
    }
    
    public func APP_BUILD_STRING() -> String {
        return SMIdentifiers.appBuildString
    }
    
    public func APP_VERSION_FLOAT() -> Float {
        return (SMIdentifiers.appVersionString as NSString).floatValue
    }
    
    public func APP_VERSION_STRING() -> String {
        return SMIdentifiers.appVersionString
    }
    
    public func APP_BUNDLE_IDENTIFIER() -> String {
        return SMIdentifiers.appBundleIdentifier
    }
}