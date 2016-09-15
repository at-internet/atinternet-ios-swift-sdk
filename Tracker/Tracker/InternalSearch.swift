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
//  InternalSearch.swift
//  Tracker
//

import UIKit

public class InternalSearch: BusinessObject {
    /// Searched keywords
    public var keyword: String = ""
    /// Number of page result
    public var resultScreenNumber: Int = 1
    /// Position of result in list
    public var resultPosition: Int?
    
    /// Set parameters in buffer
    override func setEvent() {
        tracker = tracker.setParam("mc", value: keyword)
        tracker = tracker.setParam("np", value: resultScreenNumber)
        
        if(resultPosition != nil) {
            tracker = tracker.setParam("mcrg", value: resultPosition!)
        }
    }
}

public class InternalSearches {
    /// Tracker instance
    var tracker: Tracker
    
    /**
    InternalSearches initializer
    - parameter tracker: the tracker instance
    - returns: InternalSearches instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    /**
    Set a internal search
    - parameter keywordLabel: keyword search
    - parameter resultPageNumber: page number result
    - returns: InternalSearch instance
    */
    public func add(_ keyword: String, resultScreenNumber: Int) -> InternalSearch {
        let search = InternalSearch(tracker: tracker)
        search.keyword = keyword
        search.resultScreenNumber = resultScreenNumber
        tracker.businessObjects[search.id] = search
        
        return search
    }
    
    /**
    Set a internal search
    - parameter keywordLabel: keyword search
    - parameter resultPageNumber: page number result
    - parameter resultPosition: result position
    - returns: InternalSearch instance
    */
    public func add(_ keyword: String, resultScreenNumber: Int, resultPosition: Int) -> InternalSearch {
        let search = add(keyword, resultScreenNumber: resultScreenNumber)
        search.resultPosition = resultPosition
        
        return search
    }
}
