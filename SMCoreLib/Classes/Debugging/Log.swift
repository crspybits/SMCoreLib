//
//  Log.swift
//  WhatDidILike
//
//  Created by Christopher Prince on 10/5/14.
//  Copyright (c) 2014 Spastic Muffin, LLC. All rights reserved.
//

import Foundation

// See http://stackoverflow.com/questions/24114288/macros-in-swift
// And http://stackoverflow.com/questions/24048430/logging-method-signature-using-swift/31737561#31737561

public class Log {
    // In the default arguments to these functions:
    // 1) If I use a String type, the macros (e.g., __LINE__) don't expand at run time.
    //  "\(__FUNCTION__)\(__FILE__)\(__LINE__)"
    // 2) A tuple type, like,
    // typealias SMLogFuncDetails = (String, String, Int)
    //  SMLogFuncDetails = (__FUNCTION__, __FILE__, __LINE__)
    //  doesn't work either.
    // 3) This String = __FUNCTION__ + __FILE__
    //  also doesn't work.
    
    public class func redirectConsoleLogToDocumentFolder(clearRedirectLog clearRedirectLog:Bool) {
        LogFile.redirectConsoleLogToDocumentFolder(clearRedirectLog)
    }
    
    // That above redirect redirects the stderr, which is not what Swift uses by default:
    // http://ericasadun.com/2015/05/22/swift-logging/
    // http://stackoverflow.com/questions/24041554/how-can-i-output-to-stderr-with-swift
    
    private class func logIt(string:String) {
        if UIDevice.beingDebugged() {
            // When attached to the debugger, print goes to the console.
            print(string)
        } else {
            // When not attached to the debugger, this assumes we've redirected stderr to a file.
            fputs(string, stderr)
        }
    }

    public class func msg(message: String,
        functionName:  String = #function, fileNameWithPath: String = #file, lineNumber: Int = #line ) {

#if DEBUG
        let output = self.formatLogString(message, loggingColor: .Blue, functionName: functionName, fileNameWithPath: fileNameWithPath, lineNumber: lineNumber)
        logIt(output)
#endif
    }
    
    // For use in debugging only. Doesn't log to file. Marks output in red.
    public class func error(message: String,
        functionName:  String = #function, fileNameWithPath: String = #file, lineNumber: Int = #line ) {
#if DEBUG
        let output = self.formatLogString(message, loggingColor: .Red, functionName: functionName, fileNameWithPath: fileNameWithPath, lineNumber: lineNumber)
        logIt(output)
#endif
    }
    
    // For use in debugging only. Doesn't log to file. Marks output in pink. (Yellow on white background is unreadable)
    public class func warning(message: String,
        functionName:  String = #function, fileNameWithPath: String = #file, lineNumber: Int = #line ) {
#if DEBUG
        let output = self.formatLogString(message, loggingColor: .Pink, functionName: functionName, fileNameWithPath: fileNameWithPath, lineNumber: lineNumber)
        logIt(output)
#endif
    }
    
    // For use in debugging only. Doesn't log to file. Marks output in purple.
    public class func special(message: String,
        functionName:  String = #function, fileNameWithPath: String = #file, lineNumber: Int = #line ) {
#if DEBUG
        let output = self.formatLogString(message, loggingColor: .Purple, functionName: functionName, fileNameWithPath: fileNameWithPath, lineNumber: lineNumber)
        logIt(output)
#endif
    }

    private enum SMLoggingColor {
        case Red
        case Yellow // Can't read this on a white background
        case Blue
        case Purple
        case Pink
        case None
    }
    
    private class func formatLogString(message: String, loggingColor:SMLoggingColor,
        functionName:  String, fileNameWithPath: String, lineNumber: Int) -> String {

        let fileNameWithoutPath = (fileNameWithPath as NSString).lastPathComponent
        var possiblyColoredMessage:String
            
        switch (loggingColor) {
            case .Red:
                possiblyColoredMessage = SMColorLog.red(message)
            
            case .Blue:
                possiblyColoredMessage = SMColorLog.blue(message)
            
            case .Yellow:
                possiblyColoredMessage = SMColorLog.yellow(message)
            
            case .Purple:
                possiblyColoredMessage = SMColorLog.purple(message)
            
            case .Pink:
                possiblyColoredMessage = SMColorLog.pink(message)

            case .None:
                possiblyColoredMessage = message
        }
            
        let output = "\(NSDate()): \(possiblyColoredMessage) [\(functionName) in \(fileNameWithoutPath), line \(lineNumber)]"

        return output
    }
    
    // Call this log method when something bad or important has happened.
    public class func file(message: String,
        functionName:  String = #function, fileNameWithPath: String = #file, lineNumber: Int = #line ) {
        
        var output:String
            
#if DEBUG
        // Log this in red because we typically log to a file because something important or bad has happened.
        output = self.formatLogString(message, loggingColor: .Red, functionName: functionName, fileNameWithPath: fileNameWithPath, lineNumber: lineNumber)
        logIt(output)
#endif
        
        output = self.formatLogString(message, loggingColor: .None, functionName: functionName, fileNameWithPath: fileNameWithPath, lineNumber: lineNumber)
        LogFile.write(output + "\n")
    }
}

// From https://github.com/robbiehanson/XcodeColors
// Use this with XcodeColors plugin.

struct SMColorLog {
    static let ESCAPE = "\u{001b}["
    
    static let RESET_FG = ESCAPE + "fg;" // Clear any foreground color
    static let RESET_BG = ESCAPE + "bg;" // Clear any background color
    static let RESET = ESCAPE + ";"   // Clear any foreground or background color
    
    static func red<T>(object:T) -> String {
        return "\(ESCAPE)fg255,0,0;\(object)\(RESET)"
    }
    
    static func green<T>(object:T) -> String {
        return("\(ESCAPE)fg0,255,0;\(object)\(RESET)")
    }
    
    static func blue<T>(object:T) -> String {
        return "\(ESCAPE)fg0,0,255;\(object)\(RESET)"
    }
    
    static func yellow<T>(object:T) -> String {
        return "\(ESCAPE)fg255,255,0;\(object)\(RESET)"
    }
    
    static func purple<T>(object:T) -> String {
        return "\(ESCAPE)fg255,0,255;\(object)\(RESET)"
    }
    
    static func pink<T>(object:T) -> String {
        return "\(ESCAPE)fg255,105,180;\(object)\(RESET)"
    }
    
    static func cyan<T>(object:T) -> String {
        return "\(ESCAPE)fg0,255,255;\(object)\(RESET)"
    }
}