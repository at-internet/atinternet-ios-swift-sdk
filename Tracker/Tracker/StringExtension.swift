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
//  StringExtension.swift
//  Tracker
//

import Foundation
import UIKit


/// Properties for extending String object
extension String {    
    /// Returns a percent encoded string
    var percentEncodedString: String {
        let toEncodeSet = NSCharacterSet(charactersInString:"! #$@'()*+,/:;=?@[]\"%-.<>\\^_{}|~&").invertedSet
        return self.stringByAddingPercentEncodingWithAllowedCharacters(toEncodeSet)!
    }
    
    /// Returns a percent decoded sgtring
    var percentDecodedString:String {
        if let decodedString = self.stringByRemovingPercentEncoding {
            return decodedString
        } else {
            return ""
        }
    }
    
    var sha256Value: String {
        return Hash.sha256Value("AT" + self)
    }
       
    /// Convert a JSON String to an object
    var parseJSONString: AnyObject? {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        if let jsonData = data {
            // Will return an object or nil if JSON decoding fails
            return try? NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers)
        } else {
            // Lossless conversion of the string was not possible
            return nil
        }
    }
    
    /**
    Removes white spaces inside of a string
    
    - returns: a string
    */
    func removeSpaces() -> String {
        return self.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}