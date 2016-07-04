//
//  SMPersistVars.swift
//  Catsy
//
//  Created by Christopher Prince on 7/12/15.
//  Copyright (c) 2015 Spastic Muffin, LLC. All rights reserved.
//

// A generalization over NSUserDefaults, and KeyChain (and later, perhaps iCloud) to deal with  variables that persist across launches of an app.

import Foundation

// The different persistent variable types have separate name spaces. I.e., you can use the same name (see init method below) in across user defaults and keychain.
public enum SMPersistVarType {
    case UserDefaults
    case KeyChain
}

private let KEYCHAIN_ACCOUNT = "SMPersistVars"

// Need NSObject inheritance for NSCoding.
public class SMPersistItem : NSObject {
    // if you set isMutable to true in your sublcass, it is important that you implement .mutableCopy if your SMPersistItem subclass has a non-primitive/non-built-in mutable class. E.g., my SMPersistItemDict class uses SMMutableDictionary internally (not NSMutableDictionary). cachedOrArchivedValue makes a .mutableCopy and, if we didn't implement our own mutableCopy method, we'd get an NSMutableDictionary as a result which causes a crash.
    private var isMutable:Bool = false
    
    // Some subclasses have specific archive/unarchive methods.
    private var unarchiveValueMethod:((data:NSData!) -> (AnyObject?))?
    private var archiveValueMethod:((value:AnyObject!) -> (NSData?))?
    
    private  let initialValue:AnyObject!
    
    // 10/31/15; I've introduced this for performance reasons, and specifically for the KeyChain persistence type, but will use it for NS user defaults too just for generality.
    private var _cachedCurrentValue:AnyObject?
    
    public let persistType:SMPersistVarType
    public let name:String

    init(name:String!, initialValue:AnyObject!, persistType type:SMPersistVarType) {
        self.name = name
        self.initialValue = initialValue
        self.persistType = type
        
        Log.msg("type: \(self.persistType); name: \(self.name); initialValue: \(self.initialValue); initialValueType: \(initialValue.dynamicType)")
        
        switch (type) {
        case .UserDefaults:
            SMPersistVars.session().userDefaultNames.insert(name)
            
        case .KeyChain:
            SMPersistVars.session().keyChainNames.insert(name)
        }
    }
    
    // Reset just this value.
    public func reset() {
        switch (self.persistType) {
        case .UserDefaults:
            SMPersistVars.session().resetUserDefaults(self.name)
            
        case .KeyChain:
            SMPersistVars.session().resetKeyChain(self.name)
        }
        
        self._cachedCurrentValue = nil
    }
    
    private func unarchiveValue(data:NSData!) -> AnyObject? {
        var unarchivedValue: AnyObject?
        
        if nil == self.unarchiveValueMethod {
            unarchivedValue = NSKeyedUnarchiver.unarchiveObjectWithData(data)
        }
        else {
            unarchivedValue = self.unarchiveValueMethod!(data: data)
        }
        
        return unarchivedValue
    }
    
    private func archiveValue(value:AnyObject!) -> NSData? {
        var archivedData:NSData?
        
        if nil == self.archiveValueMethod {
            archivedData = NSKeyedArchiver.archivedDataWithRootObject(value)
        }
        else {
            archivedData = self.archiveValueMethod!(value: value)
        }
        
        return archivedData
    }
    
    // [1]. 11/14/15; I changed the return value from NSData? to AnyObject? because v1.2 of Catsy had Int's and Bool's stored in NSUserDefaults for SMDefaultItemInt's and SMDefaultItemBool's. i.e., objectForKey would directly return an Int or Bool (as an NSNumber, I believe).
    private func getPersistentValue() -> AnyObject? {
        var defsStoredValue:AnyObject?

        switch (self.persistType) {
        case .UserDefaults:
            defsStoredValue = NSUserDefaults.standardUserDefaults().objectForKey(self.name)
            
        case .KeyChain:
            defsStoredValue = KeyChain.secureDataForService(self.name, account: KEYCHAIN_ACCOUNT)
        }
        
        return defsStoredValue
    }
    
    private func savePersistentValue(value:AnyObject!) -> Bool {
        let archivedData = self.archiveValue(value)
        if nil == archivedData {
            Log.error("savePersistentValue: Failed")
            return false
        } else {
            self.savePersistentData(archivedData!)
            return true
        }
    }
    
    private func savePersistentData(data:NSData!) {
        switch (self.persistType) {
        case .UserDefaults:
            NSUserDefaults.standardUserDefaults().setObject(data, forKey: self.name)
            SMPersistVars.session().saveUserDefaults()
            
        case .KeyChain:
            KeyChain.setSecureData(data, forService: self.name, account: KEYCHAIN_ACCOUNT)
        }
    }
    
    private var cachedOrArchivedValue:AnyObject? {
        get {
            if self._cachedCurrentValue != nil {
                return self._cachedCurrentValue
            }
            
            var returnValue:AnyObject?
            let persistentValue = self.getPersistentValue()
            
            if (nil == persistentValue) {
                // No value; return the initial value.
                if self.isMutable {
                    // It is important to return a mutable copy here-- because the returned object may get mutated. If we don't return mutable copy, we'll get mutating changes to self.initialValue, which we definitely do not want.
                    returnValue = self.initialValue.mutableCopy()
                }
                else {
                    returnValue = self.initialValue
                }
            }
            else {
                if persistentValue is NSData {
                    let unarchivedValue = self.unarchiveValue(persistentValue! as! NSData)
                    Log.msg("name: \(self.name); \(unarchivedValue); type: \(unarchivedValue.dynamicType)")
                    returnValue = unarchivedValue
                }
                else {
                    // Should be an Int or Bool; see [1] above.
                    Assert.If(!(persistentValue is Bool) && !(persistentValue is Int), thenPrintThisString: "Yikes: don't have an Int or a Bool or NSData!")
                    returnValue = persistentValue
                }
            }
            
            self._cachedCurrentValue = returnValue
            return returnValue
        }
        
        set {
            self.savePersistentValue(newValue)
            self._cachedCurrentValue = newValue
        }
    }
    
    public func print() {
        Log.msg("\(self.cachedOrArchivedValue)")
    }
}

public class SMPersistItemBool : SMPersistItem {
    public init(name:String!, initialBoolValue:Bool!,  persistType:SMPersistVarType) {
        super.init(name: name, initialValue:initialBoolValue, persistType:persistType)
    }
    
    // Current Bool value
    public var boolValue:Bool {
        get {
            return self.cachedOrArchivedValue as! Bool
        }
        
        set {
            self.cachedOrArchivedValue = newValue
        }
    }
    
    public var boolDefault:Bool {
        return self.initialValue as! Bool
    }
}

public class SMPersistItemInt : SMPersistItem {
    public init(name:String!, initialIntValue:Int!,  persistType:SMPersistVarType) {
        super.init(name: name, initialValue:initialIntValue, persistType:persistType)
    }

    // Current Int value
    public var intValue:Int {
        get {
            return self.cachedOrArchivedValue as! Int
        }
        
        set {
            self.cachedOrArchivedValue = newValue
        }
    }
    
    public var intDefault:Int {
        return self.initialValue as! Int
    }
}

public class SMPersistItemString : SMPersistItem {
    public init(name:String!, initialStringValue:String!,  persistType:SMPersistVarType) {
        super.init(name: name, initialValue:initialStringValue, persistType:persistType)
    }
    
    // Current String value
    public var stringValue:String {
        get {
            return self.cachedOrArchivedValue as! String
        }
        
        set {
            self.cachedOrArchivedValue = newValue
        }
    }
    
    public var stringDefault:String {
        return self.initialValue as! String
    }
}

public class SMPersistItemData : SMPersistItem {
    public init(name:String!, initialDataValue:NSData!,  persistType:SMPersistVarType) {
        super.init(name: name, initialValue:initialDataValue, persistType:persistType)
    }

    // Current NSData value
    public var dataValue:NSData {
        get {
            return self.cachedOrArchivedValue as! NSData
        }
        
        set {
            self.cachedOrArchivedValue = newValue
        }
    }
    
    public var dataDefault:NSData {
        return self.initialValue as! NSData
    }
}

// I wanted the SMDefaultItemSet class to be a generic class using Swift sets. But, generics in swift don't play well with NSCoding, so I'm just going to use NSMutableSet instead :(.
// 10/6/15. POSSIBLE ISSUE: I may have an issue here. Suppose you add an object to an SMPersistItemSet which is itself mutable. E.g., an NSMutableDictionary. THEN, you change that object which is already in the mutable set. I am unsure whether or not I will detect this change and flush the change to NSUserDefaults or the KeyChain. It seems unlikely I would detect the change. NEED TO TEST.
public class SMPersistItemSet : SMPersistItem {
    //private var myContext = 0 // Apple says this is needed for KVO
    
    // The sets you give here should have elements abiding by NSCoding. 
    public init(name:String!, initialSetValue:NSMutableSet!, persistType:SMPersistVarType) {
        super.init(name: name, initialValue:initialSetValue, persistType:persistType)
        self.isMutable = true
        
        // Note we're not observing the setValue property directly. See below.
        // Actually, it turns out we don't need this observer *at all* when using the proxy methods below.
        //self.addObserver(self, forKeyPath: "setValueWrapper", options: nil, context: &myContext)
    }
    
    deinit {
        //self.removeObserver(self, forKeyPath: "setValueWrapper", context: &myContext)
    }
    
    // Note that each time this is called/used, it retrieves the value from NSUserDefaults or the KeyChain
    private var theSetValue:NSMutableSet {
        return self.cachedOrArchivedValue as! NSMutableSet
    }
    
    // In order to get a KVO style of access working for mutations to the NSMutableSet (i.e., updates to it, not just changes to the property), I have to use proxy methods.
    // See https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/AccessorConventions.html
    // and https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/SearchImplementation.html
    // http://www.objc.io/issues/7-foundation/key-value-coding-and-observing/
    // The problem here revolves around my use of a setValue getter. This would, more typically, return an NSMutableSet. HOWEVER, then, when the caller adds/removes items to/from the set, the changed set is *not* saved to NSUserDefaults. All of this stuff with proxy methods amounts to getting callbacks when the caller changes the set (and now, proxy, set) returned by the setValue getter.
    
    //MARK: Start proxy methods
    
    // Note that these methods *cannot* be private!!! If they are, the runtime system doesn't find them.
    func countOfSetValueWrapper() -> UInt {
        return UInt(theSetValue.count)
    }
    
    func enumeratorOfSetValueWrapper() -> NSEnumerator {
        return theSetValue.objectEnumerator()
    }
    
    func memberOfSetValueWrapper(object:AnyObject!) -> AnyObject? {
        return theSetValue.member(object)
    }
    
    // For the following two accessors, use the add<Key>Object methods as these are for individual objects; otherwise, the parameter is actually passed as a set.
    func addSetValueWrapperObject(object:AnyObject!) {
        let set = theSetValue
        set.addObject(object)
        self.savePersistentValue(set)
    }
    
    func removeSetValueWrapperObject(object:AnyObject!) {
        let set = theSetValue
        set.removeObject(object)
        self.savePersistentValue(set)
    }
    
    //MARK: End proxy methods

    // It looks like in order to get this called, we needed to implement the above proxy methods. However, now with those proxy methods, I don't need this observer any more.
    /*
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
    }*/
    
    public var setValue:NSMutableSet! {
        get {
            // Return the proxy object. The proxy methods are named as, for example, add<Key>Object where key is SetValueWrapper, which is the key below, but with the first letter capitalized.
            return self.mutableSetValueForKey("setValueWrapper")
        }
        
        set {
            self.cachedOrArchivedValue = newValue
        }
    }
    
    public var setDefault:NSMutableSet {
        return self.initialValue.mutableCopy() as! NSMutableSet
    }
}

// A mutable dictionary, but being consistent with other names in this file.
public class SMPersistItemDict : SMPersistItem, SMMutableDictionaryDelegate {
    
    // The elements of your dictionaries should abide by NSCoding.
    public init(name:String!, initialDictValue:NSDictionary!, persistType:SMPersistVarType) {
        let dict = SMMutableDictionary(dictionary: initialDictValue)
        Log.msg("\(NSStringFromClass(dict.dynamicType))")
        super.init(name: name, initialValue:dict, persistType:persistType)
        dict.delegate = self
        self.isMutable = true
        
        // SMMutableDictionary has specific archive/unarchive methods.
        
        self.archiveValueMethod = { (value:AnyObject!) -> NSData? in
            let dict = value as! SMMutableDictionary
            let data = dict.archive()
            return data
        }
        
        self.unarchiveValueMethod = { (data:NSData!) -> AnyObject? in
            let dict = SMMutableDictionary.unarchiveFromData(data)
            return dict
        }
        
        Log.msg("SMPersistItemDict: name: \(self.name); type: \(self.persistType)")
    }
    
    // MARK: SMMutableDictionaryDelegate method
    
    // I don't really want this to be public but Swift says it has to be -- only for use by the delegate. Pretty please.
    public func dictionaryWasChanged(dictionary:SMMutableDictionary) {
        // dictionary gives the *updated* dictionary that must be saved.
        self.dictValue = dictionary
    }
    
    // MARK: End SMMutableDictionaryDelegate method
    
    public var dictValue:NSMutableDictionary! {
        get {
            let dict = self.cachedOrArchivedValue as! SMMutableDictionary
            Log.msg("\(NSStringFromClass(dict.dynamicType))")
            dict.delegate = self
            return dict
        }
        
        set {
            let dict = SMMutableDictionary(dictionary: newValue)
            dict.delegate = self
            super.cachedOrArchivedValue = dict
        }
    }
    
    public var dictDefault:NSMutableDictionary {
        let dict = SMMutableDictionary(dictionary: self.initialValue as! NSMutableDictionary)
        dict.delegate = self
        return dict
    }
}

public class SMPersistItemArray : SMPersistItem {
    
    // The sets you give here should have elements abiding by NSCoding. 
    public init(name:String!, initialArrayValue:NSMutableArray!, persistType:SMPersistVarType) {
        super.init(name: name, initialValue:initialArrayValue, persistType:persistType)
        self.isMutable = true
    }
    
    // Note that each time this is called/used, it retrieves the value from NSUserDefaults or the KeyChain
    private var theArrayValue:NSMutableArray {
        return self.cachedOrArchivedValue as! NSMutableArray
    }
    
    //MARK: Start proxy methods
    
    // Note that these methods *cannot* be private!!! If they are, the runtime system doesn't find them.
    func countOfArrayValueWrapper() -> UInt {
        return UInt(theArrayValue.count)
    }
    
    func objectInArrayValueWrapperAtIndex(index:UInt) -> AnyObject {
        return theArrayValue.objectAtIndex(Int(index))
    }
    
    // -insertObject:in<Key>AtIndex:
    func insertObject(object: AnyObject, inArrayValueWrapperAtIndex index:UInt) {
        let array = theArrayValue
        array.insertObject(object, atIndex: Int(index))
        self.savePersistentValue(array)
    }
    
    // -removeObjectFrom<Key>AtIndex:
    func removeObjectFromArrayValueWrapperAtIndex(index:UInt) {
        let array = theArrayValue
        array.removeObjectAtIndex(Int(index))
        self.savePersistentValue(array)
    }
    
    //MARK: End proxy methods
    
    public var arrayValue:NSMutableArray {
        get {
            // Return the proxy object. The proxy methods are named as, for example, add<Key>Object where key is SetValueWrapper, which is the key below, but with the first letter capitalized.
            return self.mutableArrayValueForKey("arrayValueWrapper")
        }
        
        set {
            self.cachedOrArchivedValue = newValue
        }
    }
    
    public var arrayDefault:NSMutableArray {
        return self.initialValue.mutableCopy() as! NSMutableArray
    }
}

@objc public class SMPersistVars : NSObject {
    // Singleton class.
    private static let theSession = SMPersistVars()
    
    // I have this as a class function and not a public static property to enable access from Objective-C
    public class func session() -> SMPersistVars {
        return self.theSession
    }
    
    // The names of all the defaults. Just held in RAM so we can do a reset of all of the items stored in NSUserDefaults and KeyChain if needed.
    private var userDefaultNames = Set<String>()
    private var keyChainNames = Set<String>()

    private override init() {
        super.init()
    }
    
    public func reset() {
        for name in self.userDefaultNames {
            self.resetUserDefaults(name)
        }
        
        self.saveUserDefaults()
        
        for name in self.keyChainNames {
            self.resetKeyChain(name)
        }
    }
    
    private func resetUserDefaults(name:String) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(name)
        self.saveUserDefaults()
    }
    
    private func saveUserDefaults() {
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private func resetKeyChain(name:String) {
        if !KeyChain.removeSecureTokenForService(name, account: KEYCHAIN_ACCOUNT) {
            Log.msg("Failed on removeSecureTokenForService: name: \(name); account: \(KEYCHAIN_ACCOUNT)")
        }
    }
}

// NSObject so I can access from Obj-C
public class SMPersistVarTest : NSObject {
#if DEBUG
    static let TEST_BOOL = SMPersistItemBool(name: "TestBool", initialBoolValue:true, persistType: .UserDefaults)
    static let TEST_INT = SMPersistItemInt(name: "TestInt", initialIntValue:0,
        persistType: .UserDefaults)
    static let TEST_SET = SMPersistItemSet(name: "TestSet", initialSetValue:NSMutableSet(), persistType: .UserDefaults)
    static let TEST_STRING = SMPersistItemString(name: "TestString", initialStringValue:"", persistType: .UserDefaults)
    static let TEST_DICT = SMPersistItemDict(name: "TestDict", initialDictValue:[:], persistType: .UserDefaults)
    static let TEST_DICT2 = SMPersistItemDict(name: "TestDict2", initialDictValue:[:], persistType: .UserDefaults)
    
    static let TEST_BOOL_KEYCHAIN = SMPersistItemBool(name: "TestBool", initialBoolValue:true, persistType: .KeyChain)
    static let TEST_INT_KEYCHAIN = SMPersistItemInt(name: "TestInt", initialIntValue:0,
        persistType: .KeyChain)
    static let TEST_SET_KEYCHAIN = SMPersistItemSet(name: "TestSet", initialSetValue:NSMutableSet(), persistType: .KeyChain)
    static let TEST_STRING_KEYCHAIN = SMPersistItemString(name: "TestString", initialStringValue:"", persistType: .KeyChain)
    static let TEST_DICT_KEYCHAIN = SMPersistItemDict(name: "TestDict", initialDictValue:[:], persistType: .KeyChain)
    
    private enum TestType {
        case JustPrint
        case ChangeValues
        case Reset
    }
    
    public class func run() {
        func printValues(messagePrefix:String) {
            print("\(messagePrefix): self.TEST_BOOL.boolValue: \(self.TEST_BOOL.boolValue)")
            print("\(messagePrefix): self.TEST_INT.intValue: \(self.TEST_INT.intValue)")
            print("\(messagePrefix): self.TEST_SET.setValue: \(self.TEST_SET.setValue)")
            print("\(messagePrefix): self.TEST_STRING.stringValue: \(self.TEST_STRING.stringValue)")
            print("\(messagePrefix): self.TEST_DICT.dictValue: \(self.TEST_DICT.dictValue)")
            print("\(messagePrefix): self.TEST_DICT2.dictValue: \(self.TEST_DICT2.dictValue)")

            print("\(messagePrefix): self.TEST_BOOL_KEYCHAIN.boolValue: \(self.TEST_BOOL_KEYCHAIN.boolValue)")
            print("\(messagePrefix): self.TEST_INT_KEYCHAIN.intValue: \(self.TEST_INT_KEYCHAIN.intValue)")
            print("\(messagePrefix): self.TEST_SET_KEYCHAIN.setValue: \(self.TEST_SET_KEYCHAIN.setValue)")
            print("\(messagePrefix): self.TEST_STRING_KEYCHAIN.stringValue: \(self.TEST_STRING_KEYCHAIN.stringValue)")
            print("\(messagePrefix): self.TEST_DICT_KEYCHAIN.dictValue: \(self.TEST_DICT_KEYCHAIN.dictValue)")
        }

        //printValues("before")

        let testType:TestType = .ChangeValues
        
        switch (testType) {
        case .JustPrint:
            break // nop
            
        case .ChangeValues:
            self.TEST_BOOL.boolValue = false
            self.TEST_INT.intValue += 1
            self.TEST_SET.setValue.addObject(NSDate())
            self.TEST_STRING.stringValue = "New user defaults string"
            self.TEST_DICT.dictValue["someKey"] = "someValue"
            self.TEST_DICT2.dictValue["someKey"] = true
            testChangeVar(self.TEST_DICT2)
            Log.msg("\(self.TEST_DICT2.dictValue)")
            self.TEST_BOOL_KEYCHAIN.boolValue = false
            self.TEST_INT_KEYCHAIN.intValue = 10
            self.TEST_SET_KEYCHAIN.setValue.addObject("new")
            self.TEST_STRING_KEYCHAIN.stringValue = "New keychain string"
            self.TEST_DICT_KEYCHAIN.dictValue["someKey"] = "someValue"
            
        case .Reset:
            self.TEST_BOOL.reset()
            self.TEST_INT.reset()
            self.TEST_SET.reset()
            self.TEST_STRING.reset()
            self.TEST_DICT.reset()
            self.TEST_DICT2.reset()
            self.TEST_BOOL_KEYCHAIN.reset()
            self.TEST_INT_KEYCHAIN.reset()
            self.TEST_SET_KEYCHAIN.reset()
            self.TEST_STRING_KEYCHAIN.reset()
            self.TEST_DICT_KEYCHAIN.reset()
        }
        
        printValues("after")
    }
    
    class func testChangeVar(dictVar:SMPersistItemDict) {
        dictVar.dictValue["someKey2"] = true
    }
    
#endif
}