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
//  TechnicalContext.swift
//  Tracker
//

import UIKit
import CoreTelephony

/// Contextual information from user device
class TechnicalContext {
    
    enum ConnexionType: String {
        case
        offline = "offline",
        gprs = "gprs",
        edge = "edge",
        twog = "2g",
        threeg = "3g",
        threegplus = "3g+",
        fourg = "4g",
        wifi = "wifi",
        unknown = "unknown"
    }
    
    /// Name of the last tracked screen
    static var screenName: String = ""
    /// ID of the last level2 id set in parameters
    static var level2: Int = 0
    
    /// Enable or disable tracking
    class var doNotTrack: Bool {
        get {
            let userDefaults = UserDefaults.standard
            
            if (userDefaults.object(forKey: "ATDoNotTrack") == nil) {
                return false
            } else {
                return userDefaults.bool(forKey: "ATDoNotTrack")
            }
        } set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue, forKey: "ATDoNotTrack")
            userDefaults.synchronize()
        }
    }
    
    /// Unique user id
    class func userId(_ identifier: String?) -> String {
        
        if(!self.doNotTrack) {
            
            let uuid: () -> String = {
                if UserDefaults.standard.object(forKey: "ATIdclient") != nil {
                    return UserDefaults.standard.object(forKey: "ATIdclient") as! String
                } else if UserDefaults.standard.object(forKey: "ATApplicationUniqueIdentifier") == nil {
                    let UUID = Foundation.UUID().uuidString
                    UserDefaults.standard.set(UUID, forKey: "ATApplicationUniqueIdentifier")
                    UserDefaults.standard.synchronize()
                    return UUID
                } else {
                    return UserDefaults.standard.object(forKey: "ATApplicationUniqueIdentifier") as! String
                }
            }
            
            if let optIdentifier = identifier {
                switch(optIdentifier.lowercased())
                {
                case "idfv":
                    return UIDevice.current.identifierForVendor!.uuidString
                default:
                    return uuid()
                }
            } else {
                return uuid()
            }
            
        } else {
            
            return "opt-out"
            
        }
        
    }
    
    /// SDK Version
    class var sdkVersion: String {
        get {
            if let optInfoDic = Bundle(for: Tracker.self).infoDictionary {
                return optInfoDic["CFBundleShortVersionString"] as! String
            } else {
                return ""
            }
        }
    }
    
    /// Device language (eg. en_US)
    class var language: String {
        get {
            return Locale.autoupdatingCurrent.identifier.lowercased()
        }
    }
    
    /// Device type (eg. [apple]-[iphone3,1]
    class var device: String {
        get {
            var size : Int = 0
            sysctlbyname("hw.machine", nil, &size, nil, 0)
            var machine = [CChar](repeating: 0, count: Int(size))
            sysctlbyname("hw.machine", &machine, &size, nil, 0)
            return String(format: "[%@]-[%@]", "apple", String.init(cString: machine).lowercased())
        }
    }
    
    /// Device OS (name + version)
    class var operatingSystem: String {
        get {
            return String(format: "[%@]-[%@]", UIDevice.current.systemName.removeSpaces().lowercased(), UIDevice.current.systemVersion)
        }
    }
    
    /// Application identifier (eg. com.atinternet.testapp)
    class var applicationIdentifier: String {
        get {
            let identifier = Bundle.main.infoDictionary!["CFBundleIdentifier"] as? String
            
            if let optIdentifier = identifier {
                return String(format:"%@", optIdentifier)
            } else {
                return ""
            }
        }
    }
    
    /// Application version (eg. [5.0])
    class var applicationVersion: String {
        get {
            let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
            
            if let optVersion = version {
                return String(format:"[%@]", optVersion)
            } else {
                return ""
            }
        }
    }
    
    /// Local hour (eg. 23x59x59)
    class var localHour: String {
        get {
            let hourFormatter = DateFormatter()
            hourFormatter.locale = LifeCycle.locale
            hourFormatter.dateFormat = "HH'x'mm'x'ss"
            
            return hourFormatter.string(from: Date())
        }
    }
    
    /// Screen resolution (eg. 1024x768)
    class var screenResolution: String {
        get {
            let screenBounds = UIScreen.main.bounds
            let screenScale = UIScreen.main.scale
            
            return String(format:"%ix%i", Int(screenBounds.size.width * screenScale), Int(screenBounds.size.height * screenScale))
        }
    }
    
    /// Carrier
    class var carrier: String {
        get {
            let networkInfo = CTTelephonyNetworkInfo()
            let provider = networkInfo.subscriberCellularProvider
            
            if let optProvider = provider {
                let carrier = optProvider.carrierName
                
                if carrier != nil {
                    return carrier!
                }
            } else {
                return ""
            }
            
            return ""
        }
    }
    
    /// Download Source
    class func downloadSource(_ tracker: Tracker) -> String {
        if let optDls = tracker.configuration.parameters["downloadSource"] {
            return optDls
        } else {
            return "ext"
        }
    }

    
    
    /// Connexion type (3G, 4G, Edge, Wifi ...)
    class var connectionType: ConnexionType {
        get {
            let reachability = Reachability.reachabilityForInternetConnection()
            
            if let optReachability = reachability {
                if(optReachability.currentReachabilityStatus == Reachability.NetworkStatus.ReachableViaWiFi) {
                    return ConnexionType.wifi
                } else if(optReachability.currentReachabilityStatus == Reachability.NetworkStatus.NotReachable) {
                    return ConnexionType.offline
                } else {
                    let telephonyInfo = CTTelephonyNetworkInfo()
                    let radioType = telephonyInfo.currentRadioAccessTechnology
                    
                    if(radioType != nil) {
                        switch(radioType!) {
                        case CTRadioAccessTechnologyGPRS:
                            return ConnexionType.gprs
                        case CTRadioAccessTechnologyEdge:
                            return ConnexionType.edge
                        case CTRadioAccessTechnologyCDMA1x:
                            return ConnexionType.twog
                        case CTRadioAccessTechnologyWCDMA:
                            return ConnexionType.threeg
                        case CTRadioAccessTechnologyCDMAEVDORev0:
                            return ConnexionType.threeg
                        case CTRadioAccessTechnologyCDMAEVDORevA:
                            return ConnexionType.threeg
                        case CTRadioAccessTechnologyCDMAEVDORevB:
                            return ConnexionType.threeg
                        case CTRadioAccessTechnologyeHRPD:
                            return ConnexionType.threegplus
                        case CTRadioAccessTechnologyHSDPA:
                            return ConnexionType.threegplus
                        case CTRadioAccessTechnologyHSUPA:
                            return ConnexionType.threegplus
                        case CTRadioAccessTechnologyLTE:
                            return ConnexionType.fourg
                        default:
                            return ConnexionType.unknown
                        }
                    } else {
                        return ConnexionType.unknown
                    }
                }
            } else {
                return ConnexionType.unknown
            }
            
            
        }
    }
}
