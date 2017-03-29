//
//  CoreDataTests.swift
//  SMCoreLib
//
//  Created by Christopher Prince on 3/26/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import SMCoreLib
import SMCoreLib_Example

class CoreDataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    let sessionName = "foobar"

    func create() {
        let bundle = Bundle(for: NSClassFromString("CoreData")!)
        
        let coreDataSession = CoreData(options: [
            CoreDataModelBundle: bundle,
            CoreDataBundleModelName: "Example",
            CoreDataSqlliteBackupFileName: "~Example.sqlite",
            CoreDataSqlliteFileName: "Example.sqlite",
            CoreDataPrivateQueue: true
        ]);

        CoreData.registerSession(coreDataSession, forName: sessionName)
        XCTAssert(CoreData.sessionNamed(sessionName).context.concurrencyType == .privateQueueConcurrencyType)
    }
    
    func testCreate() {
        create()
    }
    
    func testSaveContextWithError() {
        create()
        
        _ = CoreData.sessionNamed(sessionName).newObject(withEntityName: "Foobar")
        
        do {
            try CoreData.sessionNamed(sessionName).saveContextWithError()
        } catch {
            XCTFail()
        }
    }
    
    func testSaveContext() {
        create()
        
        _ = CoreData.sessionNamed(sessionName).newObject(withEntityName: "Foobar")
        
        do {
            try CoreData.sessionNamed(sessionName).context.save()
        } catch {
            XCTFail()
        }
    }
}
