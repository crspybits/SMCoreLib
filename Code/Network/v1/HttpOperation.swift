//
//  HttpOperation.swift
//  WhatDidILike
//
//  Created by Christopher Prince on 9/28/14.
//  Copyright (c) 2014 Spastic Muffin, LLC. All rights reserved.
//

import Foundation

class HttpOperation {
    
    /* Carry out an HTTP GET operation. For a "GET" method, the parameters are sent as part of the URL string.
        e.g., /test/demo_form.asp?name1=value1&name2=value2  
        See http://www.w3schools.com/tags/ref_httpmethods.asp
    */
    func get(url: NSURL, parameters: NSDictionary?,
        extraHeaders: ((request: NSURLRequest?) -> Dictionary<String, String>?)?,
        completion: (NSDictionary?, NSError?) -> ()) -> NetOp?
    {
        var errorResult: NSError?
        
        print("parameters: \(parameters)")
        
        let urlString: String = url.absoluteString
        let request: NSMutableURLRequest!
        do {
            request = try AFHTTPRequestSerializer().requestWithMethod("GET", URLString: urlString, parameters: parameters)
        } catch var error as NSError {
            errorResult = error
            request = nil
        }
        
        Log.msg("extraHeaders: \(extraHeaders)")
        var headers: Dictionary<String, String>?
        
        if (extraHeaders != nil) {
            // Call the extraHeaders function, because it was given.
            headers = extraHeaders!(request: request)
            for (headerField, fieldValue) in headers! {
                request.setValue(fieldValue, forHTTPHeaderField: headerField)
            }
        }
        
        if (nil == request) || (nil != errorResult) {
            completion(nil, Error.Create("Error executing requestWithMethod"))
            return nil
        }

        func successFunc(operation: AFHTTPRequestOperation?, response: AnyObject?) {
            if let responseDict = response as? NSDictionary {
                completion(responseDict, nil)
            } else {
                completion(nil, Error.Create("Response was not a dictionary"))
            }
        }
        
        func failureFunc(operation: AFHTTPRequestOperation?, error: NSError?) {
            completion(nil, error)
        }
        
        // I thought I was having quoting, but it turned out to be a problem with the oauth signature because I wasn't including the final URL from the NSURLRequest.

        let operation = AFHTTPRequestOperation(request: request)
        // 10/5/15; See bridging header. I was having a problem with just AFJSONResponseSerializer()
        operation.responseSerializer = AFJSONResponseSerializer.sharedSerializer()
        operation.setCompletionBlockWithSuccess(successFunc, failure: failureFunc)
        
        operation.start()
        
        let netOp = NetOp(operation: operation)
        return netOp
    }
    
    func get(url: NSURL, parameters: NSDictionary?,
        completion: (NSDictionary?, NSError?) -> ()) -> NetOp?
    {
        return get(url, parameters: parameters, extraHeaders: nil, completion: completion)
    }
}