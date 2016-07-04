//
//  RepeatingTimerTests.swift
//  SMCoreLibTestsTests
//
//  Created by Christopher Prince on 2/14/16.
//  Copyright © 2016 Spastic Muffin, LLC. All rights reserved.
//

import XCTest
@testable import SMCoreLibTests
import SMCoreLib

class RepeatingTimerTests: XCTestCase {
    var expectation1:XCTestExpectation?
    var timer1:RepeatingTimer?
    var timer1Count:Int = 0
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.timer1Count = 0
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Test that a timer expires once and can be cancelled.
    func testThatTimerExpiresOnce() {
        self.expectation1 = self.expectationWithDescription("Timer Expiry")
        
        self.timer1 = RepeatingTimer(interval: 5.0, selector: "timerExpiresOnceAction", andTarget: self)
        self.timer1!.start()
        
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
        func timerExpiresOnceAction() {
            self.timer1!.cancel()
            self.expectation1!.fulfill()
        }
    
    // Test that a timer expires twice and can be cancelled.
    func testThatTimerExpiresTwice() {
        self.expectation1 = self.expectationWithDescription("Timer Expiry")

        self.timer1 = RepeatingTimer(interval: 5.0, selector: "timerExpiresTwiceAction", andTarget: self)
        self.timer1!.start()
        
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
        func timerExpiresTwiceAction() {
            self.timer1Count += 1
            
            if self.timer1Count == 2 {
                self.timer1!.cancel()
                self.expectation1!.fulfill()
            }
            else if self.timer1Count > 2 {
                XCTFail()
            }
        }
    
    // Test that a timer expires once and can be cancelled, when started/cancelled from background thread.
    func testThatTimerExpiresOnceStartedFromBackgroundThread() {
        self.expectation1 = self.expectationWithDescription("Timer Expiry")
        
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.timer1 = RepeatingTimer(interval: 5.0, selector: "timerExpiresOnceStartedFromBackgroundThreadAction", andTarget: self)
            self.timer1!.start()
        })

        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
        func timerExpiresOnceStartedFromBackgroundThreadAction() {
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                self.timer1!.cancel()
                self.expectation1!.fulfill()
            })
        }
    
    // Test that a timer expires twice and can be cancelled, when started/cancelled from background thread.
    func testThatTimerExpiresTwiceStartedFromBackgroundThread() {
        self.expectation1 = self.expectationWithDescription("Timer Expiry")

        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.timer1 = RepeatingTimer(interval: 5.0, selector: "timerExpiresTwiceStartedFromBackgroundThreadAction", andTarget: self)
            self.timer1!.start()
        })
        
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
        func timerExpiresTwiceStartedFromBackgroundThreadAction() {
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                self.timer1Count += 1
                
                if self.timer1Count == 2 {
                    self.timer1!.cancel()
                    self.expectation1!.fulfill()
                }
                else if self.timer1Count > 2 {
                    XCTFail()
                }
            });
        }
}
