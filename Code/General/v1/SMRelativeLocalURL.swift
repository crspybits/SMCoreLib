//
//  SMRelativeLocalURL.swift
//  SMCoreLib
//
//  Created by Christopher Prince on 3/21/16.
//  Copyright © 2016 Spastic Muffin, LLC. All rights reserved.
//

import Foundation

//  NSURL subclass to deal with relative local URL's.

public class SMRelativeLocalURL : NSURL {
    // Need the @objc prefix to use the init method below, that has this type as a parameter, from Objective-C.
    @objc public enum BaseURLType : Int {
        case DocumentsDirectory
        case MainBundle
        case NonLocal
    }
    
    private var _localBaseURLType:BaseURLType = .NonLocal
    
    // The file is assumed to be stored in the Documents directory of the app. Upon decoding, the URL is reconsituted based on this assumption. This is because the location of the app in the file system can change with re-installation. See http://stackoverflow.com/questions/9608971/app-updates-nsurl-and-documents-directory

    private class var documentsURL: NSURL {
        get {
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let documentsURL = urls[0]
            return documentsURL
        }
    }
    
    private class var mainBundleURL: NSURL {
        get {
            return NSBundle.mainBundle().bundleURL
        }
    }
    
    // To create a non-local non-relative URL.
    public override init(fileURLWithPath: String) {
        super.init(fileURLWithPath: fileURLWithPath)
    }
    
    // The localBaseType cannot be .NonLocal. Use a fileURLWithPath constructor if you need a non-relative/non-local NSURL.
    public init?(withRelativePath relativePath:String, toBaseURLType localBaseType:BaseURLType) {
        var baseURL:NSURL

        switch localBaseType {
        case .MainBundle:
            baseURL = SMRelativeLocalURL.mainBundleURL

        case .DocumentsDirectory:
            baseURL = SMRelativeLocalURL.documentsURL
            
        case .NonLocal:
            Assert.badMojo(alwaysPrintThisString: "Should not use this for NonLocal")
            baseURL = NSURL()
        }
        
        // This constructor notation is a little odd. "relativeToURL" is the part of the URL on the left.
        super.init(string: relativePath, relativeToURL: baseURL)
        
        self._localBaseURLType = localBaseType
    }

    required public init?(coder aDecoder: NSCoder) {
        let rawValue = aDecoder.decodeObjectForKey("localBaseURLType") as! Int
        self._localBaseURLType = BaseURLType(rawValue: rawValue)!
        
        let relativePath = aDecoder.decodeObjectForKey("relativePath") as! String
        
        switch self._localBaseURLType {
        case .MainBundle:
            super.init(string: relativePath, relativeToURL: SMRelativeLocalURL.mainBundleURL)

        case .DocumentsDirectory:
            super.init(string: relativePath, relativeToURL: SMRelativeLocalURL.documentsURL)
            
        case .NonLocal:
            super.init(coder: aDecoder)
        }
    }
    
    // TODO: See what it will take to make this support secure coding. See Apple's Secure Coding Guide
    public override static func supportsSecureCoding() -> Bool {
        return false
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(self._localBaseURLType.rawValue, forKey: "localBaseURLType")
        aCoder.encodeObject(self.relativePath, forKey: "relativePath")
    }

    required convenience public init(fileReferenceLiteral path: String) {
        fatalError("init(fileReferenceLiteral:) has not been implemented")
    }
}
