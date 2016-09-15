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
//  TrackerTests.swift
//  Tracker
//

import UIKit
import XCTest

import Tracker

class TrackerTests: XCTestCase, TrackerDelegate {
    
    /* Implémentation des méthodes du TrackerDelegate */
    
    func didCallPartner(_ response: String) {
        if (response == "OK") {
            callbackCalled = true
        }
    }
    
    func warningDidOccur(_ message: String) {
        if (message == "OK") {
            callbackCalled = true
        }
    }
    
    func errorDidOccur(_ message: String) {
        if (message == "OK") {
            callbackCalled = true
        }
    }
    
    func sendDidEnd(_ status: HitStatus, message: String) {
        if (message == "OK" && status == HitStatus.success) {
            callbackCalled = true
        }
    }
    
    func saveDidEnd(_ message: String) {
        callbackCalled = true
    }
    
    func buildDidEnd(_ status: HitStatus, message: String) {
        if (message == "OK" && status == HitStatus.success) {
            callbackCalled = true
        }
    }
    
    func trackerNeedsFirstLaunchApproval(_ message: String) {
        if (message == "OK") {
            callbackCalled = true
        }
    }
    
    
    var tracker = Tracker()
    let configuration = ["log":"logp", "logSSL":"logs", "domain":"xiti.com", "pixelPath":"/hit.xiti", "site":"549808", "secure":"false", "identifier":"uuid"]
    
    let nbPersistentParameters = 15
    
    // Variables références
    var callbackCalled = false
    let mess = "OK"
    let stat = HitStatus.success
    let myConf = ["log":"customlog", "logSSL":"customlogs", "domain":"customdomain",
        "pixelPath":"custompixelpath","site":"customsite", "secure":"customsecure",
        "identifier":"customidentifier"]
    let anotherConf = ["log":"tata", "logSSL":"yoyo"]
    let opts = ParamOption()
    
    override func setUp() {
        super.setUp()
        tracker = Tracker(configuration: configuration)
        tracker.delegate = self
        callbackCalled = false
        tracker.buffer = Buffer(tracker: tracker)
        opts.persistent = true
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    // On vérifie que qu'il est possible d'instancier plusieurs fois Tracker
    func testMultiInstance() {
        let tracker1 = Tracker()
        let tracker2 = Tracker()
        XCTAssert(tracker1 !== tracker2, "tracker1 et tracker2 ne doivent pas pointer vers la même référence")
    }

    /* On vérifie si l'appel des différents callbacks est effectué correctement */
    
    func testDidCallPartner() {
        tracker.delegate?.didCallPartner(mess)
        XCTAssert(callbackCalled, "Le callback doit être appelé et la réponse doit être 'OK'")
    }
    
    func testWarningDidOccur() {
        tracker.delegate?.warningDidOccur(mess)
        XCTAssert(callbackCalled, "Le callback doit être appelé et le message doit être 'OK'")
    }
    
    func testErrorDidOccur() {
        tracker.delegate?.errorDidOccur(mess)
        XCTAssert(callbackCalled, "Le callback doit être appelé et le message doit être 'OK'")
    }
    
    func testSendDidEnd() {
        tracker.delegate?.sendDidEnd(stat, message: mess)
        XCTAssert(callbackCalled, "Le callback doit être appelé avec le status 'Success' et le message 'OK'")
    }
    
    func testBuildDidEnd() {
        tracker.delegate?.buildDidEnd(stat, message: mess)
        XCTAssert(callbackCalled, "Le callback doit être appelé avec le status 'Success' et le message 'OK'")
    }
    
    func testTrackerNeedsFirstLaunchApproval() {
        tracker.delegate?.trackerNeedsFirstLaunchApproval(mess)
        XCTAssert(callbackCalled, "Le callback doit être appelé et le message doit être 'OK'")
    }
    
    
    /* On teste toutes les surcharges de setParam */
    
    func testsetParamInt() {
        _ = tracker.setParam("test", value: 2)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 1, "La collection des paramètres volatiles doit contenir un objet")
        XCTAssertEqual(tracker.buffer.volatileParameters[0].value() as String, "2", "Le paramètre doit avoir la valeur 2")
    }
    
    func testsetParamIntWithOptions() {
        _ = tracker.setParam("test", value: 2, options: opts)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 0, "La collection des paramètres volatiles doit être vide")
        XCTAssertEqual(tracker.buffer.persistentParameters.count, nbPersistentParameters, "La collection des paramètres persitants doit contenir un objet")
    }
    
    func testsetParamFloat() {
        let val: Float = 3.14
        _ = tracker.setParam("test", value: val)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 1, "La collection des paramètres volatiles doit contenir un objet")
        let result = ((tracker.buffer.volatileParameters[0].value() as String) == val.description)
        XCTAssert(result, "Le paramètre doit avoir la valeur 3.14 (float)")
    }
    
    func testsetParamFloatWithOptions() {
        let val: Float = 3.14
        _ = tracker.setParam("test", value: val, options: opts)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 0, "La collection des paramètres volatiles doit être vide")
        XCTAssertEqual(tracker.buffer.persistentParameters.count, nbPersistentParameters, "La collection des paramètres persitants doit contenir un objet")
    }
    
    func testsetParamDouble() {
        let val: Double = 3.14
        _ = tracker.setParam("test", value: val)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 1, "La collection des paramètres volatiles doit contenir un objet")
        let result = ((tracker.buffer.volatileParameters[0].value() as String) == val.description)
        XCTAssert(result, "Le paramètre doit avoir la valeur 3.14 (double)")
    }
    
    func testsetParamDoubleWithOptions() {
        let val: Double = 3.14
        _ = tracker.setParam("test", value: val, options: opts)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 0, "La collection des paramètres volatiles doit être vide")
        XCTAssertEqual(tracker.buffer.persistentParameters.count, nbPersistentParameters, "La collection des paramètres persitants doit contenir un objet")
    }
    
    func testsetParamBool() {
        _ = tracker.setParam("test", value: true)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 1, "La collection des paramètres volatiles doit contenir un objet")
        XCTAssertEqual(tracker.buffer.volatileParameters[0].value() as String, "true", "Le paramètre doit avoir la valeur true")
    }
    
    func testsetParamBoolWithOptions() {
        _ = tracker.setParam("test", value: true, options: opts)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 0, "La collection des paramètres volatiles doit être vide")
        XCTAssertEqual(tracker.buffer.persistentParameters.count, nbPersistentParameters, "La collection des paramètres persitants doit contenir un objet")
    }
    
    func testsetParamString() {
        _ = tracker.setParam("test", value: "home")
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 1, "La collection des paramètres volatiles doit contenir un objet")
        XCTAssertEqual(tracker.buffer.volatileParameters[0].value() as String, "home", "Le paramètre doit avoir la valeur \"home\"")
    }
    
    func testsetParamStringWithOptions() {
        _ = tracker.setParam("test", value: "home", options: opts)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 0, "La collection des paramètres volatiles doit être vide")
        XCTAssertEqual(tracker.buffer.persistentParameters.count, nbPersistentParameters, "La collection des paramètres persitants doit contenir un objet")
    }
    
    func testsetParamArray() {
        _ = tracker.setParam("test", value: ["toto", true])
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 1, "La collection des paramètres volatiles doit contenir un objet")
        let array = tracker.buffer.volatileParameters[0].value()
        XCTAssert(array == "toto,true", "Le paramètre doit avoir la valeur [\"toto\", true]")
    }
    
    func testsetParamArrayWithOptions() {
        _ = tracker.setParam("test", value: ["toto", true], options: opts)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 0, "La collection des paramètres volatiles doit être vide")
        XCTAssertEqual(tracker.buffer.persistentParameters.count, nbPersistentParameters, "La collection des paramètres persitants doit contenir un objet")
    }
//    
//    func testsetParamDictionary() {
//        tracker.setParam("test", value: ["toto": true, "tata": "hello"])
//        XCTAssertEqual(tracker.buffer.volatileParameters.count, 1, "La collection des paramètres volatiles doit contenir un objet")
//        let dict: AnyObject = tracker.buffer.volatileParameters[0].value().parseJSONString!
//        
//        XCTAssert(dict["toto"] as! Bool == true, "La clé toto doit avoir pour valeur 1")
//        XCTAssert(dict["tata"] as! String == "hello", "La clé tata doit avoir pour valeur hello")
//    }
    
    func testsetParamDictionaryWithOptions() {
        _ = tracker.setParam("test", value: ["toto": true, "tata": "hello"], options: opts)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 0, "La collection des paramètres volatiles doit être vide")
        XCTAssertEqual(tracker.buffer.persistentParameters.count, nbPersistentParameters, "La collection des paramètres persitants doit contenir un objet")
    }
    
    func testsetParamClosure() {
        let closure = { () -> String in
            return "hello"
        }
        _ = tracker.setParam("test", value: closure)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 1, "La collection des paramètres volatiles doit contenir un objet")
        XCTAssertEqual(tracker.buffer.volatileParameters[0].value(), "hello", "Le paramètre doit avoir la valeur \"hello\"")
    }
    
    func testsetParamClosureWithOptions() {
        let closure = { () -> String in
            return "hello"
        }
        _ = tracker.setParam("test", value: closure, options: opts)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 0, "La collection des paramètres volatiles doit être vide")
        XCTAssertEqual(tracker.buffer.persistentParameters.count, nbPersistentParameters, "La collection des paramètres persitants doit contenir un objet")
    }
    
    
    /* Vérification du paramètrage de la configuration du tracker */
    
    func testSetFullConfiguration() {
        let expectation = self.expectation(description: "test")
        
        tracker.setConfig(anotherConf, override: true, completionHandler: { (isSet) -> Void in
            XCTAssertEqual(self.tracker.configuration.parameters.count, self.anotherConf.count, "La configuration complète du tracker n'est pas correcte")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetLogConfiguration() {
        let expectation = self.expectation(description: "test")
        
        tracker.setLog("logtest", completionHandler: { (isSet) -> Void in
            XCTAssert(self.tracker.configuration.parameters["log"] == "logtest", "Le nouveau log est incorrect")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetSecuredLogConfiguration() {
        let expectation = self.expectation(description: "test")
        
        tracker.setSecuredLog("logstest", completionHandler: { (isSet) -> Void in
            XCTAssert(self.tracker.configuration.parameters["logSSL"] == "logstest", "Le nouveau log sécurisé est incorrect")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetSiteIdConfiguration() {
        let expectation = self.expectation(description: "test")
        
        tracker.setSiteId(123456, completionHandler: { (isSet) -> Void in
            XCTAssert(self.tracker.configuration.parameters["site"] == "123456", "Le nouveau site est incorrect")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetDomainConfiguration() {
        let expectation = self.expectation(description: "test")
        
        tracker.setDomain("newdomain.com", completionHandler: { (isSet) -> Void in
            XCTAssert(self.tracker.configuration.parameters["domain"] == "newdomain.com", "Le nouveau domaine est incorrect")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetOfflineModeConfiguration() {
        let expectation = self.expectation(description: "test")
        
        tracker.setOfflineMode(.Never, completionHandler: { (isSet) -> Void in
            XCTAssert(self.tracker.configuration.parameters["storage"] == "never", "Le nouveau mode offline est incorrect")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetPluginsConfiguration() {
        let expectation = self.expectation(description: "test")
        
        
        tracker.setPlugins([.TvTracking, .NuggAd], completionHandler: { (isSet) -> Void in
            XCTAssert(self.tracker.configuration.parameters["plugins"] == "tvtracking,nuggad", "Les nouveaux plugins sont incorrects")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetSecureModeConfiguration() {
        let expectation = self.expectation(description: "test")
        
        tracker.setSecureModeEnabled(true, completionHandler: { (isSet) -> Void in
            XCTAssert(self.tracker.configuration.parameters["secure"] == "true", "Le nouveau mode securise est incorrect")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetIdentifierConfiguration() {
        let expectation = self.expectation(description: "test")
        
        tracker.setIdentifierType(.IDFV, completionHandler: { (isSet) -> Void in
            XCTAssert(self.tracker.configuration.parameters["identifier"] == "idfv", "Le nouvel identifiant est incorrect")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetHashUserIdModeConfiguration() {
        let expectation = self.expectation(description: "test")
        
        tracker.setHashUserIdEnabled(true, completionHandler: { (isSet) -> Void in
            XCTAssert(self.tracker.configuration.parameters["hashUserId"] == "true", "Le nouveau hashage est incorrect")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetPixelPathConfiguration() {
        let expectation = self.expectation(description: "test")
        
        tracker.setPixelPath("/toto.xiti", completionHandler: { (isSet) -> Void in
            XCTAssert(self.tracker.configuration.parameters["pixelPath"] == "/toto.xiti", "Le nouveau pixel path est incorrect")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetPersistIdentifiedVisitorConfiguration() {
        let expectation = self.expectation(description: "test")
        
        tracker.setPersistentIdentifiedVisitorEnabled(true, completionHandler: { (isSet) -> Void in
            XCTAssert(self.tracker.configuration.parameters["persistIdentifiedVisitor"] == "true", "Le nouveau mode de persistence est incorrect")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetTVTUrlConfiguration() {
        let expectation = self.expectation(description: "test")
        
        tracker.setTvTrackingUrl("test.com", completionHandler: { (isSet) -> Void in
            XCTAssert(self.tracker.configuration.parameters["tvtURL"] == "test.com", "La nouvelle tvtURL est incorrecte")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetTVTVisitDurationConfiguration() {
        let expectation = self.expectation(description: "test")
        
        tracker.setTvTrackingVisitDuration(20, completionHandler: { (isSet) -> Void in
            XCTAssert(self.tracker.configuration.parameters["tvtVisitDuration"] == "20", "La nouvelle tvtVisitDuration est incorrecte")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetTVTSpotValidityTimeConfiguration() {
        let expectation = self.expectation(description: "test")
        
        tracker.setTvTrackingSpotValidityTime(4, completionHandler: { (isSet) -> Void in
            XCTAssert(self.tracker.configuration.parameters["tvtSpotValidityTime"] == "4", "Le nouveau tvtSpotValidityTime est incorrect")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetEnabledBGTaskConfiguration() {
        let expectation = self.expectation(description: "test")
        
        tracker.setBackgroundTaskEnabled(true, completionHandler: { (isSet) -> Void in
            XCTAssert(self.tracker.configuration.parameters["enableBackgroundTask"] == "true", "Le nouveau mode de background task est incorrect")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetCampaignLastPersistenceConfiguration() {
        let expectation = self.expectation(description: "test")
        
        tracker.setCampaignLastPersistenceEnabled(false, completionHandler: { (isSet) -> Void in
            XCTAssert(self.tracker.configuration.parameters["campaignLastPersistence"]  == "false", "Le nouveau mode de persistence est incorrect")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetCampaignLifetimeConfiguration() {
        let expectation = self.expectation(description: "test")
        
        tracker.setCampaignLifetime(54, completionHandler: { (isSet) -> Void in
            XCTAssert(self.tracker.configuration.parameters["campaignLifetime"] == "54", "Le nouveau campaignLifetime est incorrect")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetSessionBackgroundDurationConfiguration() {
        let expectation = self.expectation(description: "test")
        
        tracker.setSessionBackgroundDuration(54, completionHandler: { (isSet) -> Void in
            XCTAssert(self.tracker.configuration.parameters["sessionBackgroundDuration"] == "54", "Le nouveau sessionBackgroundDuration est incorrect")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testReplaceSomeConfiguration() {
        let expectation = self.expectation(description: "test")
        
        tracker.setConfig(anotherConf, override: false, completionHandler: { (isSet) -> Void in
            XCTAssert(self.tracker.configuration.parameters["log"] == "tata", "La configuration complète du tracker n'est pas correcte")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetKeyConfiguration() {
        let expectation = self.expectation(description: "test")
        
        tracker.setConfig("macle", value: "mavaleur", completionHandler:nil)
        let configurationOperation = BlockOperation(block: {
            XCTAssertTrue(self.tracker.configuration.parameters["macle"] == "mavaleur", "La clé de configuration du tracker n'est pas correcte")
            expectation.fulfill()
        })
        
        TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetConfigKeyReadOnly() {
        let expectation = self.expectation(description: "test")
        
        let refCount = self.tracker.configuration.parameters.count
        tracker.setConfig("atreadonlytest", value: "test", completionHandler: nil)
        let configurationOperation = BlockOperation(block: {
            let newCount = self.tracker.configuration.parameters.count
            XCTAssertTrue(newCount == refCount, "La clé de configuration du tracker ne doit pas existée")
            expectation.fulfill()
        })
        
        TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    
    /* Vérification de la gestion de la surcharge des paramètres */
    
    func testSetVolatileParameterNotReadOnly() {
        _ = tracker.setParam("cle", value: {"valeurOriginale"})
        let refCount = tracker.buffer.volatileParameters.count
        let refValue = tracker.buffer.volatileParameters[0].value()
        _ = tracker.setParam("cle", value: {"valeurModifiee"})
        let newCount = tracker.buffer.volatileParameters.count
        let newValue = tracker.buffer.volatileParameters[0].value()
        XCTAssertEqual(refCount, newCount, "Le nombre de paramètres dans la collection volatile doit être identique")
        XCTAssertTrue(refValue != newValue, "La valeur du paramètre dans la collection volatile pour la même clé doit changer")
    }
    
    func testSetPersistentParameterNotReadOnly() {
        let opt = ParamOption()
        opt.persistent = true
        _ = tracker.setParam("cle", value: {"valeurOriginale"}, options: opt)
        let refCount = tracker.buffer.persistentParameters.count
        let refValue = tracker.buffer.persistentParameters[refCount - 1].value()
        _ = tracker.setParam("cle", value: {"valeurModifiee"})
        let newCount = tracker.buffer.persistentParameters.count
        let newValue = tracker.buffer.persistentParameters[refCount - 1].value()
        XCTAssertEqual(refCount, newCount, "Le nombre de paramètres dans la collection persistante doit être identique")
        XCTAssertTrue(refValue != newValue, "La valeur du paramètre dans la collection persistante pour la même clé doit changer")
    }
    
    func testsetParamReadOnly() {
        let opt = ParamOption()
        opt.persistent = true
        let refCount = tracker.buffer.persistentParameters.count
        let refValue = tracker.buffer.persistentParameters[0].value()
        let refKey = tracker.buffer.persistentParameters[0].key
        _ = tracker.setParam(refKey, value: "123", options: opt)
        let newKey = tracker.buffer.persistentParameters[0].key
        let newCount = tracker.buffer.persistentParameters.count
        let newValue = tracker.buffer.persistentParameters[0].value()
        XCTAssertEqual(refCount, newCount, "Le nombre de paramètres dans la collection persistante doit être identique")
        XCTAssertTrue(refValue == newValue, "La valeur du paramètre dans la collection persistante pour la même clé ne doit pas changer")
        XCTAssertTrue(refKey == newKey, "la clé pour l'index donnée de la collection persistante ne doit pas changer")
    }
    
    func testDefaultDoNotTrack() {
        let builder = Builder(tracker: self.tracker, volatileParameters: tracker.buffer.volatileParameters, persistentParameters: tracker.buffer.persistentParameters)
        
        let hits = builder.build()
        let url = URL(string: hits[0])
        
        let urlComponents = url?.query!.components(separatedBy: "&")
        
        for component in urlComponents! as [String] {
            let pairComponents = component.components(separatedBy: "=")
            
            if(pairComponents[0] == "idclient") {
                XCTAssert(pairComponents[1] != "opt-out".percentEncodedString, "le paramètre idclient doit être différent d'opt-out")
            }
        }
    }
    
    func testDoNotTrack() {
        Tracker.doNotTrack = true
        
         let configurationOperation = BlockOperation(block: {
        
            let builder = Builder(tracker: self.tracker, volatileParameters: self.tracker.buffer.volatileParameters, persistentParameters: self.tracker.buffer.persistentParameters)
            
            let hits = builder.build()
            let url = URL(string: hits[0])
            
            let urlComponents = url?.query!.components(separatedBy: "&")
            
            for component in urlComponents! as [String] {
                let pairComponents = component.components(separatedBy: "=")
                
                if(pairComponents[0] == "idclient") {
                    XCTAssert(pairComponents[1] == "opt-out", "le paramètre idclient doit être égal à opt-out")
                }
            }
        })
        
        TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
        
        Tracker.doNotTrack = false
    }
    
    func testHashUserId() {
        let expectation = self.expectation(description: "test")
        
        self.tracker.setConfig("hashUserId", value: "true", completionHandler:nil)
        _ = self.tracker.setParam(HitParam.UserID.rawValue, value: "coucou")
        
        let configurationOperation = BlockOperation(block: {
        
            let builder = Builder(tracker: self.tracker, volatileParameters: self.tracker.buffer.volatileParameters, persistentParameters: self.tracker.buffer.persistentParameters)
            
            let hits = builder.build()
            let url = URL(string: hits[0])            
            
            let urlComponents = url?.query!.components(separatedBy: "&")
            
            for component in urlComponents! as [String] {
                let pairComponents = component.components(separatedBy: "=")
                
                if(pairComponents[0] == "idclient") {
                    XCTAssert(pairComponents[1] == "1edd758910e96f4c7f7426ce8daf82c1a97dda4bfb165855e2b47a43021bddef".percentEncodedString, "le paramètre idclient doit être égal à 1edd758910e96f4c7f7426ce8daf82c1a97dda4bfb165855e2b47a43021bddef")
                }
            }
            
            expectation.fulfill()
        })
        
        TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
        
        waitForExpectations(timeout: 10, handler: nil)
        
        self.tracker.setConfig("hashUserId", value: "false", completionHandler:nil)
    }
    
    func testNoHashUserId() {
        let expectation = self.expectation(description: "test")
        
        self.tracker.setConfig("hashUserId", value: "false", completionHandler:{(isSet) in
            _ = self.tracker.setParam(HitParam.UserID.rawValue, value: "coucou")
            
            let builder = Builder(tracker: self.tracker, volatileParameters: self.tracker.buffer.volatileParameters, persistentParameters: self.tracker.buffer.persistentParameters)
            
            let hits = builder.build()
            let url = URL(string: hits[0])
            
            _ = [String: String]()
            let urlComponents = url?.query!.components(separatedBy: "&")
            
            for component in urlComponents! as [String] {
                let pairComponents = component.components(separatedBy: "=")
                
                if(pairComponents[0] == "idclient") {
                    XCTAssert(pairComponents[1] == "coucou".percentEncodedString, "le paramètre idclient doit être égal à coucou")
                }
            }
        })
        
        expectation.fulfill()
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testUnsetParam() {
        let refCount = tracker.buffer.volatileParameters.count
        tracker.setParam("toto", value: "tata")
            .unsetParam("toto")
        let newCount = tracker.buffer.volatileParameters.count
        XCTAssertTrue(refCount == newCount, "Le nombre d'éléments ne doit pas avoir changé")
    }
}
