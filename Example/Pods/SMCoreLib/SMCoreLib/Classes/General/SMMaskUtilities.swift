//
//  SMMaskUtilities.swift
//  SMCoreLib
//
//  Created by Christopher Prince on 6/16/16.
//  Copyright © 2016 Spastic Muffin, LLC. All rights reserved.
//

import Foundation

public class SMMaskUtilities {
    public static func enumDescription(rawValue rawValue:Int, allAsStrings: [String]) -> String {
        var shift = 0
        while (rawValue >> shift != 1) {
            shift += 1
        }
        return allAsStrings[shift]
    }
    
    public static func maskDescription(stringArray stringArray:[String]) -> String {
        var result = ""

        for value in stringArray {
            result += (result.characters.count == 0) ? value : ",\(value)"
        }

        return "[\(result)]"
    }
    
    // An array of strings, possibly empty.
    public static func maskArrayOfStrings
        <StructType: OptionSetType, EnumType: RawRepresentable where EnumType.RawValue == Int>
        (maskObj:StructType, contains:(maskObj:StructType, enumValue:EnumType)-> Bool) -> [String] {
        
        var result = [String]()
        var shift = 0

        while let enumValue = EnumType(rawValue: 1 << shift) {
            shift += 1
            if contains(maskObj: maskObj, enumValue: enumValue) {
                result.append("\(enumValue)")
            }
        }

        return result
    }
}
