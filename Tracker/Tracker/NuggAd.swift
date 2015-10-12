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
//  NuggAd.swift
//  Tracker
//

import UIKit

public class NuggAd: BusinessObject {
    let key = "nuggad"
    lazy public var data: [String: AnyObject] = [String: AnyObject]()
    
    /// Set parameters in buffer
    override func setEvent() {
        if let optPlugin = self.tracker.configuration.parameters["plugins"] {
            if (optPlugin.rangeOfString("nuggad") != nil) {
                let option = ParamOption()
                option.append = true
                option.encode = true
                self.tracker.setParam("stc", value: [self.key: self.data], options:option)
            }
            else {
                self.tracker.delegate?.warningDidOccur("NuggAd not enabled")
            }
        } else {
            self.tracker.delegate?.warningDidOccur("NuggAd not enabled")
        }
    }
}

public class NuggAds {
    /// Tracker instance
    var tracker: Tracker
    
    /**
    NuggAds initializer
    - parameter tracker: the tracker instance
    - returns: NuggAds instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    /**
    Set NuggAd data
    - parameter data: NuggAd response data
    - returns: NuggAd instance
    */
    public func add(data: [String: AnyObject]) -> NuggAd {        
        let ad = NuggAd(tracker: tracker)
        ad.data = data
        tracker.businessObjects[ad.id] = ad
        
        return ad
    }
}
