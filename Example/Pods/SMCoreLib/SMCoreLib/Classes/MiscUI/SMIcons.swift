//
//  SMIcons.swift
//  SMCoreLib
//
//  Created by Christopher Prince on 6/13/16.
//  Copyright © 2016 Spastic Muffin, LLC. All rights reserved.
//

// Provide access to icons stored in the assets catalog of SMCoreLib

import Foundation

public class SMIcons {
    public static var GoogleIcon:UIImage {
        let bundle = NSBundle(forClass: self)
        return UIImage(named: "GoogleIcon", inBundle: bundle,compatibleWithTraitCollection: nil)!
    }
}