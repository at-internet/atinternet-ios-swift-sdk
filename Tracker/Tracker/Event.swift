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
//  Event.swift
//  Tracker
//

import UIKit

class Event {
    /// Tracker instance
    var tracker: Tracker
    
    /**
    Event initializer
    - parameter tracker: the tracker instance
    - returns: Event instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker;
    }

    
    //MARK: Generic event tracking
    
    /**
    Set a generic event
    
    - parameter a: category of event
    - parameter type: of action
    - parameter label: of the event
    */
    func set(_ category: String, action: String, label: String) -> Tracker {
        return self.set(category, action: action, label: label, value: "{}")
    }
    
    /**
    Set a generic event
    
    - parameter a: category of event
    - parameter type: of action
    - parameter label: of the event
    - parameter an: optional json value
    */
    func set(_ category: String, action: String, label: String, value: String) -> Tracker {
        let encodingOption = ParamOption()
        encodingOption.encode = true
        
        let appendOptionWithEncoding = ParamOption()
        appendOptionWithEncoding.append = true
        appendOptionWithEncoding.encode = true
        
        return self.tracker.setParam(HitParam.HitType.rawValue, value: category)
            .setParam(HitParam.Action.rawValue, value: action)
            .setParam(HitParam.Screen.rawValue, value: label, options:encodingOption)
            .setParam(HitParam.JSON.rawValue, value: value, options: appendOptionWithEncoding)
    }
}
