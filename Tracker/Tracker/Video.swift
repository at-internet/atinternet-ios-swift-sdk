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
//  Video.swift
//  Tracker
//

import UIKit

public class Video: RichMedia {
    
    /// Media type
    let type: String = "video"
    
    /// Duration
    public var duration: Int = 0
    
    /// Set parameters in buffer
    override func setEvent() {
        super.setEvent()
        
        if (self.duration > 86400) {
            self.duration = 86400
        }
        _ = self.tracker.setParam("m1", value: duration)
            .setParam("type", value: type)
    }
    
}

public class Videos {
    
    var list: [String: Video] = [String: Video]()
    
    /// MediaPlayer instance
    var player: MediaPlayer
    
    /**
    Videos initializer
    - parameter player: the player instance
    - returns: Videos instance
    */
    init(player: MediaPlayer) {
        self.player = player
    }
    
    /**
    Create a new video
    - parameter video: name
    - parameter video: duration in seconds
    - returns: video instance
    */
    public func add(_ name:String, duration: Int) -> Video {
        if let video = self.list[name] {
            self.player.tracker.delegate?.warningDidOccur("A Video with the same name already exists.")
            return video
        } else {
            let video = Video(player: player)
            video.name = name
            video.duration = duration
            
            self.list[name] = video
            
            return video
        }
    }
    
    /**
    Create a new video
    - parameter video: name
    - parameter first: chapter
    - parameter video: duration in seconds
    - returns: video instance
    */
    public func add(_ name: String, chapter1: String, duration: Int) -> Video {
        if let video = self.list[name] {
            self.player.tracker.delegate?.warningDidOccur("A Video with the same name already exists.")
            return video
        } else {
            let video = Video(player: player)
            video.name = name
            video.duration = duration
            video.chapter1 = chapter1
            
            self.list[name] = video
            
            return video
        }
    }
    
    /**
    Create a new video
    - parameter video: name
    - parameter first: chapter
    - parameter second: chapter
    - parameter video: duration in seconds
    - returns: video instance
    */
    public func add(_ name: String, chapter1: String, chapter2: String, duration: Int) -> Video {
        if let video = self.list[name] {
            self.player.tracker.delegate?.warningDidOccur("A Video with the same name already exists.")
            return video
        } else {
            let video = Video(player: player)
            video.name = name
            video.duration = duration
            video.chapter1 = chapter1
            video.chapter2 = chapter2
            
            self.list[name] = video
            
            return video
        }
    }
    
    /**
    Create a new video
    - parameter video: name
    - parameter first: chapter
    - parameter second: chapter
    - parameter third: chapter
    - parameter video: duration in seconds
    - returns: video instance
    */
    public func add(_ name: String, chapter1: String, chapter2: String, chapter3: String, duration: Int) -> Video {
        if let video = self.list[name] {
            self.player.tracker.delegate?.warningDidOccur("A Video with the same name already exists.")
            return video
        } else {
            let video = Video(player: player)
            video.name = name
            video.duration = duration
            video.chapter1 = chapter1
            video.chapter2 = chapter2
            video.chapter3 = chapter3
            
            self.list[name] = video
            
            return video
        }
    }
    
    /**
    Remove a video
    - parameter video: name
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
    Remove all videos
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
