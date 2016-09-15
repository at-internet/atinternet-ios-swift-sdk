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
//  Touch.swift
//  Tracker
//

import UIKit

public class Gesture: BusinessObject {
    
    /// Gesture actions
    public enum Action: String {
        case Touch = "A"
        case Navigate = "N"
        case Download = "T"
        case Exit = "S"
        case Search = "IS"
    }
    
    /// Touch name
    public var name: String = ""
    /// First chapter
    public var chapter1: String?
    /// Second chapter
    public var chapter2: String?
    /// Third chapter
    public var chapter3: String?
    /// Level 2
    public var level2: Int?
    /// Action
    public var action: Action = Action.Touch
    
    /// Set parameters in buffer
    override func setEvent() {
        if(TechnicalContext.screenName != "") {
            let encodingOption = ParamOption()
            encodingOption.encode = true
            tracker = tracker.setParam(HitParam.TouchScreen.rawValue, value: TechnicalContext.screenName, options: encodingOption)
        }
        
        if(TechnicalContext.level2 > 0) {
            tracker = tracker.setParam(HitParam.TouchLevel2.rawValue, value: TechnicalContext.level2)
        }
        
        if let optLevel2 = level2 {
            self.tracker = self.tracker.setParam("s2", value: optLevel2)
        }
        
        tracker = tracker.setParam("click", value: action.rawValue)
            .event.set("click", action: action.rawValue, label: buildGestureName())
    }
    
    /**
    Send navigation gesture hit
    */
    public func sendNavigation() {
        self.action = Action.Navigate
        self.tracker.dispatcher.dispatch([self])
    }
    
    /**
    Send exit gesture hit
    */
    public func sendExit() {
        self.action = Action.Exit
        self.tracker.dispatcher.dispatch([self])
    }
    
    /**
    Send download gesture hit
    */
    public func sendDownload() {
        self.action = Action.Download
        self.tracker.dispatcher.dispatch([self])
    }
    
    /**
    Send touch gesture hit
    */

    public func sendTouch() {
        self.action = Action.Touch
        self.tracker.dispatcher.dispatch([self])
    }
    
    /**
    Send search gesture hit
    */
    public func sendSearch() {
        self.action = Action.Search
        self.tracker.dispatcher.dispatch([self])
    }
       
       
    //MARK: Touch name building
    func buildGestureName() -> String {
        var touchName = chapter1 == nil ? "" : chapter1! + "::"
        touchName = chapter2 ==  nil ? touchName : touchName + chapter2! + "::"
        touchName = chapter3 ==  nil ? touchName : touchName + chapter3! + "::"
        touchName += name
        
        return touchName
    }
}

public class Gestures {
    /// Tracker instance
    var tracker: Tracker
    
    /**
    Gestures initializer
    - parameter tracker: the tracker instance
    - returns: Gestures instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    /**
    Set a gesture
    - returns: gesture instance
    */
    public func add() -> Gesture {
        let gesture = Gesture(tracker: tracker)
        tracker.businessObjects[gesture.id] = gesture
        
        return gesture
    }
    
    /**
    Set a gesture
    - parameter touch: name
    - returns: gesture instance
    */
    public func add(_ name:String) -> Gesture {
        let gesture = Gesture(tracker: tracker)
        gesture.name = name
        tracker.businessObjects[gesture.id] = gesture
        
        return gesture
    }
    
    /**
    Set a gesture
    - parameter touch: name
    - parameter first: chapter
    - returns: gesture instance
    */
    public func add(_ name: String, chapter1: String) -> Gesture {
        let gesture = Gesture(tracker: tracker)
        gesture.name = name
        gesture.chapter1 = chapter1
        tracker.businessObjects[gesture.id] = gesture
        
        return gesture
    }
    
    /**
    Set a gesture
    - parameter touch: name
    - parameter first: chapter
    - parameter second: chapter
    - returns: gesture instance
    */
    public func add(_ name: String, chapter1: String, chapter2: String) -> Gesture {
        let gesture = Gesture(tracker: tracker)
        gesture.name = name
        gesture.chapter1 = chapter1
        gesture.chapter2 = chapter2
        tracker.businessObjects[gesture.id] = gesture
        
        return gesture
    }
    
    /**
    Set a gesture
    - parameter touch: name
    - parameter first: chapter
    - parameter second: chapter
    - parameter third: chapter
    - returns: gesture instance
    */
    public func add(_ name: String, chapter1: String, chapter2: String, chapter3: String) -> Gesture {
        let gesture = Gesture(tracker: tracker)
        gesture.name = name
        gesture.chapter1 = chapter1
        gesture.chapter2 = chapter2
        gesture.chapter3 = chapter3
        tracker.businessObjects[gesture.id] = gesture
        
        return gesture
    }
}
