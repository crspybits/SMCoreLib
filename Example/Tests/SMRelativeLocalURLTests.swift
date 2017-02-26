//
//  SMRelativeLocalURLTests.swift
//  SMCoreLib
//
//  Created by Christopher Prince on 2/25/17.
//  Copyright © 2017 Spastic Muffin, LLC. All rights reserved.
//

import XCTest
import SMCoreLib

class SMRelativeLocalURLTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func tesArchivingAndUnarchiving() {
        let url1 = SMRelativeLocalURL(withRelativePath: "foobar", toBaseURLType: .documentsDirectory)!
        let data = NSKeyedArchiver.archivedData(withRootObject: url1)
        let url2 = NSKeyedUnarchiver.unarchiveObject(with: data) as? SMRelativeLocalURL
        XCTAssert(url2 != nil)
    }
}
