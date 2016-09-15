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
//  Screen.swift
//  Tracker
//

import UIKit

public class ScreenInfo: BusinessObject {
    
}

public class AbstractScreen: BusinessObject {
    
    /// Actions
    public enum Action: String {
        case View = "view"
    }
    
    /// Touch name
    public var name: String = ""
    /// First chapter
    public var chapter1: String?
    /// Second chapter
    public var chapter2: String?
    /// Third chapter
    public var chapter3: String?
    /// Action
    public var action: Action = Action.View
    /// Level 2
    public var level2: Int?
    /// Screen contains cart info
    public var isBasketScreen: Bool = false
    
    /// Set parameters in buffer
    override func setEvent() {
        if let optLevel2 = level2 {
            self.tracker = self.tracker.setParam("s2", value: optLevel2)
        }
        
        if (isBasketScreen) {
            tracker = tracker.setParam("tp", value: "cart")
        }
    }
    
    /**
    Send a screen view event
    */
    public func sendView() {
        self.tracker.dispatcher.dispatch([self])
    }
}

public class Screen: AbstractScreen {
    //MARK: Screen
    /// Set parameters in buffer
    override func setEvent() {
        super.setEvent()
        
        _ = tracker.event.set("screen", action: action.rawValue, label: buildScreenName())
    }
    
    //MARK: Screen name building
    func buildScreenName() -> String {
        var screenName = chapter1 == nil ? "" : chapter1! + "::"
        screenName = chapter2 ==  nil ? screenName : screenName + chapter2! + "::"
        screenName = chapter3 ==  nil ? screenName : screenName + chapter3! + "::"
        screenName += name
        
        return screenName
    }
}

public class DynamicScreen: AbstractScreen {
    
    /// Dynamic screen identifier
    public var screenId: String = ""
    /// Dynamic screen update date
    public var update: Date = Date()
    
    let dateFormatter: DateFormatter = DateFormatter()
    
    /// Set parameters in buffer
    override func setEvent() {
        super.setEvent()
        
        let chapters = buildChapters()
        
        let encodingOption = ParamOption()
        encodingOption.encode = true
        
        if(screenId.characters.count > 255){
            screenId = ""
            tracker.delegate?.warningDidOccur("screenId too long, replaced by empty value")
        }
        
        dateFormatter.dateFormat = "YYYYMMddHHmm"
        dateFormatter.locale = LifeCycle.locale
        
        tracker = tracker.setParam("pchap", value: chapters == nil ? "" : chapters!, options:encodingOption)
            .setParam("pid", value: screenId)
            .setParam("pidt", value: dateFormatter.string(from: update))
            .event.set("screen", action: action.rawValue, label: name)
    }
    
    //MARK: Chapters building
    func buildChapters() -> String? {
        var value: String?
        
        if let optChapter1 = chapter1 {
            value = optChapter1
        }
        
        if let optChapter2 = chapter2 {
            if(value == nil) {
                value = optChapter2
            } else {
                value! += "::" + optChapter2
            }
        }
        
        if let optChapter3 = chapter3 {
            if(value == nil) {
                value = optChapter3
            } else {
                value! += "::" + optChapter3
            }
        }
        
        return value
    }
}

public class Screens {
    /// Tracker instance
    var tracker: Tracker
    
    /**
    Screens initializer
    - parameter tracker: the tracker instance
    - returns: Screens instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    /**
    Set a screen
    - returns: tracker instance
    */
    public func add() -> Screen {
        let screen = Screen(tracker: tracker)
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    /**
    Set a screen
    - parameter screen: name
    - returns: Screen instance
    */
    public func add(_ name:String) -> Screen {
        let screen = Screen(tracker: tracker)
        screen.name = name
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    /**
    Set a screen
    - parameter screen: name
    - parameter first: chapter
    - returns: Screen instance
    */
    public func add(_ name: String, chapter1: String) -> Screen {
        let screen = Screen(tracker: tracker)
        screen.name = name
        screen.chapter1 = chapter1
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    /**
    Set a screen
    - parameter screen: name
    - parameter first: chapter
    - parameter second: chapter
    - returns: Screen instance
    */
    public func add(_ name: String, chapter1: String, chapter2: String) -> Screen {
        let screen = Screen(tracker: tracker)
        screen.name = name
        screen.chapter1 = chapter1
        screen.chapter2 = chapter2
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    /**
    Set a screen
    - parameter screen: name
    - parameter first: chapter
    - parameter second: chapter
    - parameter third: chapter
    - returns: Screen instance
    */
    public func add(_ name: String, chapter1: String, chapter2: String, chapter3: String) -> Screen {
        let screen = Screen(tracker: tracker)
        screen.name = name
        screen.chapter1 = chapter1
        screen.chapter2 = chapter2
        screen.chapter3 = chapter3
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
}

public class DynamicScreens {
    /// Tracker instance
    var tracker: Tracker
    
    /**
    DynamicScreens initializer
    - parameter tracker: the tracker instance
    - returns: DynamicScreens instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    @available(*, deprecated: 2.2.1, message: "Use add(screenId: String, update: NSDate, name: String) instead.")
    public func add(_ screenId: Int, update: Date, name: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = String(screenId)
        screen.update = update
        screen.name = name
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    public func add(_ screenId: String, update: Date, name: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = screenId
        screen.update = update
        screen.name = name
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }

    
    /**
    Set a dynamic screen
    - parameter screen: name
    - parameter first: chapter
    - returns: DynamicScreen instance
    */
    @available(*, deprecated: 2.2.1, message: "Use add(screenId: String, update: NSDate, name: String, chapter1: String) instead.")
    public func add(_ screenId: Int, update: Date,name: String, chapter1: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = String(screenId)
        screen.update = update
        screen.name = name
        screen.chapter1 = chapter1
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    public func add(_ screenId: String, update: Date,name: String, chapter1: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = screenId
        screen.update = update
        screen.name = name
        screen.chapter1 = chapter1
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    /**
    Set a dynamic screen
    - parameter screen: name
    - parameter first: chapter
    - parameter second: chapter
    - returns: DynamicScreen instance
    */
    @available(*, deprecated: 2.2.1, message: "Use add(screenId: String, update: NSDate, name: String, chapter1: String, chapter2: String) instead.")
    public func add(_ screenId: Int, update: Date,name: String, chapter1: String, chapter2: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = String(screenId)
        screen.update = update
        screen.name = name
        screen.chapter1 = chapter1
        screen.chapter2 = chapter2
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    public func add(_ screenId: String, update: Date,name: String, chapter1: String, chapter2: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = screenId
        screen.update = update
        screen.name = name
        screen.chapter1 = chapter1
        screen.chapter2 = chapter2
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    /**
    Set a dynamic screen
    - parameter screen: name
    - parameter first: chapter
    - parameter second: chapter
    - parameter third: chapter
    - returns: DynamicScreen instance
    */
    @available(*, deprecated: 2.2.1, message: "Use add(screenId: String, update: NSDate, name: String, chapter1: String, chapter2: String, chapter3: String) instead.")
    public func add(_ screenId: Int, update: Date,name: String, chapter1: String, chapter2: String, chapter3: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = String(screenId)
        screen.update = update
        screen.name = name
        screen.chapter1 = chapter1
        screen.chapter2 = chapter2
        screen.chapter3 = chapter3
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    public func add(_ screenId: String, update: Date,name: String, chapter1: String, chapter2: String, chapter3: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = screenId
        screen.update = update
        screen.name = name
        screen.chapter1 = chapter1
        screen.chapter2 = chapter2
        screen.chapter3 = chapter3
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
}
