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
//  LiveAudio.swift
//  Tracker
//

import UIKit

public class LiveAudio: RichMedia {
   
    /// Media type
    let type: String = "audio"
    
    /// Set parameters in buffer
    override func setEvent() {
        super.broadcastMode = .Live
        
        super.setEvent()
        
        self.tracker = self.tracker.setParam("type", value: type)
    }
    
}

public class LiveAudios {
    
    var list: [String: LiveAudio] = [String: LiveAudio]()
    
    /// MediaPlayer instance
    var player: MediaPlayer
    
    /**
    LiveAudios initializer
    - parameter player: the player instance
    - returns: LiveAudios instance
    */
    init(player: MediaPlayer) {
        self.player = player
    }
    
    /**
    Create a new live audio
    - parameter audio: name
    - parameter first: chapter
    - returns: live audio instance
    */
    public func add(_ name:String) -> LiveAudio {
        if let audio = self.list[name] {
            self.player.tracker.delegate?.warningDidOccur("A LiveAudio with the same name already exists.")
            return audio
        } else {
            let audio = LiveAudio(player: player)
            audio.name = name
            
            self.list[name] = audio
            
            return audio
        }
    }
    
    /**
    Create a new live audio
    - parameter audio: name
    - parameter first: chapter
    - returns: live audio instance
    */
    public func add(_ name: String, chapter1: String) -> LiveAudio {
        if let audio = self.list[name] {
            self.player.tracker.delegate?.warningDidOccur("A LiveAudio with the same name already exists.")
            return audio
        } else {
            let audio = LiveAudio(player: player)
            audio.name = name
            audio.chapter1 = chapter1
            
            self.list[name] = audio
            
            return audio
        }
    }
    
    /**
    Create a new live audio
    - parameter audio: name
    - parameter first: chapter
    - parameter second: chapter
    - returns: live audio instance
    */
    public func add(_ name: String, chapter1: String, chapter2: String) -> LiveAudio {
        if let audio = self.list[name] {
            self.player.tracker.delegate?.warningDidOccur("A LiveAudio with the same name already exists.")
            return audio
        } else {
            let audio = LiveAudio(player: player)
            audio.name = name
            audio.chapter1 = chapter1
            audio.chapter2 = chapter2
            
            self.list[name] = audio
            
            return audio
        }
    }
    
    /**
    Create a new live audio
    - parameter audio: name
    - parameter first: chapter
    - parameter second: chapter
    - parameter third: chapter
    - returns: live audio instance
    */
    public func add(_ name: String, chapter1: String, chapter2: String, chapter3: String) -> LiveAudio {
        if let audio = self.list[name] {
            self.player.tracker.delegate?.warningDidOccur("A LiveAudio with the same name already exists.")
            return audio
        } else {
            let audio = LiveAudio(player: player)
            audio.name = name
            audio.chapter1 = chapter1
            audio.chapter2 = chapter2
            audio.chapter3 = chapter3
            
            self.list[name] = audio
            
            return audio
        }
    }
    
    /**
    Remove a live audio
    - parameter audio: name
    */
    public func remove(_ name: String) {
        if let timer = list[name]?.timer {
            if timer.isValid {
                list[name]!.sendStop()
            }
        }
        self.list.removeValue(forKey: name)
    }
    
    /**
    Remove all live audios
    */
    public func removeAll() {
        for (_, value) in self.list {
            if let timer = value.timer {
                if timer.isValid {
                    value.sendStop()
                }
            }
        }
        self.list.removeAll(keepingCapacity: false)
    }
    
}
