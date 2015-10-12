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
    
    func didCallPartner(response: String) {
        if (response == "OK") {
            callbackCalled = true
        }
    }
    
    func warningDidOccur(message: String) {
        if (message == "OK") {
            callbackCalled = true
        }
    }
    
    func errorDidOccur(message: String) {
        if (message == "OK") {
            callbackCalled = true
        }
    }
    
    func sendDidEnd(status: HitStatus, message: String) {
        if (message == "OK" && status == HitStatus.Success) {
            callbackCalled = true
        }
    }
    
    func saveDidEnd(message: String) {
        callbackCalled = true
    }
    
    func buildDidEnd(status: HitStatus, message: String) {
        if (message == "OK" && status == HitStatus.Success) {
            callbackCalled = true
        }
    }
    
    func trackerNeedsFirstLaunchApproval(message: String) {
        if (message == "OK") {
            callbackCalled = true
        }
    }
    
    
    // Instance du tracker
    let tracker = Tracker()
    
    let nbPersistentParameters = 15
    
    // Variables références
    var callbackCalled = false
    let mess = "OK"
    let stat = HitStatus.Success
    let myConf = ["log":"customlog", "logSSL":"customlogs", "domain":"customdomain",
        "pixelPath":"custompixelpath","site":"customsite", "secure":"customsecure",
        "identifier":"customidentifier"]
    let anotherConf = ["log":"tata", "logSSL":"yoyo"]
    let opts = ParamOption()
    
    override func setUp() {
        super.setUp()
        
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
        tracker.setParam("test", value: 2)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 1, "La collection des paramètres volatiles doit contenir un objet")
        XCTAssertEqual(tracker.buffer.volatileParameters[0].value() as String, "2", "Le paramètre doit avoir la valeur 2")
    }
    
    func testsetParamIntWithOptions() {
        tracker.setParam("test", value: 2, options: opts)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 0, "La collection des paramètres volatiles doit être vide")
        XCTAssertEqual(tracker.buffer.persistentParameters.count, nbPersistentParameters, "La collection des paramètres persitants doit contenir un objet")
    }
    
    func testsetParamFloat() {
        let val: Float = 3.14
        tracker.setParam("test", value: val)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 1, "La collection des paramètres volatiles doit contenir un objet")
        let result = ((tracker.buffer.volatileParameters[0].value() as String) == val.description)
        XCTAssert(result, "Le paramètre doit avoir la valeur 3.14 (float)")
    }
    
    func testsetParamFloatWithOptions() {
        let val: Float = 3.14
        tracker.setParam("test", value: val, options: opts)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 0, "La collection des paramètres volatiles doit être vide")
        XCTAssertEqual(tracker.buffer.persistentParameters.count, nbPersistentParameters, "La collection des paramètres persitants doit contenir un objet")
    }
    
    func testsetParamDouble() {
        let val: Double = 3.14
        tracker.setParam("test", value: val)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 1, "La collection des paramètres volatiles doit contenir un objet")
        let result = ((tracker.buffer.volatileParameters[0].value() as String) == val.description)
        XCTAssert(result, "Le paramètre doit avoir la valeur 3.14 (double)")
    }
    
    func testsetParamDoubleWithOptions() {
        let val: Double = 3.14
        tracker.setParam("test", value: val, options: opts)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 0, "La collection des paramètres volatiles doit être vide")
        XCTAssertEqual(tracker.buffer.persistentParameters.count, nbPersistentParameters, "La collection des paramètres persitants doit contenir un objet")
    }
    
    func testsetParamBool() {
        tracker.setParam("test", value: true)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 1, "La collection des paramètres volatiles doit contenir un objet")
        XCTAssertEqual(tracker.buffer.volatileParameters[0].value() as String, "true", "Le paramètre doit avoir la valeur true")
    }
    
    func testsetParamBoolWithOptions() {
        tracker.setParam("test", value: true, options: opts)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 0, "La collection des paramètres volatiles doit être vide")
        XCTAssertEqual(tracker.buffer.persistentParameters.count, nbPersistentParameters, "La collection des paramètres persitants doit contenir un objet")
    }
    
    func testsetParamString() {
        tracker.setParam("test", value: "home")
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 1, "La collection des paramètres volatiles doit contenir un objet")
        XCTAssertEqual(tracker.buffer.volatileParameters[0].value() as String, "home", "Le paramètre doit avoir la valeur \"home\"")
    }
    
    func testsetParamStringWithOptions() {
        tracker.setParam("test", value: "home", options: opts)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 0, "La collection des paramètres volatiles doit être vide")
        XCTAssertEqual(tracker.buffer.persistentParameters.count, nbPersistentParameters, "La collection des paramètres persitants doit contenir un objet")
    }
    
    func testsetParamArray() {
        tracker.setParam("test", value: ["toto", true])
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 1, "La collection des paramètres volatiles doit contenir un objet")
        let array = tracker.buffer.volatileParameters[0].value()
        XCTAssert(array == "toto,true", "Le paramètre doit avoir la valeur [\"toto\", true]")
    }
    
    func testsetParamArrayWithOptions() {
        tracker.setParam("test", value: ["toto", true], options: opts)
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
        tracker.setParam("test", value: ["toto": true, "tata": "hello"], options: opts)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 0, "La collection des paramètres volatiles doit être vide")
        XCTAssertEqual(tracker.buffer.persistentParameters.count, nbPersistentParameters, "La collection des paramètres persitants doit contenir un objet")
    }
    
    func testsetParamClosure() {
        let closure = { () -> String in
            return "hello"
        }
        tracker.setParam("test", value: closure)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 1, "La collection des paramètres volatiles doit contenir un objet")
        XCTAssertEqual(tracker.buffer.volatileParameters[0].value(), "hello", "Le paramètre doit avoir la valeur \"hello\"")
    }
    
    func testsetParamClosureWithOptions() {
        let closure = { () -> String in
            return "hello"
        }
        tracker.setParam("test", value: closure, options: opts)
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 0, "La collection des paramètres volatiles doit être vide")
        XCTAssertEqual(tracker.buffer.persistentParameters.count, nbPersistentParameters, "La collection des paramètres persitants doit contenir un objet")
    }
    
    
    /* Vérification du paramètrage de la configuration du tracker */
    
    func testSetFullConfiguration() {
        let expectation = expectationWithDescription("test")
        
        tracker.setConfig(anotherConf, override: true, completionHandler: { (isSet) -> Void in
            XCTAssertEqual(self.tracker.configuration.parameters.count, self.anotherConf.count, "La configuration complète du tracker n'est pas correcte")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testReplaceSomeConfiguration() {
        let expectation = expectationWithDescription("test")
        
        tracker.setConfig(anotherConf, override: false, completionHandler: { (isSet) -> Void in
            XCTAssert(self.tracker.configuration.parameters["log"] == "tata", "La configuration complète du tracker n'est pas correcte")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testSetKeyConfiguration() {
        let expectation = expectationWithDescription("test")
        
        tracker.setConfig("macle", value: "mavaleur", completionHandler:nil)
        let configurationOperation = NSBlockOperation(block: {
            XCTAssertTrue(self.tracker.configuration.parameters["macle"] == "mavaleur", "La clé de configuration du tracker n'est pas correcte")
            expectation.fulfill()
        })
        
        TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testSetConfigKeyReadOnly() {
        let expectation = expectationWithDescription("test")
        
        let refCount = self.tracker.configuration.parameters.count
        tracker.setConfig("atreadonlytest", value: "test", completionHandler: nil)
        let configurationOperation = NSBlockOperation(block: {
            let newCount = self.tracker.configuration.parameters.count
            XCTAssertTrue(newCount == refCount, "La clé de configuration du tracker ne doit pas existée")
            expectation.fulfill()
        })
        
        TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    
    /* Vérification de la gestion de la surcharge des paramètres */
    
    func testSetVolatileParameterNotReadOnly() {
        tracker.setParam("cle", value: {"valeurOriginale"})
        let refCount = tracker.buffer.volatileParameters.count
        let refValue = tracker.buffer.volatileParameters[0].value()
        tracker.setParam("cle", value: {"valeurModifiee"})
        let newCount = tracker.buffer.volatileParameters.count
        let newValue = tracker.buffer.volatileParameters[0].value()
        XCTAssertEqual(refCount, newCount, "Le nombre de paramètres dans la collection volatile doit être identique")
        XCTAssertTrue(refValue != newValue, "La valeur du paramètre dans la collection volatile pour la même clé doit changer")
    }
    
    func testSetPersistentParameterNotReadOnly() {
        let opt = ParamOption()
        opt.persistent = true
        tracker.setParam("cle", value: {"valeurOriginale"}, options: opt)
        let refCount = tracker.buffer.persistentParameters.count
        let refValue = tracker.buffer.persistentParameters[refCount - 1].value()
        tracker.setParam("cle", value: {"valeurModifiee"})
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
        tracker.setParam(refKey, value: "123", options: opt)
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
        let url = NSURL(string: hits[0])
        
        let urlComponents = url?.query!.componentsSeparatedByString("&")
        
        for component in urlComponents! as [String] {
            let pairComponents = component.componentsSeparatedByString("=")
            
            if(pairComponents[0] == "idclient") {
                XCTAssert(pairComponents[1] != "opt-out".percentEncodedString, "le paramètre idclient doit être différent d'opt-out")
            }
        }
    }
    
    func testDoNotTrack() {
        Tracker.doNotTrack = true
        
         let configurationOperation = NSBlockOperation(block: {
        
            let builder = Builder(tracker: self.tracker, volatileParameters: self.tracker.buffer.volatileParameters, persistentParameters: self.tracker.buffer.persistentParameters)
            
            let hits = builder.build()
            let url = NSURL(string: hits[0])
            
            let urlComponents = url?.query!.componentsSeparatedByString("&")
            
            for component in urlComponents! as [String] {
                let pairComponents = component.componentsSeparatedByString("=")
                
                if(pairComponents[0] == "idclient") {
                    XCTAssert(pairComponents[1] == "opt-out", "le paramètre idclient doit être égal à opt-out")
                }
            }
        })
        
        TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
        
        Tracker.doNotTrack = false
    }
    
    func testHashUserId() {
        let expectation = expectationWithDescription("test")
        
        self.tracker.setConfig("hashUserId", value: "true", completionHandler:nil)
        self.tracker.setParam(HitParam.UserID.rawValue, value: "coucou")
        
        let configurationOperation = NSBlockOperation(block: {
        
            let builder = Builder(tracker: self.tracker, volatileParameters: self.tracker.buffer.volatileParameters, persistentParameters: self.tracker.buffer.persistentParameters)
            
            let hits = builder.build()
            let url = NSURL(string: hits[0])            
            
            let urlComponents = url?.query!.componentsSeparatedByString("&")
            
            for component in urlComponents! as [String] {
                let pairComponents = component.componentsSeparatedByString("=")
                
                if(pairComponents[0] == "idclient") {
                    XCTAssert(pairComponents[1] == "1edd758910e96f4c7f7426ce8daf82c1a97dda4bfb165855e2b47a43021bddef".percentEncodedString, "le paramètre idclient doit être égal à 1edd758910e96f4c7f7426ce8daf82c1a97dda4bfb165855e2b47a43021bddef")
                }
            }
            
            expectation.fulfill()
        })
        
        TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
        
        waitForExpectationsWithTimeout(10, handler: nil)
        
        self.tracker.setConfig("hashUserId", value: "false", completionHandler:nil)
    }
    
    func testNoHashUserId() {
        let expectation = expectationWithDescription("test")
        
        self.tracker.setConfig("hashUserId", value: "false", completionHandler:{(isSet) in
            self.tracker.setParam(HitParam.UserID.rawValue, value: "coucou")
            
            let builder = Builder(tracker: self.tracker, volatileParameters: self.tracker.buffer.volatileParameters, persistentParameters: self.tracker.buffer.persistentParameters)
            
            let hits = builder.build()
            let url = NSURL(string: hits[0])
            
            _ = [String: String]()
            let urlComponents = url?.query!.componentsSeparatedByString("&")
            
            for component in urlComponents! as [String] {
                let pairComponents = component.componentsSeparatedByString("=")
                
                if(pairComponents[0] == "idclient") {
                    XCTAssert(pairComponents[1] == "coucou".percentEncodedString, "le paramètre idclient doit être égal à coucou")
                }
            }
        })
        
        expectation.fulfill()
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testUnsetParam() {
        let refCount = tracker.buffer.volatileParameters.count
        tracker.setParam("toto", value: "tata")
        tracker.unsetParam("toto")
        let newCount = tracker.buffer.volatileParameters.count
        XCTAssertTrue(refCount == newCount, "Le nombre d'éléments ne doit pas avoir changé")
    }
}
