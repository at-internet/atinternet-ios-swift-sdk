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
//  Publisher.swift
//  Tracker
//

import UIKit

public class Publisher : OnAppAd {
    
    /// Campaign identifier
    public var campaignId: String = ""
    
    /// Creation
    public var creation: String?
    
    /// Variant
    public var variant: String?
    
    /// Format
    public var format: String?
    
    /// General placement
    public var generalPlacement: String?
    
    /// Detailed placement
    public var detailedPlacement: String?
    
    /// Advertiser identifier
    public var advertiserId: String?
    
    /// URL
    public var url: String?
    
    /**
    Send publisher touch hit
    */
    public func sendTouch() {
        self.action = Action.Touch
        self.tracker.dispatcher.dispatch([self])
    }
    
    /**
    Send publisher view hit
    */
    public func sendImpression() {
        self.action = Action.View
        self.tracker.dispatcher.dispatch([self])
    }
    
    /// Set parameters in buffer
    override func setEvent() {
        let prefix = "PUB"
        let separator = "-"
        let defaultType = "AT"
        var currentType = ""
        
        var spot = prefix + separator + campaignId + separator
        
        if let creation = creation {
            spot += creation + separator
        } else {
            spot += separator
        }
        
        if let variant = variant {
            spot += variant + separator
        } else {
            spot += separator
        }
        
        if let format = format {
            spot += format + separator
        } else {
            spot += separator
        }
        
        if let generalPlacement = generalPlacement {
            spot += generalPlacement + separator
        } else {
            spot += separator
        }
        
        if let detailedPlacement = detailedPlacement {
            spot += detailedPlacement + separator
        } else {
            spot += separator
        }
        
        if let advertiserId = advertiserId {
            spot += advertiserId + separator
        } else {
            spot += separator
        }
        
        if let url = url {
            spot += url
        }
        
        let positions = Tool.findParameterPosition(HitParam.HitType.rawValue, arrays: self.tracker.buffer.persistentParameters, self.tracker.buffer.volatileParameters)
        
        if(positions.count > 0) {
            for(_, position) in positions.enumerated() {
                if(position.arrayIndex == 0) {
                    currentType = (self.tracker.buffer.persistentParameters[position.index] as Param).value()
                } else {
                    currentType = (self.tracker.buffer.volatileParameters[position.index] as Param).value()
                }
            }
        }
        
        if (currentType != "screen" && currentType != defaultType) {
            self.tracker = self.tracker.setParam(HitParam.HitType.rawValue, value: defaultType)
        }
        
        let option = ParamOption()
        option.append = true
        option.encode = true
        self.tracker = self.tracker.setParam(self.action.rawValue, value: spot, options: option)
        
        if(action == Action.Touch) {
            if(TechnicalContext.screenName != "") {
                let encodingOption = ParamOption()
                encodingOption.encode = true
                _ = tracker.setParam("patc", value: TechnicalContext.screenName, options: encodingOption)
            }
            
            if(TechnicalContext.level2 > 0) {
                _ = tracker.setParam("s2atc", value: TechnicalContext.level2)
            }
        }
    }
}

public class Publishers {
    /// Tracker instance
    var tracker: Tracker
    
    /**
    Publishers initializer
    - parameter tracker: the tracker instance
    - returns: Publishers instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    /**
    Set a publisher
    @param campaignID campaign identifier
    @return the Publisher instance
    */
    public func add(_ campaignId: String) -> Publisher {
        let publisherDetail = Publisher(tracker: self.tracker)
        publisherDetail.campaignId = campaignId
        
        self.tracker.businessObjects[publisherDetail.id] = publisherDetail
        
        return publisherDetail
    }
    
    /**
    Send publisher views hits
    */
    public func sendImpressions() {
        var impressions = [BusinessObject]()
        
        for(_, object) in self.tracker.businessObjects {
            if let pub = object as? Publisher {
                if(pub.action == Publisher.Action.View) {
                    impressions.append(pub)
                }
            }
        }
        
        if(impressions.count > 0) {
            self.tracker.dispatcher.dispatch(impressions)
        }
    }
}
