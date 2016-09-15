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
//  ScreenTests.swift
//  Tracker
//

import UIKit
import XCTest

class ScreenTests: XCTestCase {

    lazy var screen: Screen = Screen(tracker: Tracker())
    lazy var screens: Screens = Screens(tracker: Tracker())
    
    lazy var dynamicScreen: DynamicScreen = DynamicScreen(tracker: Tracker())
    lazy var dynamicScreens: DynamicScreens = DynamicScreens(tracker: Tracker())
    
    let curDate = Date()
    let dateFormatter: DateFormatter = DateFormatter()
    
    func testInitScreen() {
        XCTAssertTrue(screen.name == "", "Le nom de l'écran doit être vide")
        XCTAssertTrue(screen.level2 == nil, "Le niveau 2 de l'écran doit etre nil")
    }
    
    func testSetScreen() {
        screen.name = "Home"
        screen.setEvent()
        
        XCTAssertEqual(screen.tracker.buffer.volatileParameters.count, 4, "Le nombre de paramètres volatiles doit être égal à 4")
        XCTAssert(screen.tracker.buffer.volatileParameters[0].key == "type", "Le premier paramètre doit être type")
        XCTAssert(screen.tracker.buffer.volatileParameters[0].value() == "screen", "La valeur du premier paramètre doit être screen")
        
        XCTAssert(screen.tracker.buffer.volatileParameters[1].key == "action", "Le second paramètre doit être action")
        XCTAssert(screen.tracker.buffer.volatileParameters[1].value() == "view", "La valeur du second paramètre doit être view")
        
        XCTAssert(screen.tracker.buffer.volatileParameters[2].key == "p", "Le troisième paramètre doit être p")
        XCTAssert(screen.tracker.buffer.volatileParameters[2].value() == "Home", "La valeur du troisième paramètre doit être Home")
    }
    
    func testSetScreenWithNameAndChapter() {
        screen = screens.add("Basket", chapter1: "Sport")
        screen.setEvent()
        
        XCTAssert(screen.tracker.buffer.volatileParameters[2].key == "p", "Le troisième paramètre doit être p")
        XCTAssert(screen.tracker.buffer.volatileParameters[2].value() == "Sport::Basket", "La valeur du troisième paramètre doit être Sport::Basket")
    }
    
    func testAddScreen() {
        screen = screens.add()
        XCTAssert(screens.tracker.businessObjects.count == 1, "Le nombre d'objet en attente doit être égale à 1")
        XCTAssert(screen.name == "", "Le nom de l'écran doit etre vide")
        XCTAssert((screens.tracker.businessObjects[screen.id] as! Screen).name == "", "Le nom de l'écran doit etre vide")
    }
    
    func testAddScreenWithName() {
        screen = screens.add("Home")
        XCTAssert(screens.tracker.businessObjects.count == 1, "Le nombre d'objet en attente doit être égale à 1")
        XCTAssert(screen.name == "Home", "Le nom de l'écran doit etre égal à Home")
        XCTAssert((screens.tracker.businessObjects[screen.id] as! Screen).name == "Home", "Le nom de l'écran doit etre égal à Home")
    }
    
    func testAddScreenWithNameAndLevel2() {
        screen = screens.add("Home")
        screen.level2 = 1
        XCTAssert(screens.tracker.businessObjects.count == 1, "Le nombre d'objet en attente doit être égale à 1")
        XCTAssert(screen.name == "Home", "Le nom de l'écran doit etre égal à Home")
        XCTAssert(screen.level2! == 1, "Le niveau 2 doit être égal à 1")
        XCTAssert((screens.tracker.businessObjects[screen.id] as! Screen).name == "Home", "Le nom de l'écran doit etre égal à Home")
        XCTAssert((screens.tracker.businessObjects[screen.id] as! Screen).level2! == 1, "Le niveau 2 doit être égal à 1")
    }
    
    func testSetDynamicScreen() {
        dateFormatter.dateFormat = "YYYYMMddHHmm"
        
        dynamicScreen.screenId = "123"
        dynamicScreen.update = curDate;
        dynamicScreen.name = "HomeDyn"
        dynamicScreen.chapter1 = "chap1"
        dynamicScreen.chapter2 = "chap2"
        dynamicScreen.chapter3 = "chap3"
        
        dynamicScreen.setEvent()
        
        XCTAssertEqual(dynamicScreen.tracker.buffer.volatileParameters.count, 7, "Le nombre de paramètres volatiles doit être égal à 7")
        
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[0].key == "pchap", "Le paramètre doit être pchap")
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[0].value() == "chap1::chap2::chap3", "La valeur doit être chap1::chap2::chap3")
        
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[1].key == "pid", "Le paramètre doit être pid")
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[1].value() == "123", "La valeur doit être 123")
        
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[2].key == "pidt", "Le paramètre doit être pidt")
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[2].value() == dateFormatter.string(from: curDate), "La valeur doit être curDate")
        
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[3].key == "type", "Le premier paramètre doit être type")
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[3].value() == "screen", "La valeur du premier paramètre doit être screen")
        
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[4].key == "action", "Le second paramètre doit être action")
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[4].value() == "view", "La valeur du second paramètre doit être view")
        
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[5].key == "p", "Le troisième paramètre doit être p")
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[5].value() == "HomeDyn", "La valeur du troisième paramètre doit être HomeDyn")
    }
    
    func testSetDynamicScreenWithTooLongStringId() {
        dateFormatter.dateFormat = "YYYYMMddHHmm"
        
        var s = ""
        for i in 0 ..< 256 {
            s += String(i)
        }
        
        dynamicScreen.screenId = s
        dynamicScreen.update = curDate;
        dynamicScreen.name = "HomeDyn"
        dynamicScreen.chapter1 = "chap1"
        dynamicScreen.chapter2 = "chap2"
        dynamicScreen.chapter3 = "chap3"
        
        dynamicScreen.setEvent()
        
        XCTAssertEqual(dynamicScreen.tracker.buffer.volatileParameters.count, 7, "Le nombre de paramètres volatiles doit être égal à 7")
        
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[0].key == "pchap", "Le paramètre doit être pchap")
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[0].value() == "chap1::chap2::chap3", "La valeur doit être chap1::chap2::chap3")
        
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[1].key == "pid", "Le paramètre doit être pid")
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[1].value() == "", "La valeur doit être vide")
        
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[2].key == "pidt", "Le paramètre doit être pidt")
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[2].value() == dateFormatter.string(from: curDate), "La valeur doit être curDate")
        
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[3].key == "type", "Le premier paramètre doit être type")
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[3].value() == "screen", "La valeur du premier paramètre doit être screen")
        
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[4].key == "action", "Le second paramètre doit être action")
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[4].value() == "view", "La valeur du second paramètre doit être view")
        
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[5].key == "p", "Le troisième paramètre doit être p")
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters[5].value() == "HomeDyn", "La valeur du troisième paramètre doit être HomeDyn")
    }
    
    func testAddDynamicScreen() {
        dateFormatter.dateFormat = "YYYYMMddHHmm"
        
        dynamicScreen = dynamicScreens.add("123", update: curDate, name: "HomeDyn")
        
        XCTAssert(dynamicScreens.tracker.businessObjects.count == 1, "Le nombre d'objet en attente doit être égale à 1")
        
        XCTAssert(dynamicScreen.name == "HomeDyn", "Le nom de l'écran doit etre égal à HomeDyn")
        XCTAssert((dynamicScreens.tracker.businessObjects[dynamicScreen.id] as! DynamicScreen).name == "HomeDyn", "Le nom de l'écran doit etre égal à HomeDyn")
        
        XCTAssert(dynamicScreen.screenId == "123", "L'identifiant d'écran doit etre égal à 123")
        XCTAssert((dynamicScreens.tracker.businessObjects[dynamicScreen.id] as! DynamicScreen).screenId == "123", "L'identifiant d'écran doit etre égal à 123")
        
        XCTAssert(dynamicScreen.update == curDate, "La date de l'écran doit être égal à curDate")
        XCTAssert((dynamicScreens.tracker.businessObjects[dynamicScreen.id] as! DynamicScreen).update == curDate, "La date de l'écran doit être égal à curDate")
    }
    
    func testAddDynamicScreenWithChapter() {
        dateFormatter.dateFormat = "YYYYMMddHHmm"
        
        dynamicScreen = dynamicScreens.add(123, update: curDate, name: "HomeDyn", chapter1: "chap1")
        
        XCTAssert(dynamicScreens.tracker.businessObjects.count == 1, "Le nombre d'objet en attente doit être égale à 1")
        
        XCTAssert(dynamicScreen.name == "HomeDyn", "Le nom de l'écran doit etre égal à HomeDyn")
        XCTAssert((dynamicScreens.tracker.businessObjects[dynamicScreen.id] as! DynamicScreen).name == "HomeDyn", "Le nom de l'écran doit etre égal à HomeDyn")
        
        XCTAssert(dynamicScreen.screenId == "123", "L'identifiant d'écran doit etre égal à 123")
        XCTAssert((dynamicScreens.tracker.businessObjects[dynamicScreen.id] as! DynamicScreen).screenId == "123", "L'identifiant d'écran doit etre égal à 123")
        
        XCTAssert(dynamicScreen.update == curDate, "La date de l'écran doit être égal à curDate")
        XCTAssert((dynamicScreens.tracker.businessObjects[dynamicScreen.id] as! DynamicScreen).update == curDate, "La date de l'écran doit être égal à curDate")
        
        XCTAssert(dynamicScreen.chapter1 == "chap1", "Le chapitre 1 de l'écran doit être égal à chap1")
        XCTAssert((dynamicScreens.tracker.businessObjects[dynamicScreen.id] as! DynamicScreen).chapter1 == "chap1", "Le chapitre 1 de l'écran doit être égal à chap1")
    }
}
