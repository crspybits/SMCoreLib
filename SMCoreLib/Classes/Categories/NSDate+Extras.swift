//
//  NSDate+Extras.swift
//  SMCoreLib
//
//  Created by Christopher Prince on 3/17/16.
//  Copyright © 2016 Spastic Muffin, LLC. All rights reserved.
//

import Foundation

public extension NSDate {
    public enum TimeUnit {
        case Day
        case Week
        case Month
        case Year
    }
    
    // Any units other than those given are discarded in the returned date.
    // Note that units can be passed in an array style, e.g., [.Year, .Month, .Day]
    public func keepOnlyUnits(units:NSCalendarUnit) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(units, fromDate: self)
        return calendar.dateFromComponents(components)!
    }
    
    public func add(timeUnit:TimeUnit, amount:Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let additionalDateComponent = NSDateComponents()
        
        switch timeUnit {
        case .Day:
            additionalDateComponent.day = amount
            
        case .Week:
            additionalDateComponent.weekOfYear = amount

        case .Month:
            additionalDateComponent.month = amount

        case .Year:
            additionalDateComponent.year = amount
        }

        return calendar.dateByAddingComponents(additionalDateComponent, toDate: self, options: NSCalendarOptions(rawValue: 0))!
    }
}
