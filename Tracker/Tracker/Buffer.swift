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
//  Buffer.swift
//  Tracker
//

import UIKit

/// Buffer that stores hit parameters
public class Buffer {
    /// Tracker instance
    var tracker: Tracker
    /// Array that contains persistent parameters (context variables, etc.)
    var persistentParameters: [Param]
    /// Array that contains volatile parameters (page, global indicators, etc.)
    var volatileParameters: [Param]
    
    /**
    Buffer initialization
    
    - returns: a buffer instance
    */
    public init(tracker: Tracker) {
        self.tracker = tracker
        persistentParameters = [Param]()
        volatileParameters = [Param]()
        
        addContextVariables()
    }
    
    /**
    Add context variables to the hit
    */
    func addContextVariables() {
        let persistentOption = ParamOption()
        persistentOption.persistent = true
        
        let persistentOptionWithEncoding = ParamOption()
        persistentOptionWithEncoding.persistent = true
        persistentOptionWithEncoding.encode = true
        
        // Add SDK version
        let sdkVersion = TechnicalContext.sdkVersion
        self.persistentParameters.append(Param(key: "vtag", value: {sdkVersion}, type: .string, options: persistentOption))
        // Add Platform type
        self.persistentParameters.append(Param(key: "ptag", value: {"ios"}, type: .string, options: persistentOption))
        // Add device language
        self.persistentParameters.append(Param(key: "lng", value: {TechnicalContext.language}, type: .string, options: persistentOption))
        // Add device information
        let device = TechnicalContext.device
        self.persistentParameters.append(Param(key: "mfmd", value: {device}, type: .string, options: persistentOption))
        // Add OS information
        let operatingSystem = TechnicalContext.operatingSystem
        self.persistentParameters.append(Param(key: "os", value: {operatingSystem}, type: .string, options: persistentOption))
        // Add application identifier
        let applicationIdentifier = TechnicalContext.applicationIdentifier
        self.persistentParameters.append(Param(key: "apid", value: {applicationIdentifier}, type: .string, options: persistentOption))
        // Add application version
        let applicationVersion = TechnicalContext.applicationVersion
        self.persistentParameters.append(Param(key: "apvr", value: {applicationVersion}, type: .string, options: persistentOptionWithEncoding))
        // Add local hour
        self.persistentParameters.append(Param(key: "hl", value: {TechnicalContext.localHour}, type: .string, options: persistentOption))
        // Add screen resolution
        self.persistentParameters.append(Param(key: "r", value: {TechnicalContext.screenResolution}, type: .string, options: persistentOption))
        // Add carrier
        self.persistentParameters.append(Param(key: "car", value: {TechnicalContext.carrier}, type: .string, options: persistentOptionWithEncoding))
        // Add connexion information
        self.persistentParameters.append(Param(key: "cn", value: {TechnicalContext.connectionType.rawValue}, type: .string, options: persistentOptionWithEncoding))
        // Add time stamp for cache
        self.persistentParameters.append(Param(key: "ts", value: {String(format:"%f", Date().timeIntervalSince1970 )}, type: .string, options: persistentOption))
        // Add download SDK source
        self.persistentParameters.append(Param(key: "dls", value: {TechnicalContext.downloadSource(self.tracker)}, type: .string, options: persistentOption))
        // Add unique user id
        self.persistentParameters.append(Param(key: "idclient", value: {TechnicalContext.userId(self.tracker.configuration.parameters["identifier"])}, type: .string, options: persistentOption))
    }
}
