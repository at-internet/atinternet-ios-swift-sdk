/*
This SDK is licensed under the MIT license (MIT)
Copyright (c) 2015- Applied Technologies Internet SAS (registration number B 403 261 258 - Trade and Companies Register of Bordeaux – France)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/





//
//  LifeCycle.swift
//  Tracker
//

import Foundation
import UIKit


/// Life cycle metrics
class LifeCycle {
    /// List of lifecycle metrics
    static var parameters = [String: AnyObject]()
    /// App was launched for the first time
    static var firstLaunch: Bool = false
    /// Indicates whether the app version has changed
    static var appVersionChanged: Bool = false
    // Number of days since last app use
    static var daysSinceLastUse: Int = 0
    /// Check whether lifecycle has already been initialized
    static var isInitialized: Bool = false
    /// Calendar type
    static var calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    
    /// Lifecycle keys
    enum LifeCycleKey: String {
        case FirstLaunch = "ATFirstLaunch"
        case LastUse = "ATLastUse"
        case FirstLaunchDate = "ATFirstLaunchDate"
        case LaunchDayCount = "ATLaunchDayCount"
        case LaunchMonthCount = "ATLaunchMonthount"
        case LaunchWeekCount = "ATLaunchWeekCount"
        case LaunchCount = "ATLaunchCount"
        case LastApplicationVersion = "ATLastApplicationVersion"
        case ApplicationUpdate = "ATApplicationUpdate"
        case LaunchCountSinceUpdate = "ATLaunchCountSinceUpdate"
    }
    
    /**
    Check whether the app has finished launching
    
    :params: a notification
    */
    class func initLifeCycle() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let dateFormatter = NSDateFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.dateFormat = "yyyyMMdd"
        let monthFormatter = NSDateFormatter()
        monthFormatter.calendar = calendar
        monthFormatter.dateFormat = "yyyyMM"
        let weekFormatter = NSDateFormatter()
        weekFormatter.calendar = calendar
        weekFormatter.dateFormat = "yyyyww"
        
        let now = NSDate()
        var lastUse = now
        
        // Not first launch
        if let _ = userDefaults.objectForKey(LifeCycleKey.FirstLaunch.rawValue) as? Int {
            LifeCycle.firstLaunch = false
            
            // Last use
            if let optLastUse = userDefaults.objectForKey(LifeCycleKey.LastUse.rawValue) as? NSDate {
                LifeCycle.daysSinceLastUse = Tool.daysBetweenDates(optLastUse, toDate: now)
                lastUse = optLastUse
            }
            
            // Launch count
            if let launchCount = userDefaults.objectForKey(LifeCycleKey.LaunchCount.rawValue) as? Int {
                userDefaults.setInteger(launchCount + 1, forKey: LifeCycleKey.LaunchCount.rawValue)
            }
            
            // Launches of day
            if let launchDayCount = userDefaults.objectForKey(LifeCycleKey.LaunchDayCount.rawValue) as? Int {
                if(dateFormatter.stringFromDate(lastUse) == dateFormatter.stringFromDate(now)) {
                    userDefaults.setInteger(launchDayCount + 1, forKey: LifeCycleKey.LaunchDayCount.rawValue)
                } else {
                    userDefaults.setInteger(1, forKey: LifeCycleKey.LaunchDayCount.rawValue)
                }
            }
            
            // Launches of week
            if let launchWeekCount = userDefaults.objectForKey(LifeCycleKey.LaunchWeekCount.rawValue) as? Int {
                if(weekFormatter.stringFromDate(lastUse) == weekFormatter.stringFromDate(now)) {
                    userDefaults.setInteger((launchWeekCount + 1), forKey: LifeCycleKey.LaunchWeekCount.rawValue)
                } else {
                    userDefaults.setInteger(1, forKey: LifeCycleKey.LaunchWeekCount.rawValue)
                }
            }
            
            // Launches of month
            if let launchMonthCount = userDefaults.objectForKey(LifeCycleKey.LaunchMonthCount.rawValue) as? Int {
                if(monthFormatter.stringFromDate(lastUse) == monthFormatter.stringFromDate(now)) {
                    userDefaults.setInteger((launchMonthCount + 1), forKey: LifeCycleKey.LaunchMonthCount.rawValue)
                } else {
                    userDefaults.setInteger(1, forKey: LifeCycleKey.LaunchMonthCount.rawValue)
                }
            }
            
            // Application version changed
            if let appVersion = userDefaults.objectForKey(LifeCycleKey.LastApplicationVersion.rawValue) as? String {
                if(appVersion != TechnicalContext.applicationVersion) {
                    LifeCycle.appVersionChanged = true
                    userDefaults.setObject(now, forKey: LifeCycleKey.ApplicationUpdate.rawValue)
                    userDefaults.setInteger(1, forKey: LifeCycleKey.LaunchCountSinceUpdate.rawValue)
                    userDefaults.setObject(TechnicalContext.applicationVersion, forKey: LifeCycleKey.LastApplicationVersion.rawValue)
                } else {
                    if let launchCountSinceUpdate = userDefaults.objectForKey(LifeCycleKey.LaunchCountSinceUpdate.rawValue) as? Int {
                        userDefaults.setInteger(launchCountSinceUpdate + 1, forKey: LifeCycleKey.LaunchCountSinceUpdate.rawValue)
                    }
                }
            }
            
            userDefaults.setObject(now, forKey: LifeCycleKey.LastUse.rawValue)
            // Save user defaults
            userDefaults.synchronize()
        } else {
            LifeCycle.firstLaunchInit()
        }

        
        LifeCycle.isInitialized = true
    }
    
    /**
    Init user defaults on first launch
    */
    class func firstLaunchInit() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let now = NSDate()
        self.firstLaunch = true
       
        
        // If SDK V1 first launch exists
        if let optFirstLaunchDate = userDefaults.objectForKey("firstLaunchDate") as? String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.calendar = calendar
            dateFormatter.dateFormat = "YYYYMMdd"
            let fld = dateFormatter.dateFromString(optFirstLaunchDate)
            
            userDefaults.setObject(fld, forKey: LifeCycleKey.FirstLaunchDate.rawValue)
                    userDefaults.setInteger(0, forKey: LifeCycleKey.FirstLaunch.rawValue)
            
            userDefaults.setObject(nil, forKey: "firstLaunchDate")
            self.firstLaunch = false
            
        } else {
            userDefaults.setInteger(1, forKey: LifeCycleKey.FirstLaunch.rawValue)
            
            // First launch date
            userDefaults.setObject(now, forKey: LifeCycleKey.FirstLaunchDate.rawValue)
        }
        
        // Launch Count update from SDK V1
        if let optLaunchCount = userDefaults.objectForKey("ATLaunchCount") as? Int {
            userDefaults.setInteger(optLaunchCount + 1, forKey: LifeCycleKey.LaunchCount.rawValue)
        } else {
            userDefaults.setInteger(1, forKey: LifeCycleKey.LaunchCount.rawValue)
        }
        
        // Launches of day
        userDefaults.setInteger(1, forKey: LifeCycleKey.LaunchDayCount.rawValue)
        
        // Launches of week
        userDefaults.setInteger(1, forKey: LifeCycleKey.LaunchWeekCount.rawValue)
        
        // Launches of month
        userDefaults.setInteger(1, forKey: LifeCycleKey.LaunchMonthCount.rawValue)
        
        // Application version changed
        userDefaults.setObject(TechnicalContext.applicationVersion, forKey: LifeCycleKey.LastApplicationVersion.rawValue)
        
        // Last use update from SDK V1
        if let optLastUseDate = userDefaults.objectForKey("lastUseDate") as? NSDate  {
            userDefaults.setObject(nil, forKey: "lastUseDate")
            LifeCycle.daysSinceLastUse = Tool.daysBetweenDates(optLastUseDate, toDate: now)
        }
        userDefaults.setObject(now, forKey: LifeCycleKey.LastUse.rawValue)

        
        userDefaults.synchronize()
    }
    
    /**
    Get all lifecycle metrics in a JSON format
    
    - returns: a closure that will return a JSON
    */
    static func getMetrics() -> (() -> String) {
        return {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            if userDefaults.objectForKey(LifeCycleKey.FirstLaunch.rawValue) == nil {
                LifeCycle.firstLaunchInit()
            }
            
            let firstLaunchDate = userDefaults.objectForKey(LifeCycleKey.FirstLaunchDate.rawValue) as! NSDate
            let now = NSDate()
            let dateFormatter = NSDateFormatter()
            dateFormatter.calendar = calendar
            dateFormatter.dateFormat = "yyyyMMdd"

            // First launch
            LifeCycle.parameters["fl"] = (self.firstLaunch ? 1 : 0)
            
            // First launch after update
            LifeCycle.parameters["flau"] = (self.appVersionChanged ? 1 : 0)
            
            // First launch of day
            LifeCycle.parameters["ldc"] = userDefaults.integerForKey(LifeCycleKey.LaunchDayCount.rawValue)
            
            // First launch of week
            LifeCycle.parameters["lwc"] = userDefaults.integerForKey(LifeCycleKey.LaunchWeekCount.rawValue)
            
            // First launch of month
            LifeCycle.parameters["lmc"] = userDefaults.integerForKey(LifeCycleKey.LaunchMonthCount.rawValue)
            
            // Launch count since update
            if let launchCountSinceUpdate = userDefaults.objectForKey(LifeCycleKey.LaunchCountSinceUpdate.rawValue) as? Int {
                LifeCycle.parameters["lcsu"] = launchCountSinceUpdate
            }
            
            // Launch count
            LifeCycle.parameters["lc"] = userDefaults.integerForKey(LifeCycleKey.LaunchCount.rawValue)
            
            // First launch date
            LifeCycle.parameters["fld"] = Int(dateFormatter.stringFromDate(firstLaunchDate))!
            
            // Days since first launch
            LifeCycle.parameters["dsfl"] = Tool.daysBetweenDates(firstLaunchDate, toDate: now)
            
            // Update launch date & days since update
            if let applicationUpdate = userDefaults.objectForKey(LifeCycleKey.ApplicationUpdate.rawValue) as? NSDate {
                LifeCycle.parameters["uld"] = Int(dateFormatter.stringFromDate(applicationUpdate))!
                LifeCycle.parameters["dsu"] = Tool.daysBetweenDates(applicationUpdate, toDate: now)
            }
            
            // Days sinces last use
            LifeCycle.parameters["dslu"] = self.daysSinceLastUse
            
            let json = Tool.JSONStringify(["lifecycle": LifeCycle.parameters], prettyPrinted: false)
            
            LifeCycle.parameters.removeAll(keepCapacity: false)
            
            return json
        }
    }
}