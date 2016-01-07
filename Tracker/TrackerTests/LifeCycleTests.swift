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
//  LifeCycleTests.swift
//  Tracker
//

import UIKit
import XCTest

class LifeCycleTests: XCTestCase {

    let userDefaults = NSUserDefaults.standardUserDefaults()
    let dateFormatter = NSDateFormatter()
    var now: String?
    
    override func setUp() {
        super.setUp()
        LifeCycle.parameters = [String: AnyObject]()
        LifeCycle.appVersionChanged = false
        LifeCycle.daysSinceLastUse = 0
        LifeCycle.isInitialized = false
        
        dateFormatter.dateFormat = "yyyyMMdd"
        now = dateFormatter.stringFromDate(NSDate())
        
        userDefaults.removeObjectForKey(LifeCycle.LifeCycleKey.ApplicationUpdate.rawValue)
        userDefaults.removeObjectForKey(LifeCycle.LifeCycleKey.FirstLaunch.rawValue)
        userDefaults.removeObjectForKey(LifeCycle.LifeCycleKey.FirstLaunchDate.rawValue)
        userDefaults.removeObjectForKey(LifeCycle.LifeCycleKey.LastApplicationVersion.rawValue)
        userDefaults.removeObjectForKey(LifeCycle.LifeCycleKey.LastUse.rawValue)
        userDefaults.removeObjectForKey(LifeCycle.LifeCycleKey.LaunchCount.rawValue)
        userDefaults.removeObjectForKey(LifeCycle.LifeCycleKey.LaunchCountSinceUpdate.rawValue)
        userDefaults.removeObjectForKey(LifeCycle.LifeCycleKey.LaunchDayCount.rawValue)
        userDefaults.removeObjectForKey(LifeCycle.LifeCycleKey.LaunchMonthCount.rawValue)
        userDefaults.removeObjectForKey(LifeCycle.LifeCycleKey.LaunchWeekCount.rawValue)
        
        userDefaults.synchronize()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        LifeCycle.parameters = [String: AnyObject]()
        LifeCycle.appVersionChanged = false
        LifeCycle.daysSinceLastUse = 0
        LifeCycle.isInitialized = false
        
        dateFormatter.dateFormat = "yyyyMMdd"
        now = dateFormatter.stringFromDate(NSDate())
        
        userDefaults.removeObjectForKey(LifeCycle.LifeCycleKey.ApplicationUpdate.rawValue)
        userDefaults.removeObjectForKey(LifeCycle.LifeCycleKey.FirstLaunch.rawValue)
        userDefaults.removeObjectForKey(LifeCycle.LifeCycleKey.FirstLaunchDate.rawValue)
        userDefaults.removeObjectForKey(LifeCycle.LifeCycleKey.LastApplicationVersion.rawValue)
        userDefaults.removeObjectForKey(LifeCycle.LifeCycleKey.LastUse.rawValue)
        userDefaults.removeObjectForKey(LifeCycle.LifeCycleKey.LaunchCount.rawValue)
        userDefaults.removeObjectForKey(LifeCycle.LifeCycleKey.LaunchCountSinceUpdate.rawValue)
        userDefaults.removeObjectForKey(LifeCycle.LifeCycleKey.LaunchDayCount.rawValue)
        userDefaults.removeObjectForKey(LifeCycle.LifeCycleKey.LaunchMonthCount.rawValue)
        userDefaults.removeObjectForKey(LifeCycle.LifeCycleKey.LaunchWeekCount.rawValue)
        
        userDefaults.synchronize()
        
        
    }
    
    func testRetrieveSDKV1Lifecycle() {
        let now = NSDate()
        
        let oldLastUse: AnyObject? = userDefaults.objectForKey(LifeCycle.LifeCycleKey.LastUse.rawValue)
        
        XCTAssertNil(oldLastUse, "oldLastUse doit être nil")
        
        userDefaults.setObject("20110201", forKey: "firstLaunchDate")
        userDefaults.setInteger(5, forKey: "ATLaunchCount")
        userDefaults.setObject(now, forKey: "lastUseDate")
        userDefaults.synchronize()
        
        LifeCycle.firstLaunchInit()
        
        XCTAssert(userDefaults.objectForKey("firstLaunchDate") == nil, "firstLaunchDate doit être nil")
        XCTAssert(userDefaults.objectForKey(LifeCycle.LifeCycleKey.FirstLaunch.rawValue) as! Int == 0, "firstLaunch doit être égale à 0")
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYYMMdd"
        XCTAssert((userDefaults.objectForKey(LifeCycle.LifeCycleKey.FirstLaunchDate.rawValue) as! NSDate) == dateFormatter.dateFromString("20110201"), "firstLaunchDate doit être égale à 20110201")
        XCTAssertNotNil(userDefaults.objectForKey(LifeCycle.LifeCycleKey.LastUse.rawValue) as! NSDate, "LastUse ne doit pas etre nil")
        XCTAssert(userDefaults.objectForKey(LifeCycle.LifeCycleKey.LaunchCount.rawValue) as! Int == 6, "LaunchCount doit être égale à 5")
        
    }

    func testFirstLaunchAndFirstScreenHit() {
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["fl"].intValue == 1, "la variable fl doit être égale à 1")
        XCTAssert(json["lifecycle"]["flau"].intValue == 0, "la variable flau doit être égale à 0")
        XCTAssert(json["lifecycle"]["ldc"].intValue == 1, "la variable ldc doit être égale à 1")
        XCTAssert(json["lifecycle"]["lwc"].intValue == 1, "la variable lwc doit être égale à 1")
        XCTAssert(json["lifecycle"]["lmc"].intValue == 1, "la variable lmc doit être égale à 1")
        XCTAssert(json["lifecycle"]["fld"].intValue == Int(now!), "la variable fld doit être égale à aujourd'hui")
        XCTAssert(json["lifecycle"]["dsfl"].intValue == 0, "la variable dsfl doit être égale à 0")
        XCTAssert(json["lifecycle"]["dslu"].intValue == 0, "la variable dslu doit être égale à 0")
        XCTAssert(json["lifecycle"]["lc"].intValue == 1, "la variable lc doit être égale à 1")
    }
    
    func testDaysSinceFirstLaunch() {
        let today = NSDate()
        let dateComponent = NSDateComponents()
        dateComponent.day = -2
        
        let past = NSCalendar.currentCalendar().dateByAddingComponents(dateComponent, toDate: today, options: NSCalendarOptions(rawValue: 0))
        
        // Set first launch date two days in the past
        userDefaults.setInteger(1, forKey: LifeCycle.LifeCycleKey.FirstLaunch.rawValue)
        userDefaults.setObject(past, forKey: LifeCycle.LifeCycleKey.FirstLaunchDate.rawValue)
        userDefaults.synchronize()
        
        _ = Tracker()
    
        let stringData = LifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)

        XCTAssert(json["lifecycle"]["dsfl"].intValue == 2, "la variable dsfl doit être égale à 0")
    }
    
    func testDaysSinceLastUse() {
        let today = NSDate()
        let dateComponent = NSDateComponents()
        dateComponent.day = -10
        
        let past = NSCalendar.currentCalendar().dateByAddingComponents(dateComponent, toDate: today, options: NSCalendarOptions(rawValue: 0))
        
        // Set first launch date two days in the past
        userDefaults.setInteger(1, forKey: LifeCycle.LifeCycleKey.FirstLaunch.rawValue)
        userDefaults.setObject(past, forKey: LifeCycle.LifeCycleKey.FirstLaunchDate.rawValue)
        userDefaults.setObject(past, forKey: LifeCycle.LifeCycleKey.LastUse.rawValue)
        userDefaults.synchronize()
        
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["dslu"].intValue == 10, "la variable dslu doit être égale à 0")
    }
    
    func testLaunchCount() {
        let today = NSDate()
        userDefaults.setInteger(1, forKey: LifeCycle.LifeCycleKey.FirstLaunch.rawValue)
        userDefaults.setObject(today, forKey: LifeCycle.LifeCycleKey.FirstLaunchDate.rawValue)
        userDefaults.setInteger(10, forKey: LifeCycle.LifeCycleKey.LaunchCount.rawValue)
        userDefaults.synchronize()
        
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["lc"].intValue == 11, "la variable lc doit être égale à 11")
    }
    
    func testLaunchDayCount() {
        
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["ldc"].intValue == 1, "la variable ldc doit être égale à 1")
    }
    
    func testLaunchDayCountSinceSameDay() {
        // Set last use to now in the past
        let today = NSDate()
        userDefaults.setInteger(1, forKey: LifeCycle.LifeCycleKey.FirstLaunch.rawValue)
        userDefaults.setObject(today, forKey: LifeCycle.LifeCycleKey.FirstLaunchDate.rawValue)
        userDefaults.setObject(today, forKey: LifeCycle.LifeCycleKey.LastUse.rawValue)
        userDefaults.setObject(5, forKey: LifeCycle.LifeCycleKey.LaunchDayCount.rawValue)
        userDefaults.synchronize()
        
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["ldc"].intValue == 6, "la variable ldc doit être égale à 6")
    }
    
    func testLaunchDayCountSinceLastUseInPast() {
        let today = NSDate()
        let dateComponent = NSDateComponents()
        dateComponent.day = -10
        
        let past = NSCalendar.currentCalendar().dateByAddingComponents(dateComponent, toDate: today, options: NSCalendarOptions(rawValue: 0))
        
        // Set last use 10 days in the past
        userDefaults.setObject(past, forKey: LifeCycle.LifeCycleKey.LastUse.rawValue)
        userDefaults.setObject(5, forKey: LifeCycle.LifeCycleKey.LaunchDayCount.rawValue)
        userDefaults.synchronize()
        
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["ldc"].intValue == 1, "la variable ldc doit être égale à 1")
    }
    
    func testLaunchMonthCount() {
        
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["lmc"].intValue == 1, "la variable ldc doit être égale à 1")
    }
    
    func testLaunchMonthCountSinceSameDay() {
        // Set last use to now in the past
        let today = NSDate()
        userDefaults.setInteger(1, forKey: LifeCycle.LifeCycleKey.FirstLaunch.rawValue)
        userDefaults.setObject(today, forKey: LifeCycle.LifeCycleKey.FirstLaunchDate.rawValue)
        userDefaults.setObject(today, forKey: LifeCycle.LifeCycleKey.LastUse.rawValue)
        userDefaults.setObject(5, forKey: LifeCycle.LifeCycleKey.LaunchMonthCount.rawValue)
        userDefaults.synchronize()
        
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["lmc"].intValue == 6, "la variable lmc doit être égale à 6")
    }
    
    func testLaunchMonthCountSinceLastUseInPast() {
        let today = NSDate()
        let dateComponent = NSDateComponents()
        dateComponent.day = -32
        
        let past = NSCalendar.currentCalendar().dateByAddingComponents(dateComponent, toDate: today, options: NSCalendarOptions(rawValue: 0))
        
        // Set last use 10 days in the past
        userDefaults.setObject(past, forKey: LifeCycle.LifeCycleKey.LastUse.rawValue)
        userDefaults.setObject(5, forKey: LifeCycle.LifeCycleKey.LaunchMonthCount.rawValue)
        userDefaults.synchronize()
        
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["lmc"].intValue == 1, "la variable lmc doit être égale à 1")
    }
    
    func testLaunchWeekCount() {
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["lwc"].intValue == 1, "la variable lwc doit être égale à 1")
    }
    
    func testLaunchWeekCountSinceSameDay() {
        // Set last use to now in the past
        let today = NSDate()
        userDefaults.setInteger(1, forKey: LifeCycle.LifeCycleKey.FirstLaunch.rawValue)
        userDefaults.setObject(today, forKey: LifeCycle.LifeCycleKey.FirstLaunchDate.rawValue)
        userDefaults.setObject(today, forKey: LifeCycle.LifeCycleKey.LastUse.rawValue)
        userDefaults.setObject(5, forKey: LifeCycle.LifeCycleKey.LaunchWeekCount.rawValue)
        userDefaults.synchronize()
        
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["lwc"].intValue == 6, "la variable lwc doit être égale à 6")
    }
    
    func testLaunchWeekCountSinceLastUseInPast() {
        let today = NSDate()
        let dateComponent = NSDateComponents()
        dateComponent.day = -7
        
        let past = NSCalendar.currentCalendar().dateByAddingComponents(dateComponent, toDate: today, options: NSCalendarOptions(rawValue: 0))
        
        // Set last use 10 days in the past
        userDefaults.setObject(past, forKey: LifeCycle.LifeCycleKey.LastUse.rawValue)
        userDefaults.setObject(5, forKey: LifeCycle.LifeCycleKey.LaunchWeekCount.rawValue)
        userDefaults.synchronize()
        
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["lwc"].intValue == 1, "la variable lwc doit être égale à 1")
    }
    
    func testFirstLaunchAfterUpdate() {
        let today = NSDate()
        userDefaults.setInteger(1, forKey: LifeCycle.LifeCycleKey.FirstLaunch.rawValue)
        userDefaults.setObject(today, forKey: LifeCycle.LifeCycleKey.FirstLaunchDate.rawValue)
        userDefaults.setObject("[0.0]", forKey: LifeCycle.LifeCycleKey.LastApplicationVersion.rawValue)
        userDefaults.synchronize()
        
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["flau"].intValue == 1, "la variable flai doit être égale à 1")
        XCTAssert(json["lifecycle"]["uld"].intValue == Int(now!), "la variable uld doit être égale à aujourd'hui")
        XCTAssert(json["lifecycle"]["lcsu"].intValue == 1, "la variable lcsu doit être égale à 1")
        XCTAssert(json["lifecycle"]["dsu"].intValue == 0, "la variable dsu doit être égale à 0")
    }
    
    func testUpdateLaunchCount() {
        let today = NSDate()
        userDefaults.setInteger(1, forKey: LifeCycle.LifeCycleKey.FirstLaunch.rawValue)
        userDefaults.setObject(today, forKey: LifeCycle.LifeCycleKey.FirstLaunchDate.rawValue)
        userDefaults.setObject("", forKey: LifeCycle.LifeCycleKey.LastApplicationVersion.rawValue)
        userDefaults.setInteger(10, forKey: LifeCycle.LifeCycleKey.LaunchCountSinceUpdate.rawValue)
        userDefaults.synchronize()
        
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["lcsu"].intValue == 11, "la variable lcsu doit être égale à 11")
    }
    
    func testDaysSinceUpdate() {
        let today = NSDate()
        let dateComponent = NSDateComponents()
        dateComponent.day = -7
        
        let past = NSCalendar.currentCalendar().dateByAddingComponents(dateComponent, toDate: today, options: NSCalendarOptions(rawValue: 0))
        
        userDefaults.setObject(past, forKey: LifeCycle.LifeCycleKey.ApplicationUpdate.rawValue)
        userDefaults.synchronize()
        
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["dsu"].intValue == 7, "la variable dsu doit être égale à 7")
    }
    
    func testSecondSinceBackground() {
        let now = NSDate()
        let nowWith65 = NSDate().dateByAddingTimeInterval(65)
        let delta = Tool.secondsBetweenDates(now, toDate: nowWith65)
        XCTAssert(delta == 65)
    }
    
    func testUpdateFirstLaunch() {
        _ = Tracker()
        LifeCycle.updateFirstLaunch()
        XCTAssertFalse(LifeCycle.firstLaunch)
    }
    
    func testSwitchSessionIfMoreThan60Seconds() {
        _ = Tracker()
        let nowMinus65 = NSDate().dateByAddingTimeInterval(-65)
        LifeCycle.applicationActive(["sessionBackgroundDuration":"60"])
        let idSession = LifeCycle.sessionId
        
        LifeCycle.timeInBackground = nowMinus65
        LifeCycle.applicationActive(["sessionBackgroundDuration":"60"])
        XCTAssertNotEqual(LifeCycle.sessionId, idSession)
        
    }
    
    func testKeepSessionIfLessThan60Seconds() {
        _ = Tracker()
        let nowMinus65 = NSDate().dateByAddingTimeInterval(-35)
        LifeCycle.applicationActive(["sessionBackgroundDuration":"60"])
        let idSession = LifeCycle.sessionId
        
        LifeCycle.timeInBackground = nowMinus65
        LifeCycle.applicationActive(["sessionBackgroundDuration":"60"])
        XCTAssertEqual(LifeCycle.sessionId, idSession)
        
    }
    
}
