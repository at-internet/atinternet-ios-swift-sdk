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
//  Tracker.swift
//  Tracker
//

import UIKit
import CoreData


/// Build or send status of the hit
public enum HitStatus {
    case failed
    case success
}

/// Standard parameters
public enum HitParam: String {
    case Screen = "p"
    case Level2 = "s2"
    case JSON = "stc"
    case UserID = "idclient"
    case HitType = "type"
    case Action = "action"
    case Touch = "click"
    case TouchScreen = "pclick"
    case TouchLevel2 = "s2click"
    case VisitorIdentifierNumeric = "an"
    case VisitorIdentifierText = "at"
    case VisitorCategory = "ac"
    case BackgroundMode = "bg"
    case OnAppAdsTouch = "atc"
    case OnAppAdsImpression = "ati"
    case GPSLatitude = "gy"
    case GPSLongitude = "gx"
}

/// Background modes
public enum BackgroundMode {
    case normal
    case task
    case fetch
}

// MARK: - Tracker Delegate

/// Tracker's delegate
public protocol TrackerDelegate: class {
    
    /**
    First launch of the tracker
    
    - parameter message: approval message for confidentiality
    */
    func trackerNeedsFirstLaunchApproval(_ message: String)
    
    /**
    Building of hit done
    
    - parameter status: result of hit building
    - parameter message: info about hit building
    */
    func buildDidEnd(_ status: HitStatus, message: String)
    
    /**
    Sending of hit done
    
    - parameter status: sending result
    - parameter message: information about sending result
    */
    func sendDidEnd(_ status: HitStatus, message: String)
    
    /**
    Saving of hit done (offline)
    
    - parameter message: information about saving result
    */
    func saveDidEnd(_ message: String)
    
    /**
    Partner call done
    
    - parameter response: the response received from the partner
    */
    func didCallPartner(_ response: String)
    
    /**
    Received a warning message (does not stop hit sending)
    
    - parameter message: the warning message
    */
    func warningDidOccur(_ message: String)
    
    /**
    Received an error message (stop hit sending)
    
    - parameter message: the error message
    */
    func errorDidOccur(_ message: String)
    
}

// MARK: - Tracker

/// Wrapper class for tracking usage of your application
public class Tracker {
    
    internal weak var _delegate: TrackerDelegate? = nil
    
    /// Tracker's delegate
    public var delegate: TrackerDelegate? {
        get {
            return _delegate
        }
        set {
            _delegate = newValue
            if LifeCycle.firstSession {
                _delegate?.trackerNeedsFirstLaunchApproval("Tracker first launch")
            }
        }
    }
    
    /// Contains tracker configuration
    var configuration: Configuration
    
    /// Contains parameters
    lazy var buffer: Buffer = Buffer(tracker: self)
    
    /// Dispatcher
    lazy var dispatcher: Dispatcher = Dispatcher(tracker: self)
        
    /// Debugger
    public var debugger: UIViewController? {
        get {
            return Debugger.sharedInstance.viewController;
        }
        set {
            Debugger.sharedInstance.viewController = newValue
        }
    }
    
    internal lazy var businessObjects: [String: BusinessObject] = [String: BusinessObject]()
    
    //MARK: Offline
    private(set) public lazy var offline: Offline = Offline(tracker: self)
    
    //MARK: Context Tracking
    /// Context tracking
    private(set) public lazy var context: Context = Context(tracker: self)
    
    //MARK: NuggAd Tracking
    /// NuggAd tracking
    private(set) public lazy var nuggAds: NuggAds = NuggAds(tracker: self)
    
    //MARK: GPS Tracking
    /// GPS tracking
    private(set) public lazy var locations: Locations = Locations(tracker: self)
    
    //MARK: Publisher Tracking
    /// Publisher tracking
    private(set) public lazy var publishers: Publishers = Publishers(tracker: self)
    
    //MARK: SelfPromotion Tracking
    /// SelfPromotion tracking
    private(set) public lazy var selfPromotions: SelfPromotions = SelfPromotions(tracker: self)
    
    //MARK: Identified Visitor Tracking
    /// Identified visitor tracking
    private(set) public lazy var identifiedVisitor: IdentifiedVisitor = IdentifiedVisitor(tracker: self)
    
    //MARK: Screen Tracking
    /// Screen tracking
    private(set) public lazy var screens: Screens = Screens(tracker: self)
    
    //MARK: Dynamic Screen Tracking
    /// Dynamic Screen tracking
    private(set) public lazy var dynamicScreens: DynamicScreens = DynamicScreens(tracker: self)
    
    //MARK: Touch Tracking
    /// Touch tracking
    private(set) public lazy var gestures: Gestures = Gestures(tracker: self)
    
    //MARK: Custom Object Tracking
    private(set) public lazy var customObjects: CustomObjects = CustomObjects(tracker: self)
    
    //MARK: TV Tracking
    private(set) public lazy var tvTracking: TVTracking = TVTracking(tracker: self)
    
    //MARK: Event Tracking
    /// Event tracking
    private(set) lazy var event: Event = Event(tracker: self)
    
    //MARK: CustomVar Tracking
    /// CustomVar tracking
    private(set) public lazy var customVars: CustomVars = CustomVars(tracker: self)
    
    //MARK: Order Tracking
    /// Order tracking
    private(set) public lazy var orders: Orders = Orders(tracker: self)
    
    //MARK: Aisle Tracking
    /// Aisle tracking
    private(set) public lazy var aisles: Aisles = Aisles(tracker: self)
    
    //MARK: Cart Tracking
    /// Cart tracking
    private(set) public lazy var cart: Cart = Cart(tracker: self)
    
    //MARK: Product Tracking
    /// Product tracking
    private(set) public lazy var products: Products = Products(tracker: self)
    
    //MARK: Campaign Tracking
    /// Campaign tracking
    private(set) public lazy var campaigns: Campaigns = Campaigns(tracker: self)
    
    //MARK: Internal Search Tracking
    /// Internal Search tracking
    private(set) public lazy var internalSearches: InternalSearches = InternalSearches(tracker: self)
    
    //MARK: Custom tree structure Tracking
    /// Custom tree structure  tracking
    private(set) public lazy var customTreeStructures: CustomTreeStructures = CustomTreeStructures(tracker: self)
    
    //MARK: Richmedia Tracking
    /// Richmedia tracking
    private(set) public lazy var mediaPlayers: MediaPlayers = MediaPlayers(tracker: self)


    
    //MARK: - Initializer
    
    /**
    Default tracker initializer
    
    - returns: a Tracker
    */
    public convenience init() {
        self.init(configuration: Configuration().parameters)
    }
    
    /**
    Tracker initializer with custom configuration
    
    - parameter configuration: custom configuration
    
    - returns: a Tracker
    */
    public init(configuration: [String: String]) {
        // Set the custom configuration
        self.configuration = Configuration(customConfiguration: configuration)
        
        if(!LifeCycle.isInitialized) {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(Tracker.applicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
            notificationCenter.addObserver(self, selector: #selector(Tracker.applicationActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
            LifeCycle.applicationActive(self.configuration.parameters)
        }
    }
    
    /**
     Called when application goes to background
     should save the timestamp to know if we have to start a new session on the next launch
     */
    @objc func applicationDidEnterBackground() {
        LifeCycle.applicationDidEnterBackground()
    }
    
    /**
     Called when app is active
     Should create a new SessionId if necessary
     */
    @objc func applicationActive() {
        LifeCycle.applicationActive(self.configuration.parameters)
    }
    
    // MARK: - Configuration
    
    /** 
    Override current tracker configuration

    - parameter configuration: new configuration for the tracker
    */
    public func setConfig(_ configuration: [String: String], override: Bool, completionHandler: ((_ isSet: Bool) -> Void)?) {
        
        var keyCount = 0
        
        if(override) {
            self.configuration.parameters.removeAll(keepingCapacity: false)
        }
        
        for (key, value) in configuration {
            keyCount = keyCount + 1
            if (!Configuration.ReadOnlyConfiguration.list.contains(key)) {
                let configurationOperation = BlockOperation(block: {
                    self.configuration.parameters[key] = value
                })
                
                if(completionHandler != nil && keyCount == configuration.count) {
                    configurationOperation.completionBlock = {
                        completionHandler!(true)
                    }
                }
                
                TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
            } else {
                if(completionHandler != nil && keyCount == configuration.count) {
                    completionHandler!(false)
                }
                delegate?.warningDidOccur(String(format: "Configuration %@ is read only. Value will not be updated", key))
            }
        }
    }
    
    /**
    Set a configuration key
    
    - parameter key: configuration parameter key
    - parameter value: configuration parameter value
    */
    public func setConfig(_ key: String, value: String, completionHandler: ((_ isSet: Bool) -> Void)?) {
        if (!Configuration.ReadOnlyConfiguration.list.contains(key)) {
            let configurationOperation = BlockOperation(block: {
                self.configuration.parameters[key] = value
            })
            
            if(completionHandler != nil) {
                configurationOperation.completionBlock = {
                    completionHandler!(true)
                }
            }
            
            TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
        } else {
            if(completionHandler != nil) {
                completionHandler!(false)
            }
            delegate?.warningDidOccur(String(format: "Configuration %@ is read only. Value will not be updated", key))
        }
    }
    
    /// Get the current configuration (read-only)
    public var config: [String:String] {
        get {
            return self.configuration.parameters
        }
    }
    
    public func setLog(_ log: String, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.Log, value: log, completionHandler: completionHandler)
    }
    public func setSecuredLog(_ securedLog: String, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.LogSSL, value: securedLog, completionHandler: completionHandler)
    }
    public func setDomain(_ domain: String, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.Domain, value: domain, completionHandler: completionHandler)
    }
    public func setSiteId(_ siteId: Int, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.Site, value: String(siteId), completionHandler: completionHandler)
    }
    public func setOfflineMode(_ offlineMode: OfflineModeKey, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.OfflineMode, value: offlineMode.rawValue, completionHandler: completionHandler)
    }
    public func setSecureModeEnabled(_ enabled: Bool, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.Secure, value: String(enabled), completionHandler: completionHandler)
    }
    public func setIdentifierType(_ identifierType: IdentifierTypeKey, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.Identifier, value: identifierType.rawValue, completionHandler: completionHandler)
    }
    public func setHashUserIdEnabled(_ enabled: Bool, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.HashUserId, value: String(enabled), completionHandler: completionHandler)
    }
    public func setPlugins(_ pluginNames: [PluginKey], completionHandler: ((_ isSet: Bool) -> Void)?) {
        let newValue = pluginNames.map({$0.rawValue}).joined(separator: ",")
        setConfig(TrackerConfigurationKeys.Plugins, value: newValue, completionHandler: completionHandler)
    }
    public func setBackgroundTaskEnabled(_ enabled: Bool, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.EnableBackgroundTask, value: String(enabled), completionHandler: completionHandler)
    }
    public func setPixelPath(_ pixelPath: String, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.PixelPath, value: pixelPath, completionHandler: completionHandler)
    }
    public func setPersistentIdentifiedVisitorEnabled(_ enabled: Bool, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.PersistIdentifiedVisitor, value: String(enabled), completionHandler: completionHandler)
    }
    public func setTvTrackingUrl(_ url: String, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.TvTrackingURL, value: url, completionHandler: completionHandler)
    }
    public func setTvTrackingVisitDuration(_ visitDuration: Int, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.TvTrackingVisitDuration, value: String(visitDuration), completionHandler: completionHandler)
    }
    public func setTvTrackingSpotValidityTime(_ time: Int, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.TvTrackingSpotValidityTime, value: String(time), completionHandler: completionHandler)
    }
    public func setCampaignLastPersistenceEnabled(_ enabled: Bool, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.CampaignLastPersistence, value: String(enabled), completionHandler: completionHandler)
    }
    public func setCampaignLifetime(_ lifetime: Int, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.CampaignLifetime, value: String(lifetime), completionHandler: completionHandler)
    }
    public func setSessionBackgroundDuration(_ duration: Int, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.SessionBackgroundDuration, value: String(duration), completionHandler: completionHandler)
    }
    
    // MARK: - Parameter
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: parameter value
    */
    private func setParam(_ key: String, value: @escaping ()->(String), type: Param.ParamType) {
        // Check whether the parameter is not in read only mode
        if(!ReadOnlyParam.list.contains(key)) {
            let param = Param(key: key, value: value, type: type)
            let positions = Tool.findParameterPosition(key, arrays: buffer.persistentParameters, buffer.volatileParameters)
            
            // Check if parameter is already set
            if(positions.count > 0) {
                // If found, replace first parameter with new value and delete others in appropriate buffer array
                for(index, position) in positions.enumerated() {
                    if(index == 0) {
                        (position.arrayIndex == 0) ? (buffer.persistentParameters[position.index] = param)
                            : (buffer.volatileParameters[position.index] = param)
                    } else {
                        _ = (position.arrayIndex == 0) ? buffer.persistentParameters.remove(at: position.index) : buffer.volatileParameters.remove(at: position.index)
                    }
                }
            } else {
                // If not found, append parameter to volatile buffer
                buffer.volatileParameters.append(param)
            }
        } else {
            delegate?.warningDidOccur(String(format: "Parameter %@ is read only. Value will not be updated", key))
        }
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: parameter value
    - parameter options: parameter options
    */
    private func setParam(_ key: String, value: @escaping ()->(String), type: Param.ParamType, options: ParamOption) {
        // Check whether the parameter is not in read only mode
        if(!ReadOnlyParam.list.contains(key)) {
            let param = Param(key: key, value: value, type: type, options: options)
            let positions = Tool.findParameterPosition(key, arrays: buffer.persistentParameters, buffer.volatileParameters)
            
            if(options.append) {
                // Check if parameter is already set
                for(_, position) in positions.enumerated() {
                    // If new parameter is set to be persistent we move old parameters into the right buffer array
                    if(options.persistent) {
                        // If old parameter was in volatile buffer, we place it into the persistent buffer
                        if(position.arrayIndex > 0) {
                            let existingParam = buffer.volatileParameters[position.index]
                            buffer.volatileParameters.remove(at: position.index)
                            buffer.persistentParameters.append(existingParam)
                        }
                    } else {
                        if(position.arrayIndex == 0) {
                            let existingParam = buffer.persistentParameters[position.index]
                            buffer.persistentParameters.remove(at: position.index)
                            buffer.volatileParameters.append(existingParam)
                        }
                    }
                }
                
                (options.persistent) ? buffer.persistentParameters.append(param) : buffer.volatileParameters.append(param)
            } else {
                // Check if parameter is already set
                if(positions.count > 0) {
                    // If found, replace first parameter with new value and delete others in appropriate buffer array
                    for(index, position) in positions.enumerated() {
                        if(index == 0) {
                            if(position.arrayIndex == 0) {
                                // If parameter is set to be persistent and is already persistent, we change its value. If not, we place the parameter in the volatile buffer
                                if(options.persistent) {
                                    buffer.persistentParameters[position.index] = param
                                } else {
                                    buffer.persistentParameters.remove(at: position.index)
                                    buffer.volatileParameters.append(param)
                                }
                            } else {
                                if(options.persistent) {
                                    buffer.volatileParameters.remove(at: position.index)
                                    buffer.persistentParameters.append(param)
                                } else {
                                    buffer.volatileParameters[position.index] = param
                                }
                            }
                        } else {
                            _ = (position.arrayIndex == 0) ? buffer.persistentParameters.remove(at: position.index) : buffer.volatileParameters.remove(at: position.index)
                        }
                    }
                } else {
                    // If not found, append parameter to buffer
                    (options.persistent) ? buffer.persistentParameters.append(param) : buffer.volatileParameters.append(param)
                }
            }
        } else {
            delegate?.warningDidOccur(String(format: "Parameter %@ is read only. Value will not be updated", key))
        }
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: string parameter value
    */
    public func setParam(_ key: String, value: @escaping ()->(String)) -> Tracker {
        setParam(key, value: value, type: .closure)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: string parameter value
    - parameter options: parameter options
    */
    public func setParam(_ key: String, value: @escaping ()->(String), options: ParamOption) -> Tracker {
        setParam(key, value: value, type: .closure, options: options)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: string parameter value
    */
    public func setParam(_ key: String, value: String) -> Tracker {
        // If string is not JSON
        if (value.parseJSONString == nil) {
            setParam(key, value: {value}, type: .string)
        } else {
            setParam(key, value: {value}, type: .json)
        }
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: string parameter value
    - parameter options: parameter options
    */
    public func setParam(_ key: String, value: String, options: ParamOption) -> Tracker {
        // If string is not JSON
        if (value.parseJSONString == nil) {
            setParam(key, value: {value}, type: .string, options: options)
        } else {
            setParam(key, value: {value}, type: .json, options: options)
        }
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: int parameter value
    */
    public func setParam(_ key: String, value: Int) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .integer)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: int parameter value
    - parameter options: parameter options
    */
    public func setParam(_ key: String, value: Int, options: ParamOption) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .integer, options: options)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: float parameter value
    */
    public func setParam(_ key: String, value: Float) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .float)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: float parameter value
    - parameter options: parameter options
    */
    public func setParam(_ key: String, value: Float, options: ParamOption) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .float, options: options)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: double parameter value
    */
    public func setParam(_ key: String, value: Double) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .double)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: double parameter value
    - parameter options: parameter options
    */
    public func setParam(_ key: String, value: Double, options: ParamOption) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .double, options: options)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: bool parameter value
    */
    public func setParam(_ key: String, value: Bool) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .bool)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: bool parameter value
    - parameter options: parameter options
    */
    public func setParam(_ key: String, value: Bool, options: ParamOption) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .bool, options: options)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: array parameter value
    */
    public func setParam(_ key: String, value: [Any]) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .array)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: array parameter value
    - parameter options: parameter options
    */
    public func setParam(_ key: String, value: [Any], options: ParamOption) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .array, options: options)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: dictionary parameter value
    */
    public func setParam(_ key: String, value: [String: Any]) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .json)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: dictionary parameter value
    - parameter options: parameter options
    */
    public func setParam(_ key: String, value: [String: Any], options: ParamOption) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .json, options: options)
        
        return self
    }
    
    /**
    Set a not string type parameter
    
    - parameter key: parameter key
    - parameter value: parameter value
    - parameter options: parameter options
    */
    func handleNotStringParameterSetting(_ key: String, value: Any, type: Param.ParamType, options: ParamOption? = nil) {
        var stringValue: (value: String, success: Bool)
        if let optOptions = options {
            stringValue = Tool.convertToString(value, separator: optOptions.separator)
            if (stringValue.success) {
                setParam(key, value: {stringValue.value}, type: type, options: optOptions)
            } else {
                delegate?.warningDidOccur(String(format: "Parameter %@ could not be inserted in hit. Parameter will be ignored", key))
            }
        } else {
            stringValue = Tool.convertToString(value)
            if (stringValue.success) {
                setParam(key, value: {stringValue.value}, type: type)
            } else {
                delegate?.warningDidOccur(String(format: "Parameter %@ could not be inserted in hit. Parameter will be ignored", key))
            }
        }
    }
    
    /**
    Remove a parameter from the hit querystring
    
    - parameter parameter: type
    */
    public func unsetParam(_ param: String) {
        let positions = Tool.findParameterPosition(param, arrays: buffer.persistentParameters, buffer.volatileParameters)
        
        // Check if parameter is already set in buffer
        if(positions.count > 0) {
            for(_, position) in positions.enumerated() {
                if(position.arrayIndex == 0) {
                    buffer.persistentParameters.remove(at: position.index);
                } else {
                    buffer.volatileParameters.remove(at: position.index);
                }
            }
        }
        
        switch param {
        case HitParam.Level2.rawValue:
            context._level2 = nil
        case HitParam.BackgroundMode.rawValue:
            context._backgroundMode = nil
        default:
            break
        }
    }

    // MARK: - Dispatch
    /**
    Send the built hit
    */
    public func dispatch() {
        
        if(businessObjects.count > 0) {
            
            var onAppAds = [BusinessObject]()
            var customObjects = [BusinessObject]()
            var screenObjects = [BusinessObject]()
            var salesTrackerObjects = [BusinessObject]()
            var internalSearchObjects = [BusinessObject]()
            var products = [BusinessObject]()
            
            // Order object by timestamp
            let sortedObjects = businessObjects.sorted {
                a, b in return a.1.timeStamp  < b.1.timeStamp
            }
            
            for(_, object) in sortedObjects {
                
                if(!(object is Product)) {
                    dispatchObjects(&products, customObjects: &customObjects)
                }
                
                // Dispatch onAppAds before sending other object
                if(!(object is OnAppAd || object is ScreenInfo || object is AbstractScreen || object is InternalSearch || object is Cart || object is Order)
                    || (object is OnAppAd && (object as! OnAppAd).action == OnAppAd.Action.Touch)) {
                    dispatchObjects(&onAppAds, customObjects: &customObjects)
                }
                
                if let ad = object as? OnAppAd {
                    ///If ad impression, then add to temp list
                    if(ad.action == OnAppAd.Action.View) {
                        onAppAds.append(ad)
                    }
                    else {
                        // Send onAppAd touch hit
                        customObjects.append(ad)
                        dispatcher.dispatch(customObjects)
                        customObjects.removeAll(keepingCapacity: false)
                    }
                } else if object is Product {
                    products.append(object)
                } else if (object is CustomObject || object is NuggAd) {
                    customObjects.append(object)
                } else if (object is Order || object is Cart) {
                    salesTrackerObjects.append(object)
                } else if (object is ScreenInfo) {
                    screenObjects.append(object)
                } else if (object is InternalSearch) {
                    internalSearchObjects.append(object)
                } else if (object is AbstractScreen) {
                    onAppAds += customObjects
                    onAppAds += screenObjects
                    onAppAds += internalSearchObjects
                    
                    // Sales tracker
                    var orders = [BusinessObject]()
                    var cart: Cart?
                    
                    if(salesTrackerObjects.count > 0) {
                        for(_, value) in salesTrackerObjects.enumerated() {
                            switch(value) {
                            case let crt as Cart:
                                cart = crt
                            default:
                                orders.append(value)
                                break
                            }
                        }
                    }
                    
                    if(cart != nil) {
                        if (((object as! AbstractScreen).isBasketScreen) || orders.count > 0) {
                            onAppAds.append(cart!)
                        }
                    }
                    
                    onAppAds += orders
                    onAppAds.append(object)
                    
                    dispatcher.dispatch(onAppAds)
                    
                    screenObjects.removeAll(keepingCapacity: false)
                    salesTrackerObjects.removeAll(keepingCapacity: false)
                    internalSearchObjects.removeAll(keepingCapacity: false)
                    onAppAds.removeAll(keepingCapacity: false)
                    customObjects.removeAll(keepingCapacity: false)
                } else {

                    if(object is Gesture && (object as! Gesture).action == Gesture.Action.Search) {
                        onAppAds += internalSearchObjects
                        internalSearchObjects.removeAll(keepingCapacity: false)
                    }
                    
                    onAppAds += customObjects
                    onAppAds += [object]
                    dispatcher.dispatch(onAppAds)
                    
                    onAppAds.removeAll(keepingCapacity: false)
                    customObjects.removeAll(keepingCapacity: false)
                }
            }
            
            // S'il reste des publicités / autopromo à envoyer, on envoie
            dispatchObjects(&onAppAds, customObjects: &customObjects)
            
            // S'il reste des produits vus à envoyer
            dispatchObjects(&products, customObjects: &customObjects)
            
            if(customObjects.count > 0 || internalSearchObjects.count > 0 || screenObjects.count > 0) {
                customObjects += internalSearchObjects
                customObjects += screenObjects
                
                dispatcher.dispatch(customObjects)
                
                customObjects.removeAll(keepingCapacity: false)
                internalSearchObjects.removeAll(keepingCapacity: false)
                screenObjects.removeAll(keepingCapacity: false)
            }
            
        } else {
            dispatcher.dispatch(nil)
        }
    }
    
    /**
    Dispatch objects with their customObjects
    */
    func dispatchObjects(_ objects: inout [BusinessObject], customObjects: inout [BusinessObject]) {
        if(objects.count > 0) {
            objects += customObjects
            dispatcher.dispatch(objects)
            customObjects.removeAll(keepingCapacity: false)
            objects.removeAll(keepingCapacity: false)
        }
    }
    
    //MARK: - User identifier management
    
    /**
    Gets the user id
    
    - returns: the user id depending on configuration (uuid, idfv)
    */
    public func getUserId() -> String {
        if let hash = self.configuration.parameters["hashUserId"] {
            if (hash == "true") {
                return TechnicalContext.userId(self.configuration.parameters["identifier"]).sha256Value
            } else {
                return TechnicalContext.userId(self.configuration.parameters["identifier"])
            }
        } else {
            return TechnicalContext.userId(self.configuration.parameters["identifier"])
        }
    }
    
    // MARK: - Do not track
    
    /**
    Enable or disable tracking
    */
    public class var doNotTrack: Bool {
        get {
            return TechnicalContext.doNotTrack
        } set {
            let dotNotTrackOperation = BlockOperation(block: {
                TechnicalContext.doNotTrack = newValue
            })
            
            TrackerQueue.sharedInstance.queue.addOperation(dotNotTrackOperation)
        }
    }
    
    // MARK: - Crash
    
    private static var _handleCrash: Bool = false
    
    /// Set tracker crash handler
    /// Use only if you don't already use another crash analytics solution
    /// Once enabled, tracker crash handler can't be disabled until tracker instance termination
    public class var handleCrash: Bool {
        get {
            return _handleCrash
        } set {
            if !_handleCrash {
                _handleCrash = newValue
                
                if _handleCrash {
                    Crash.handle()
                }
            }
        }
    }
}

// MARK: - Tracker Queue
/// Operation queue
class TrackerQueue {
    /**
    Private initializer (cannot instantiate BuilderQueue)
    */
    private init() {
        
    }
    
    /// TrackerQueue singleton
    static let sharedInstance: TrackerQueue = {
        let instance = TrackerQueue()
        return instance
    }()
    
    /// Queue
    lazy var queue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "TrackerQueue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = QualityOfService.background
        return queue
        }()
}
