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
//  Player.swift
//  Tracker
//

import UIKit

public class MediaPlayer {
    /// Tracker instance
    var tracker: Tracker
    
    /// Player ID
    public var playerId: Int = 1
    
    /// List of videos attached to this player
    public lazy var videos: Videos = Videos(player: self)
    
    /// List of audios attached to this player
    public lazy var audios: Audios = Audios(player: self)
    
    /// List of live videos attached to this player
    public lazy var liveVideos: LiveVideos = LiveVideos(player: self)
    
    /// List of live audios attached to this player
    public lazy var liveAudios: LiveAudios = LiveAudios(player: self)
    
    /**
    Players initializer
    - parameter tracker: the tracker instance
    - returns: Players instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
    }    
}

public class MediaPlayers {
    /// Tracker instance
    var tracker: Tracker
    
    /// Player ids
    lazy var playerIds: [Int: MediaPlayer] = [Int: MediaPlayer]()
    
    /**
    Players initializer
    - parameter tracker: the tracker instance
    - returns: Players instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    /**
    Add a new ATMediaPlayer
    - returns: ATMediaPlayer instance
    */
    public func add() -> MediaPlayer {
        let player = MediaPlayer(tracker: tracker)
        
        if playerIds.count > 0 {
            player.playerId = playerIds.keys.max()! + 1
        } else {
            player.playerId = 1
        }
        
        playerIds[player.playerId] = player
        
        return player
    }
    
    /**
    Add a new ATMediaPlayer
    - parameter playerId: the player identifier
    - returns: ATMediaPlayer instance
    */
    public func add(_ playerId: Int) -> MediaPlayer {
        
        if (playerIds.index(forKey: playerId) != nil) {
            self.tracker.delegate?.warningDidOccur("A player with the same id already exists.")
            return playerIds[playerId]!
        } else {
            let player = MediaPlayer(tracker: tracker)
            player.playerId = playerId
            playerIds[player.playerId] = player
            
            return player
        }

    }
    
    /**
    Remove an ATMediaPlayer
    - parameter playerId: the player identifier
    */
    public func remove(_ playerId: Int) {
        let player = playerIds[playerId]
        
        if let player = player {
           self.sendStops(player)
        }
        
        playerIds.removeValue(forKey: playerId)
    }
    
    /**
    Remove all ATMediaPlayer
    */
    public func removeAll() {
        for (player) in self.playerIds.values {
            self.sendStops(player)
        }
        
        playerIds.removeAll(keepingCapacity: false)
    }
    
    func sendStops(_ player: MediaPlayer) {
        for (video) in (player.videos.list.values) {
            if let timer = video.timer {
                if (timer.isValid) {
                    video.sendStop()
                }
            }
        }
        
        for (audio) in (player.audios.list.values) {
            if let timer = audio.timer {
                if (timer.isValid) {
                    audio.sendStop()
                }
            }
        }
        
        for (liveVideo) in (player.liveVideos.list.values) {
            if let timer = liveVideo.timer {
                if (timer.isValid) {
                    liveVideo.sendStop()
                }
            }
        }
        
        for (liveAudio) in (player.liveAudios.list.values) {
            if let timer = liveAudio.timer {
                if (timer.isValid) {
                    liveAudio.sendStop()
                }
            }
        }
    }
}
