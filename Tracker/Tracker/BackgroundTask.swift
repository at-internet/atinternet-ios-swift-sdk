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
//  BackgroundTaskManager.swift
//  Tracker
//

import Foundation
import UIKit

public class BackgroundTask {
    typealias completionBlock = () -> Void
    
    /// Number of running tasks
    lazy var taskCounter: Int = 0
    /// Array of tasks identifiers
    lazy var tasks = [Int: Int]()
    /// Array of tasks completion block
    lazy var tasksCompletionBlocks = [Int: completionBlock]()
    
    /**
    Private initializer (cannot instantiate BackgroundTaskManager)
    */
    private init() {
        
    }
    
    /// BackgroundTaskManager singleton
    static var sharedInstance: BackgroundTask = {
        let instance = BackgroundTask()
        
        return instance
    }()
    
    /**
    Starts a background task
    */
    func begin() -> Int {
        return begin(nil)
    }
    
    /**
    Starts a background and call the callback function when done
    
    :params: completion block to call right before task ends
    */
    func begin(_ completion: (() -> Void)!) -> Int {
        var taskKey = 0
        
        objc_sync_enter(self)
        taskKey = taskCounter
        taskCounter += 1
        objc_sync_exit(self)

#if !AT_EXTENSION
        let identifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.end(taskKey)
        })
#else
        let identifier = -1
#endif
        
        tasks[taskKey] = identifier
        
        if(completion != nil) {
            tasksCompletionBlocks[taskKey] = completion
        }
        
        return taskKey
    }
    
    /**
    Force task to end
    
    :params: ID of the task to end
    */
    func end(_ key: Int) {
        objc_sync_enter(self.tasks)
        
        if let completionBlock = tasksCompletionBlocks[key] {
            completionBlock()
            tasksCompletionBlocks.removeValue(forKey: key)
        }
        
        if let taskId = tasks[key] {
            // On stoppe tous les envoi de hits offline en cours si le délais en background est expiré
            for operation in TrackerQueue.sharedInstance.queue.operations {
                if let sender = operation as? Sender {
                    if(!sender.isExecuting && sender.hit.isOffline) {
                        sender.cancel()
                    }
                }
            }

#if !AT_EXTENSION
            // On arrete la tache en arrière plan
            UIApplication.shared.endBackgroundTask(taskId)
#endif

            tasks[key] = UIBackgroundTaskInvalid
            tasks.removeValue(forKey: key)
        }
        
        objc_sync_exit(self.tasks)
    }
}
