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
//  Configuration.swift
//  Tracker
//

import UIKit

/// Tracker configuraiton
class Configuration {

    /// Dictionary of configuration parameters
    var parameters = [String: String]()
    
    /// Read only configuration
    class ReadOnlyConfiguration {
        /// Set of all configuration which value cannot be updated
        class var list: Set<String> {
            get {
                return [
                    "atreadonlytest"
//                    "plugins"
                ]
            }
        }
    }
    
    /**
    Init with default configuration set in the tag delivery ui
    
    - returns: a configuration
    */
    init() {
        let bundle = NSBundle(forClass: object_getClass(self))
        let path = bundle.pathForResource("DefaultConfiguration", ofType: "plist")
        if let optPath = path {
            let defaultConf = NSDictionary(contentsOfFile: optPath)
            if let optDefaultConf = defaultConf as? [String: String] {
                parameters = optDefaultConf
            }
        }
    }
    
    /**
    Init with custom configuration
    
    - parameter a: dictionnary containing the custom configuration
    
    - returns: a configuration
    */
    init(customConfiguration: [String: String]) {
        parameters = customConfiguration
    }
}
