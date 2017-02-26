import UIKit
import XCTest
import SMCoreLib

class PlistTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: constructor tests
    
    func testThatNonExistentPlistFileThrowsError() {
        do {
            let _ = try PlistDictLoader(plistFileNameInBundle: "Example.plist")
            XCTFail()
        } catch {
        }
    }
    
    func testThatExistingPlistFileDoesNotThrowError() {
        do {
            let _ = try PlistDictLoader(plistFileNameInBundle: "Test.plist")
        } catch {
            XCTFail()
        }
    }
    
    // MARK: Test `get` with integer values
    
    func testThatNonExistingNonRequiredIntValueIsNotNil() {
        let plist = try! PlistDictLoader(plistFileNameInBundle: "Test.plist")
        XCTAssert(plist.get(varName: "NoIntegerThere", ofType: .intType) == nil)
    }
    
    func testThatExistingNonRequiredIntValueHasRightValue() {
        let plist = try! PlistDictLoader(plistFileNameInBundle: "Test.plist")
        let result = plist.get(varName: "MyInteger", ofType: .intType)
        XCTAssert(result != nil)
        
        if case .intValue(let intResult) = result! {
            XCTAssert(intResult == 100)
        }
        else {
            XCTFail()
        }
    }

    // MARK: Test `get` with string values
    
    func testThatNonExistingNonRequiredStringValueIsNil() {
        let plist = try! PlistDictLoader(plistFileNameInBundle: "Test.plist")
        XCTAssert(plist.get(varName: "NoStringHere") == nil)
    }
    
    func testThatExistingNonRequiredStringValueHasRightValue() {
        let plist = try! PlistDictLoader(plistFileNameInBundle: "Test.plist")
        let result = plist.get(varName: "MyString")
        
        XCTAssert(result != nil)
        
        if case .stringValue(let strResult) = result! {
            XCTAssert(strResult == "Hello World!")
        }
        else {
            XCTFail()
        }
    }
    
    // MARK: Test `getRequired` with integer values

    func testThatNonExistingRequiredIntValueThrowsError() {
        let plist = try! PlistDictLoader(plistFileNameInBundle: "Test.plist")
        
        do {
            let _ = try plist.getRequired(varName: "Foobar", ofType: .intType)
            XCTFail()
        } catch {
        }
    }
    
    func testThatExistingRequiredIntValueHasRightValue() {
        let plist = try! PlistDictLoader(plistFileNameInBundle: "Test.plist")
        let result = try! plist.getRequired(varName: "MyInteger", ofType: .intType)
        
        if case .intValue(let intResult) = result {
            XCTAssert(intResult == 100)
        }
        else {
            XCTFail()
        }
    }
    
    // MARK: Test `getRequired` with string values
    
    func testThatNonExistingRequiredStringValueThrowsError() {
        let plist = try! PlistDictLoader(plistFileNameInBundle: "Test.plist")
        
        do {
            let _ = try plist.getRequired(varName: "Foobar")
            XCTFail()
        } catch {
        }
    }

    func testThatExistingRequiredStringValueHasRightValue() {
        let plist = try! PlistDictLoader(plistFileNameInBundle: "Test.plist")
        let result = try! plist.getRequired(varName: "MyString")
        
        if case .stringValue(let strResult) = result {
            XCTAssert(strResult == "Hello World!")
        }
        else {
            XCTFail()
        }
    }
}
