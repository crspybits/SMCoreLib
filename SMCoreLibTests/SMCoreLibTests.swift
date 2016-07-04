//
//  SMCoreLibTests.swift
//  SMCoreLibTests
//
//  Created by Christopher Prince on 3/17/16.
//  Copyright © 2016 Spastic Muffin, LLC. All rights reserved.
//

import XCTest
import SMCoreLib

class SMCoreLibNSDateExtras: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRetainOnlyUnits() {
        Log.msg("Days: \(NSDate().retainOnlyUnits([.Year, .Month, .Day]))")
        Log.msg("Months: \(NSDate().retainOnlyUnits([.Year, .Month]))")
        Log.msg("Years: \(NSDate().retainOnlyUnits(.Year))")
    }
    
    func testAdd() {
        Log.msg("Day: \(NSDate().add(.Day, amount: 1))")
        Log.msg("Week: \(NSDate().add(.Week, amount: 1))")
        Log.msg("Month: \(NSDate().add(.Month, amount: 1))")
        Log.msg("Year: \(NSDate().add(.Year, amount: 1))")
    }
}
