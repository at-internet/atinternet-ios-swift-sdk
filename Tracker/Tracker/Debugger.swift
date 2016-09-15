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
//  Debug.swift
//  Tracker
//

import UIKit

class Debugger {
    
    /// View controller where to display debugger
    weak var _viewController: UIViewController?
    
    weak var viewController: UIViewController? {
        get {
            return _viewController
        }
        set {
            if(newValue != nil) {
                if(_viewController != nil) {
                    if(newValue != _viewController) {
                        _viewController = newValue
                        deinitDebugger()
                        initDebugger()
                        updateEventList()
                    }
                } else {
                    _viewController = newValue
                    
                    initDebugger()
                }
            } else {
                deinitDebugger()
                
                _viewController = newValue
            }
        }
    }
    /// Debug button
    lazy var debugButton: UIButton = UIButton()
    /// Debug button position
    var debugButtonPosition: String = "Right"
    /// List of all created windows
    lazy var windows: [(window:UIView, content:UIView, menu: UIView, windowTitle: String)] = []
    /// Window title
    lazy var windowTitleLabel = UILabel()
    /// List of offline hits
    lazy var hits: [Hit] = []
    /// Gesture recogniser for debug button
    var gestureRecogniser: UIPanGestureRecognizer!
    /// Debug button constraint (for animation)
    var debugButtonConstraint: NSLayoutConstraint!
    /// List of received events
    var receivedEvents: [DebuggerEvent] = []
    /// Is debugger visible or not
    var debuggerShown:Bool = false
    /// Is debugger animating
    var debuggerAnimating: Bool = false
    /// Date formatter (HH:mm:ss)
    let hourFormatter = DateFormatter()
    /// Date formatter (dd/MM/yyyy HH:mm:ss)
    let dateHourFormatter = DateFormatter()
    /// Offline storage
    let storage = Storage.sharedInstance
    
    static let sharedInstance: Debugger = {
        let instance = Debugger()
        return instance
    }()

    
    /**
     Add debugger to view controller
     */
    func initDebugger() {
        hourFormatter.dateFormat = "HH':'mm':'ss"
        hourFormatter.locale = LifeCycle.locale
        dateHourFormatter.dateFormat = "dd'/'MM'/'YYYY' 'HH':'mm':'ss"
        dateHourFormatter.locale = LifeCycle.locale
        
        createDebugButton()
        createEventViewer()
        
        gestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(Debugger.debugButtonWasDragged(_:)))
        debugButton.addGestureRecognizer(gestureRecogniser)
        
        viewController!.view.bringSubview(toFront: debugButton)
    }
    
    /**
     Remove debugger from view controller
     */
    func deinitDebugger() {
        debuggerShown = false
        debuggerAnimating = false
        
        debugButton.removeFromSuperview()
        
        for(_, window) in self.windows.enumerated() {
            window.window.removeFromSuperview()
        }
        
        self.windows.removeAll(keepingCapacity: false)
    }
    
    /**
     Add an event to the event list
     */
    func addEvent(_ message: String, icon: String) {
        let event = DebuggerEvent()
        event.date = Date()
        event.type = icon
        event.message = message
        
        self.receivedEvents.insert(event, at: 0)
        DispatchQueue.main.sync(execute: {
            self.addEventToList()
        })
    }
    
    // MARK: Debug button
    
    /**
     Create debug button
     */
    func createDebugButton() {
        debugButton.setBackgroundImage(UIImage(named: "atinternet-logo", in: Bundle(for: Tracker.self), compatibleWith: nil), for: UIControlState())
        debugButton.frame = CGRect(x: 0, y: 0, width: 94, height: 73)
        debugButton.translatesAutoresizingMaskIntoConstraints = false
        debugButton.alpha = 0
        
        self.viewController!.view.addSubview(debugButton)
        
        // align atButton from the left
        if(debugButtonPosition == "Right") {
            debugButtonConstraint = NSLayoutConstraint(item: debugButton,
                                                       attribute: NSLayoutAttribute.trailing,
                                                       relatedBy: NSLayoutRelation.equal,
                                                       toItem: self.viewController!.view,
                                                       attribute: NSLayoutAttribute.trailing,
                                                       multiplier: 1.0,
                                                       constant: 0)
        } else {
            debugButtonConstraint = NSLayoutConstraint(item: debugButton,
                                                       attribute: NSLayoutAttribute.leading,
                                                       relatedBy: NSLayoutRelation.equal,
                                                       toItem: self.viewController!.view,
                                                       attribute: NSLayoutAttribute.leading,
                                                       multiplier: 1.0,
                                                       constant: 0)
        }
        
        self.viewController!.view.addConstraint(debugButtonConstraint)
        
        self.viewController!.view.addConstraint(NSLayoutConstraint(item: self.viewController!.bottomLayoutGuide,
            attribute: NSLayoutAttribute.top,
            relatedBy: NSLayoutRelation.equal,
            toItem: debugButton,
            attribute: NSLayoutAttribute.bottom,
            multiplier: 1.0,
            constant: 10))
        
        // width constraint
        self.viewController!.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[debugButton(==94)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["debugButton": debugButton]))
        
        // height constraint
        self.viewController!.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[debugButton(==73)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["debugButton": debugButton]))
        
        debugButton.addTarget(self, action: #selector(Debugger.debuggerTouched), for: UIControlEvents.touchUpInside)
        
        UIView.animate(
            withDuration: 0.4,
            delay: 0.0,
            options: UIViewAnimationOptions.curveLinear,
            animations: {
                self.debugButton.alpha = 1.0;
            },
            completion: nil)
    }
    
    /**
     Debug button was dragged (change postion from left to right ...)
     */
    @objc func debugButtonWasDragged(_ recogniser: UIPanGestureRecognizer) {
        let button = recogniser.view as! UIButton
        let translation = recogniser.translation(in: button)
        
        let velocity = recogniser.velocity(in: button)
        
        if (recogniser.state == UIGestureRecognizerState.changed)
        {
            button.center = CGPoint(x: button.center.x + translation.x, y: button.center.y)
            recogniser.setTranslation(CGPoint.zero, in: button)
        }
        else if (recogniser.state == UIGestureRecognizerState.ended)
        {
            if(velocity.x < 0) {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.debugButtonConstraint.constant = (self.viewController!.view.frame.width - button.frame.width) * -1
                    self.viewController!.view.layoutIfNeeded()
                    self.viewController!.view.updateConstraints()
                    }, completion: {
                        finished in
                        self.debugButtonPosition = "Left"
                        self.viewController!.view.removeConstraint(self.debugButtonConstraint)
                        
                        self.debugButtonConstraint = NSLayoutConstraint(item: self.debugButton,
                            attribute: NSLayoutAttribute.leading,
                            relatedBy: NSLayoutRelation.equal,
                            toItem: self.viewController!.view,
                            attribute: NSLayoutAttribute.leading,
                            multiplier: 1.0,
                            constant: 0)
                        
                        self.viewController!.view.addConstraint(self.debugButtonConstraint)
                })
            } else {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.debugButtonConstraint.constant = (self.viewController!.view.frame.width - button.frame.width)
                    self.viewController!.view.layoutIfNeeded()
                    self.viewController!.view.updateConstraints()
                    }, completion: {
                        finished in
                        self.debugButtonPosition = "Right"
                        self.viewController!.view.removeConstraint(self.debugButtonConstraint)
                        
                        self.debugButtonConstraint = NSLayoutConstraint(item: self.debugButton,
                            attribute: NSLayoutAttribute.trailing,
                            relatedBy: NSLayoutRelation.equal,
                            toItem: self.viewController!.view,
                            attribute: NSLayoutAttribute.trailing,
                            multiplier: 1.0,
                            constant: 0)
                        
                        self.viewController!.view.addConstraint(self.debugButtonConstraint)
                })
            }
        }
    }
    
    /**
     Debug button was touched
     */
    @objc func debuggerTouched() {
        for w in self.windows {
            w.window.isHidden = false
        }
        
        if(self.debuggerShown && !debuggerAnimating) {
            debuggerAnimating = true
            
            UIView.animate(
                withDuration: 0.2,
                delay: 0.0,
                options: UIViewAnimationOptions.curveLinear,
                animations: {
                    for w in self.windows {
                        w.content.alpha = 0.0
                        w.menu.alpha = 0.0
                    }
                },
                completion: {
                    finished in
                    self.animateEventLog()
            })
        } else {
            debuggerAnimating = true
            
            animateEventLog()
        }
    }
    
    /**
     Animate window (show or hide)
     */
    func animateEventLog() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: UIViewAnimationOptions.curveEaseIn,
            animations: {
                if(self.debuggerShown) {
                    if(self.debugButtonPosition == "Right") {
                        for w in self.windows {
                            w.window.frame = CGRect(x: self.viewController!.view.frame.width - 47, y: self.viewController!.view.frame.height - (self.viewController!.bottomLayoutGuide.length + 93), width: 0, height: 0)
                        }
                    } else {
                        for w in self.windows {
                            w.window.frame = CGRect(x: 47, y: self.viewController!.view.frame.height - (self.viewController!.bottomLayoutGuide.length + 93), width: 0, height: 0)
                        }
                    }
                } else {
                    for w in self.windows {
                        w.window.frame = CGRect(x: 10, y: (self.viewController!.topLayoutGuide.length + 10), width: self.viewController!.view.frame.width - 20, height: self.viewController!.view.frame.height - (self.viewController!.bottomLayoutGuide.length + 93) - (self.viewController!.topLayoutGuide.length + 10))
                    }
                }
            },
            completion: {
                finished in
                
                if(!self.debuggerShown) {
                    UIView.animate(
                        withDuration: 0.2,
                        delay: 0.0,
                        options: UIViewAnimationOptions.curveLinear,
                        animations: {
                            for w in self.windows {
                                w.content.alpha = 1.0
                                w.menu.alpha = 1.0
                            }
                        },
                        completion: nil)
                    
                    self.viewController!.view.bringSubview(toFront: self.windows[self.windows.count - 1].window)
                } else {
                    for w in self.windows {
                        w.window.isHidden = true
                    }
                }
                
                self.debuggerShown = !self.debuggerShown
                self.debuggerAnimating = false
        })
    }
    
    //MARK: Event viewer
    
    /**
     Create event viewer window
     */
    func createEventViewer() {
        let eventViewer: (window: UIView, content: UIView, menu: UIView, windowTitle: String) = self.createWindow("Event viewer")
        
        let offlineButton = UIButton()
        offlineButton.translatesAutoresizingMaskIntoConstraints = false
        offlineButton.setBackgroundImage(UIImage(named: "database64", in: Bundle(for: Tracker.self), compatibleWith: nil), for: UIControlState())
        offlineButton.addTarget(self, action: #selector(Debugger.createOfflineHitsViewer), for: UIControlEvents.touchUpInside)
        
        eventViewer.menu.addSubview(offlineButton)
        
        // width constraint
        eventViewer.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[offlineButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["offlineButton": offlineButton]))
        
        // height constraint
        eventViewer.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[offlineButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["offlineButton": offlineButton]))
        
        eventViewer.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[offlineButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["offlineButton": offlineButton]))
        
        // align messageLabel from the top and bottom
        eventViewer.menu.addConstraint(NSLayoutConstraint(item: offlineButton,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: eventViewer.menu,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0))
        
        windowTitleLabel.text = eventViewer.windowTitle
        windowTitleLabel.textColor = UIColor.white
        windowTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        eventViewer.menu.addSubview(windowTitleLabel)
        
        // align messageLabel from the top and bottom
        eventViewer.menu.addConstraint(NSLayoutConstraint(item: windowTitleLabel,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: eventViewer.menu,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0))
        
        eventViewer.menu.addConstraint(NSLayoutConstraint(item: windowTitleLabel,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: eventViewer.menu,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0))
        
        let trashButton = UIButton()
        
        eventViewer.menu.addSubview(trashButton)
        
        trashButton.translatesAutoresizingMaskIntoConstraints = false
        
        trashButton.setBackgroundImage(UIImage(named: "trash64", in: Bundle(for: Tracker.self), compatibleWith: nil), for: UIControlState())
        trashButton.addTarget(self, action: #selector(Debugger.trashEvents), for: UIControlEvents.touchUpInside)
        
        // width constraint
        eventViewer.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[trashButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["trashButton": trashButton]))
        
        // height constraint
        eventViewer.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[trashButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["trashButton": trashButton]))
        
        eventViewer.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[trashButton]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["trashButton": trashButton]))
        
        // align messageLabel from the top and bottom
        eventViewer.menu.addConstraint(NSLayoutConstraint(item: trashButton,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: eventViewer.menu,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0))
        
        getEventsList(eventViewer)
    }
    
    /**
     Builds offline hits list rows
     */
    func getEventsList(_ eventViewer: (window:UIView, content:UIView, menu: UIView, windowTitle: String)) {
        
        let scrollViews = eventViewer.content.subviews.filter({ return $0 is UIScrollView }) as! [UIScrollView]
        let emptyEventList = eventViewer.content.subviews.filter() {
            if($0.tag == -2) {
                return true
            } else {
                return false
            }
        }
        
        if(scrollViews.count > 0) {
            for row in scrollViews[0].subviews {
                row.tag = 9999999
                row.removeFromSuperview()
            }
            
            scrollViews[0].removeFromSuperview()
        }
        
        if(emptyEventList.count > 0) {
            emptyEventList[0].removeFromSuperview()
        }
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        scrollView.tag = -100
        
        eventViewer.content.addSubview(scrollView)
        
        eventViewer.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .top,
            relatedBy: .equal,
            toItem: eventViewer.content,
            attribute: .top,
            multiplier: 1.0,
            constant: 0))
        
        eventViewer.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: eventViewer.content,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0))
        
        eventViewer.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: eventViewer.content,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0))
        
        eventViewer.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: eventViewer.content,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0))
        
        if(receivedEvents.count == 0) {
            let emptyContentView = UIView()
            emptyContentView.tag = -2
            emptyContentView.translatesAutoresizingMaskIntoConstraints = false
            emptyContentView.layer.cornerRadius = 4.0
            emptyContentView.backgroundColor = UIColor(red: 139/255.0, green: 139/255.0, blue: 139/255.0, alpha: 1)
            
            eventViewer.content.addSubview(emptyContentView)
            
            // height constraint
            eventViewer.content.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[emptyContentView(==50)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["emptyContentView": emptyContentView]))
            
            eventViewer.content.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-30-[emptyContentView]-30-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["emptyContentView": emptyContentView]))
            
            // align messageLabel from the top and bottom
            eventViewer.content.addConstraint(NSLayoutConstraint(item: emptyContentView,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: eventViewer.content,
                attribute: .centerY,
                multiplier: 1.0,
                constant: 0))
            
            let emptyContentLabel = UILabel()
            emptyContentLabel.translatesAutoresizingMaskIntoConstraints = false
            emptyContentLabel.text = "No event detected"
            emptyContentLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            emptyContentLabel.sizeToFit()
            
            emptyContentView.addSubview(emptyContentLabel)
            
            emptyContentView.addConstraint(NSLayoutConstraint(item: emptyContentLabel,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: emptyContentView,
                attribute: .centerY,
                multiplier: 1.0,
                constant: 0))
            
            emptyContentView.addConstraint(NSLayoutConstraint(item: emptyContentLabel,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: emptyContentView,
                attribute: .centerX,
                multiplier: 1.0,
                constant: 0))
        } else {
            previousConstraintForEvents = nil
            var previous: UIView?
            for (i, event) in receivedEvents.reversed().enumerated() {
                previous = buildEventRow(event, tag: i, scrollView: scrollView, previousRow: previous)
            }
        }
    }
    
    var previousConstraintForEvents: NSLayoutConstraint!
    func buildEventRow(_ event: DebuggerEvent, tag: Int, scrollView: UIScrollView, previousRow: UIView?) -> UIView {
        let rowView = UIView()
        rowView.translatesAutoresizingMaskIntoConstraints = false
        rowView.isUserInteractionEnabled = true
        rowView.tag = tag
        rowView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Debugger.eventRowSelected(_:))))
        
        scrollView.insertSubview(rowView, at: 0)
        
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[rowView]-0-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["rowView": rowView]))
        
        if previousConstraintForEvents != nil {
            scrollView.removeConstraint(previousConstraintForEvents)
        }
        
        previousConstraintForEvents = NSLayoutConstraint(item: rowView,
                                                         attribute: .top,
                                                         relatedBy: .equal,
                                                         toItem: scrollView,
                                                         attribute: .top,
                                                         multiplier: 1.0,
                                                         constant: 0)
        scrollView.addConstraint(previousConstraintForEvents)
        
        if(tag == 0) {
            scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                                                        attribute: .centerX,
                                                        relatedBy: .equal,
                                                        toItem: scrollView,
                                                        attribute: .centerX,
                                                        multiplier: 1.0,
                                                        constant: 0))
            
            scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                                                        attribute: .bottom,
                                                        relatedBy: .equal,
                                                        toItem: scrollView,
                                                        attribute: .bottom,
                                                        multiplier: 1.0,
                                                        constant: 0))
        } else {
            if let previous = previousRow {
                scrollView.addConstraint(NSLayoutConstraint(item: previous,
                                                            attribute: .top,
                                                            relatedBy: .equal,
                                                            toItem: rowView,
                                                            attribute: .bottom,
                                                            multiplier: 1.0,
                                                            constant: 0))
            }
        }
        
        if(tag % 2 == 0) {
            rowView.backgroundColor = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
        } else {
            rowView.backgroundColor = UIColor.white
        }
        
        let iconView = UIImageView()
        let dateLabel = UILabel()
        let messageLabel = UILabel()
        let hitTypeView = UIImageView()
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        hitTypeView.translatesAutoresizingMaskIntoConstraints = false
        
        rowView.addSubview(iconView)
        rowView.addSubview(dateLabel)
        rowView.addSubview(messageLabel)
        rowView.addSubview(hitTypeView)
        
        /******* ICON ********/
        iconView.image = UIImage(named: event.type, in: Bundle(for: Tracker.self), compatibleWith: nil)
        
        rowView.addConstraint(NSLayoutConstraint(item: iconView,
                                                 attribute: .left,
                                                 relatedBy: .equal,
                                                 toItem: rowView,
                                                 attribute: .left,
                                                 multiplier: 1.0,
                                                 constant: 5))
        
        // align iconView from the top and bottom
        rowView.addConstraint(NSLayoutConstraint(item: iconView,
                                                 attribute: .centerY,
                                                 relatedBy: .equal,
                                                 toItem: rowView,
                                                 attribute: .centerY,
                                                 multiplier: 1.0,
                                                 constant: -1))
        
        // width constraint
        rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[iconView(==24)]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["iconView": iconView]))
        
        // height constraint
        rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[iconView(==24)]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["iconView": iconView]))
        /******* END ICON ********/
        
        /******* DATE ********/
        dateLabel.text = hourFormatter.string(from: event.date)
        dateLabel.sizeToFit();
        
        // align iconView from the top and bottom
        rowView.addConstraint(NSLayoutConstraint(item: dateLabel,
                                                 attribute: .left,
                                                 relatedBy: .equal,
                                                 toItem: iconView,
                                                 attribute: .right,
                                                 multiplier: 1.0,
                                                 constant: 5))
        
        rowView.addConstraint(NSLayoutConstraint(item: dateLabel,
                                                 attribute: .centerY,
                                                 relatedBy: .equal,
                                                 toItem: rowView,
                                                 attribute: .centerY,
                                                 multiplier: 1.0,
                                                 constant: 0))
        /******* END DATE ********/
        
        /******* HIT ********/
        messageLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        messageLabel.baselineAdjustment = UIBaselineAdjustment.none
        messageLabel.text = event.message
        
        rowView.addConstraint(NSLayoutConstraint(item: messageLabel,
                                                 attribute: .left,
                                                 relatedBy: .equal,
                                                 toItem: dateLabel,
                                                 attribute: .right,
                                                 multiplier: 1.0,
                                                 constant: 10))
        
        rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[messageLabel]-12-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["messageLabel": messageLabel]))
        
        /******* END HIT ********/
        
        /******* HIT TYPE ********/
        let URL = NSURL(string: event.message)
        
        if let optURL = URL {
            hitTypeView.isHidden = false
            
            let hit = Hit(url: optURL.absoluteString!)
            
            switch(hit.getHitType()) {
            case Hit.HitType.touch:
                hitTypeView.image = UIImage(named: "touch48", in: Bundle(for: Tracker.self), compatibleWith: nil)
            case Hit.HitType.adTracking:
                hitTypeView.image = UIImage(named: "tv48", in: Bundle(for: Tracker.self), compatibleWith: nil)
            case Hit.HitType.audio:
                hitTypeView.image = UIImage(named: "audio48", in: Bundle(for: Tracker.self), compatibleWith: nil)
            case Hit.HitType.video:
                hitTypeView.image = UIImage(named: "video48", in: Bundle(for: Tracker.self), compatibleWith: nil)
            case Hit.HitType.productDisplay:
                hitTypeView.image = UIImage(named: "product48", in: Bundle(for: Tracker.self), compatibleWith: nil)
            default:
                hitTypeView.image = UIImage(named: "smartphone48", in: Bundle(for: Tracker.self), compatibleWith: nil)
            }
        } else {
            hitTypeView.isHidden = true
        }
        
        rowView.addConstraint(NSLayoutConstraint(item: hitTypeView,
                                                 attribute: .left,
                                                 relatedBy: NSLayoutRelation.greaterThanOrEqual,
                                                 toItem: messageLabel,
                                                 attribute: .right,
                                                 multiplier: 1.0,
                                                 constant: 10))
        
        // align iconView from the top and bottom
        rowView.addConstraint(NSLayoutConstraint(item: hitTypeView,
                                                 attribute: .centerY,
                                                 relatedBy: .equal,
                                                 toItem: rowView,
                                                 attribute: .centerY,
                                                 multiplier: 1.0,
                                                 constant: -1))
        
        // width constraint
        rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[hitTypeView(==24)]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["hitTypeView": hitTypeView]))
        
        // height constraint
        rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[hitTypeView(==24)]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["hitTypeView": hitTypeView]))
        
        rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[hitTypeView]-5-|", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["hitTypeView": hitTypeView]))
        
        return rowView
    }
    
    /**
     Reload event list
     */
    func updateEventList() {
        getEventsList(self.windows[0])
    }
    
    @objc func addEventToList() {
        let window = self.windows[0]
        
        window.content.viewWithTag(-2)?.removeFromSuperview()
        
        let scrollview = window.content.viewWithTag(-100) as! UIScrollView
        
        _ = buildEventRow(self.receivedEvents[0], tag: self.receivedEvents.count - 1, scrollView: scrollview, previousRow: scrollview.viewWithTag(self.receivedEvents.count - 2))
    }
    
    /**
     event list row selected
     */
    @objc func eventRowSelected(_ recogniser: UIPanGestureRecognizer) {
        self.windows[0].content.isHidden = true
        
        if let row = recogniser.view {
            let window = createEventDetailView(receivedEvents[row.tag].message)
            
            hidePreviousWindowMenuButtons(window)
        }
    }
    
    /**
     Delete received events
     */
    @objc func trashEvents() {
        self.receivedEvents.removeAll(keepingCapacity: false)
        updateEventList()
    }
    
    //MARK: Event detail
    
    /**
     Create event detail window
     
     - parameter hit: or message to display
     */
    func createEventDetailView(_ hit: String) -> UIView {
        var eventDetail: (window: UIView, content: UIView, menu: UIView, windowTitle: String) = self.createWindow("Hit Detail")
        eventDetail.window.alpha = 0.0;
        eventDetail.window.isHidden = false
        eventDetail.content.alpha = 1.0
        eventDetail.menu.alpha = 1.0
        
        let backButton = UIButton()
        
        eventDetail.menu.addSubview(backButton)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        backButton.setBackgroundImage(UIImage(named: "back64", in: Bundle(for: Tracker.self), compatibleWith: nil), for: UIControlState())
        backButton.tag = self.windows.count - 1
        backButton.addTarget(self, action: #selector(Debugger.backButtonWasTouched(_:)), for: UIControlEvents.touchUpInside)
        
        // width constraint
        eventDetail.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[backButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["backButton": backButton]))
        
        // height constraint
        eventDetail.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[backButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["backButton": backButton]))
        
        eventDetail.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[backButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["backButton": backButton]))
        
        // align messageLabel from the top and bottom
        eventDetail.menu.addConstraint(NSLayoutConstraint(item: backButton,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: eventDetail.menu,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0))
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        eventDetail.content.addSubview(scrollView)
        
        eventDetail.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .top,
            relatedBy: .equal,
            toItem: eventDetail.content,
            attribute: .top,
            multiplier: 1.0,
            constant: 0))
        
        eventDetail.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: eventDetail.content,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0))
        
        eventDetail.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: eventDetail.content,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0))
        
        eventDetail.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: eventDetail.content,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0))
        
        let URL = Foundation.URL(string: hit)
        
        if let optURL = URL {
            eventDetail.windowTitle = "Hit detail"
            windowTitleLabel.text = eventDetail.windowTitle
            
            var urlComponents: [(key: String, value: String)] = []
            
            let sslComponent: (key: String, value: String) = (key: "ssl", value: optURL.scheme == "http" ? "Off" : "On")
            urlComponents.append(sslComponent)
            
            let logComponent: (key: String, value: String) = (key: "log", value: optURL.host!)
            urlComponents.append(logComponent)
            
            let queryStringComponents = optURL.query!.components(separatedBy: "&")
            
            for (_,component) in (queryStringComponents as [String]).enumerated() {
                let pairComponents = component.components(separatedBy: "=")
                
                urlComponents.append((key: pairComponents[0], value: pairComponents[1].percentDecodedString))
            }
            
            var i: Int = 0
            var previousRow: UIView!
            
            for(key, value) in urlComponents {
                let rowView = UIView()
                rowView.translatesAutoresizingMaskIntoConstraints = false
                
                scrollView.addSubview(rowView)
                
                scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[rowView]-0-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["rowView": rowView]))
                
                if(i == 0) {
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .top,
                        relatedBy: .equal,
                        toItem: scrollView,
                        attribute: .top,
                        multiplier: 1.0,
                        constant: 0))
                    
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .centerX,
                        relatedBy: .equal,
                        toItem: scrollView,
                        attribute: .centerX,
                        multiplier: 1.0,
                        constant: 0))
                } else {
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .top,
                        relatedBy: .equal,
                        toItem: previousRow,
                        attribute: .bottom,
                        multiplier: 1.0,
                        constant: 0))
                }
                
                if(i % 2 == 0) {
                    rowView.backgroundColor = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
                } else {
                    rowView.backgroundColor = UIColor.white
                }
                
                if(i == urlComponents.count - 1) {
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .bottom,
                        relatedBy: .equal,
                        toItem: scrollView,
                        attribute: .bottom,
                        multiplier: 1.0,
                        constant: 0))
                }
                
                let variableLabel = UILabel()
                variableLabel.translatesAutoresizingMaskIntoConstraints = false
                variableLabel.text = key
                variableLabel.textAlignment = NSTextAlignment.right
                variableLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                
                rowView.addSubview(variableLabel)
                
                rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[variableLabel(==100)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["variableLabel": variableLabel]))
                
                rowView.addConstraint(NSLayoutConstraint(item: variableLabel,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: rowView,
                    attribute: .top,
                    multiplier: 1.0,
                    constant: 12))
                
                rowView.addConstraint(NSLayoutConstraint(item: rowView,
                    attribute: .bottom,
                    relatedBy: NSLayoutRelation.greaterThanOrEqual,
                    toItem: variableLabel,
                    attribute: .bottom,
                    multiplier: 1.0,
                    constant: 12))
                
                rowView.addConstraint(NSLayoutConstraint(item: variableLabel,
                    attribute: .left,
                    relatedBy: .equal,
                    toItem: rowView,
                    attribute: .left,
                    multiplier: 1.0,
                    constant: 0))
                
                let columnSeparator = UIView()
                columnSeparator.translatesAutoresizingMaskIntoConstraints = false
                columnSeparator.backgroundColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
                
                rowView.addSubview(columnSeparator)
                
                rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[columnSeparator(==1)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["columnSeparator": columnSeparator]))
                
                rowView.addConstraint(NSLayoutConstraint(item: columnSeparator,
                    attribute: .left,
                    relatedBy: .equal,
                    toItem: variableLabel,
                    attribute: .right,
                    multiplier: 1.0,
                    constant: 10))
                
                rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[columnSeparator]-0-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["columnSeparator": columnSeparator]))
                
                let valueLabel = UILabel()
                valueLabel.translatesAutoresizingMaskIntoConstraints = false
                
                if let optValue: Any = value.parseJSONString {
                    if(key == "stc") {
                        valueLabel.text = Tool.JSONStringify(optValue, prettyPrinted: true)
                    } else {
                        valueLabel.text = value
                    }
                } else {
                    valueLabel.text = value
                }
                
                valueLabel.textAlignment = NSTextAlignment.left
                valueLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                valueLabel.numberOfLines = 0
                
                rowView.addSubview(valueLabel)
                
                rowView.addConstraint(NSLayoutConstraint(item: valueLabel,
                    attribute: .left,
                    relatedBy: .equal,
                    toItem: columnSeparator,
                    attribute: .right,
                    multiplier: 1.0,
                    constant: 10))
                
                rowView.addConstraint(NSLayoutConstraint(item: valueLabel,
                    attribute: .right,
                    relatedBy: .equal,
                    toItem: rowView,
                    attribute: .right,
                    multiplier: 1.0,
                    constant: 10))
                
                rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[valueLabel]-12-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["valueLabel": valueLabel]))
                
                previousRow = rowView
                
                i += 1
            }
        } else {
            eventDetail.windowTitle = "Event detail"
            windowTitleLabel.text = eventDetail.windowTitle
            
            let eventMessageLabel = UILabel()
            eventMessageLabel.translatesAutoresizingMaskIntoConstraints = false
            eventMessageLabel.text = hit
            
            eventMessageLabel.textAlignment = NSTextAlignment.left
            eventMessageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            eventMessageLabel.numberOfLines = 0
            
            scrollView.addSubview(eventMessageLabel)
            
            scrollView.addConstraint(NSLayoutConstraint(item: eventMessageLabel,
                attribute: .leading,
                relatedBy: .equal,
                toItem: scrollView,
                attribute: .leading,
                multiplier: 1.0,
                constant: 10))
            
            scrollView.addConstraint(NSLayoutConstraint(item: eventMessageLabel,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: scrollView,
                attribute: .trailing,
                multiplier: 1.0,
                constant: 10))
            
            scrollView.addConstraint(NSLayoutConstraint(item: eventMessageLabel,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: scrollView,
                attribute: .centerX,
                multiplier: 1.0,
                constant: 0))
            
            scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[eventMessageLabel]-10-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["eventMessageLabel": eventMessageLabel]))
        }
        
        return eventDetail.window
    }
    
    //MARK: Offline hits
    
    /**
     Create offline hits window
     */
    @objc func createOfflineHitsViewer() {
        let offlineHits: (window: UIView, content: UIView, menu: UIView, windowTitle: String) = self.createWindow("Offline Hits")
        offlineHits.window.alpha = 0.0;
        offlineHits.window.isHidden = false
        offlineHits.content.alpha = 1.0
        offlineHits.menu.alpha = 1.0
        
        windowTitleLabel.text = offlineHits.windowTitle
        
        let backButton = UIButton()
        
        offlineHits.menu.addSubview(backButton)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        backButton.setBackgroundImage(UIImage(named: "back64", in: Bundle(for: Tracker.self), compatibleWith: nil), for: UIControlState())
        backButton.tag = self.windows.count - 1
        backButton.addTarget(self, action: #selector(Debugger.backButtonWasTouched(_:)), for: UIControlEvents.touchUpInside)
        
        // width constraint
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[backButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["backButton": backButton]))
        
        // height constraint
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[backButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["backButton": backButton]))
        
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[backButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["backButton": backButton]))
        
        // align messageLabel from the top and bottom
        offlineHits.menu.addConstraint(NSLayoutConstraint(item: backButton,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: offlineHits.menu,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0))
        
        let trashButton = UIButton()
        
        offlineHits.menu.addSubview(trashButton)
        
        trashButton.translatesAutoresizingMaskIntoConstraints = false
        
        trashButton.setBackgroundImage(UIImage(named: "trash64", in: Bundle(for: Tracker.self), compatibleWith: nil), for: UIControlState())
        trashButton.addTarget(self, action: #selector(Debugger.trashOfflineHits), for: UIControlEvents.touchUpInside)
        
        // width constraint
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[trashButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["trashButton": trashButton]))
        
        // height constraint
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[trashButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["trashButton": trashButton]))
        
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[trashButton]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["trashButton": trashButton]))
        
        // align messageLabel from the top and bottom
        offlineHits.menu.addConstraint(NSLayoutConstraint(item: trashButton,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: offlineHits.menu,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0))
        
        let refreshButton = UIButton()
        
        offlineHits.menu.addSubview(refreshButton)
        
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        
        refreshButton.setBackgroundImage(UIImage(named: "refresh64", in: Bundle(for: Tracker.self), compatibleWith: nil), for: UIControlState())
        refreshButton.addTarget(self, action: #selector(Debugger.refreshOfflineHits), for: UIControlEvents.touchUpInside)
        
        // width constraint
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[refreshButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["refreshButton": refreshButton]))
        
        // height constraint
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[refreshButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["refreshButton": refreshButton]))
        
        // align messageLabel from the top and bottom
        offlineHits.menu.addConstraint(NSLayoutConstraint(item: trashButton,
            attribute: .leading,
            relatedBy: .equal,
            toItem: refreshButton,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 10))
        
        // align messageLabel from the top and bottom
        offlineHits.menu.addConstraint(NSLayoutConstraint(item: refreshButton,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: offlineHits.menu,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0))
        
        getOfflineHitsList(offlineHits)
        
        hidePreviousWindowMenuButtons(offlineHits.window)
    }
    
    /**
     Refresh offline hits list
     */
    @objc func refreshOfflineHits() {
        getOfflineHitsList(self.windows[self.windows.count - 1])
    }
    
    /**
     Builds offline hits list rows
     */
    func getOfflineHitsList(_ offlineHits: (window:UIView, content:UIView, menu: UIView, windowTitle: String)) {
        
        let scrollViews = offlineHits.content.subviews.filter({ return $0 is UIScrollView }) as! [UIScrollView]
        let emptyOfflineHitsView = offlineHits.content.subviews.filter() {
            if($0.tag == -2) {
                return true
            } else {
                return false
            }
        }
        
        if(scrollViews.count > 0) {
            scrollViews[0].removeFromSuperview()
        }
        
        if(emptyOfflineHitsView.count > 0) {
            emptyOfflineHitsView[0].removeFromSuperview()
        }
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        offlineHits.content.addSubview(scrollView)
        
        offlineHits.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .top,
            relatedBy: .equal,
            toItem: offlineHits.content,
            attribute: .top,
            multiplier: 1.0,
            constant: 0))
        
        offlineHits.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: offlineHits.content,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0))
        
        offlineHits.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: offlineHits.content,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0))
        
        offlineHits.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: offlineHits.content,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0))
        
        var previousRow: UIView!
        hits = storage.get()
        hits = hits.sorted(by: sortOfflineHits)
        
        if(hits.count == 0) {
            let noOfflineHitsView = UIView()
            noOfflineHitsView.tag = -2
            noOfflineHitsView.translatesAutoresizingMaskIntoConstraints = false
            noOfflineHitsView.layer.cornerRadius = 4.0
            noOfflineHitsView.backgroundColor = UIColor(red: 139/255.0, green: 139/255.0, blue: 139/255.0, alpha: 1)
            
            offlineHits.content.addSubview(noOfflineHitsView)
            
            // height constraint
            offlineHits.content.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[noOfflineHitsView(==50)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["noOfflineHitsView": noOfflineHitsView]))
            
            offlineHits.content.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-30-[noOfflineHitsView]-30-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["noOfflineHitsView": noOfflineHitsView]))
            
            // align messageLabel from the top and bottom
            offlineHits.content.addConstraint(NSLayoutConstraint(item: noOfflineHitsView,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: offlineHits.content,
                attribute: .centerY,
                multiplier: 1.0,
                constant: 0))
            
            let emptyContentLabel = UILabel()
            emptyContentLabel.translatesAutoresizingMaskIntoConstraints = false
            emptyContentLabel.text = "No stored hit"
            emptyContentLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            emptyContentLabel.sizeToFit()
            
            noOfflineHitsView.addSubview(emptyContentLabel)
            
            noOfflineHitsView.addConstraint(NSLayoutConstraint(item: emptyContentLabel,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: noOfflineHitsView,
                attribute: .centerY,
                multiplier: 1.0,
                constant: 0))
            
            noOfflineHitsView.addConstraint(NSLayoutConstraint(item: emptyContentLabel,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: noOfflineHitsView,
                attribute: .centerX,
                multiplier: 1.0,
                constant: 0))
        } else {
            for(i, hit) in hits.enumerated() {
                let rowView = UIView()
                rowView.translatesAutoresizingMaskIntoConstraints = false
                rowView.isUserInteractionEnabled = true
                rowView.tag = i
                rowView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Debugger.offlineHitRowSelected(_:))))
                
                scrollView.addSubview(rowView)
                
                scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[rowView]-0-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["rowView": rowView]))
                
                if(i == 0) {
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .top,
                        relatedBy: .equal,
                        toItem: scrollView,
                        attribute: .top,
                        multiplier: 1.0,
                        constant: 0))
                    
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .centerX,
                        relatedBy: .equal,
                        toItem: scrollView,
                        attribute: .centerX,
                        multiplier: 1.0,
                        constant: 0))
                } else {
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .top,
                        relatedBy: .equal,
                        toItem: previousRow,
                        attribute: .bottom,
                        multiplier: 1.0,
                        constant: 0))
                }
                
                if(i % 2 == 0) {
                    rowView.backgroundColor = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
                } else {
                    rowView.backgroundColor = UIColor.white
                }
                
                if(i == hits.count - 1) {
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .bottom,
                        relatedBy: .equal,
                        toItem: scrollView,
                        attribute: .bottom,
                        multiplier: 1.0,
                        constant: 0))
                }
                
                let dateLabel = UILabel()
                let messageLabel = UILabel()
                let hitTypeView = UIImageView()
                let deleteButton = UIButton()
                
                dateLabel.translatesAutoresizingMaskIntoConstraints = false
                messageLabel.translatesAutoresizingMaskIntoConstraints = false
                hitTypeView.translatesAutoresizingMaskIntoConstraints = false
                deleteButton.translatesAutoresizingMaskIntoConstraints = false
                
                rowView.addSubview(dateLabel)
                rowView.addSubview(messageLabel)
                rowView.addSubview(hitTypeView)
                rowView.addSubview(deleteButton)
                
                /******* DATE ********/
                dateLabel.text = dateHourFormatter.string(from: hit.creationDate as Date)
                dateLabel.sizeToFit();
                
                // align iconView from the top and bottom
                rowView.addConstraint(NSLayoutConstraint(item: dateLabel,
                    attribute: .left,
                    relatedBy: .equal,
                    toItem: rowView,
                    attribute: .left,
                    multiplier: 1.0,
                    constant: 5))
                
                rowView.addConstraint(NSLayoutConstraint(item: dateLabel,
                    attribute: .centerY,
                    relatedBy: .equal,
                    toItem: rowView,
                    attribute: .centerY,
                    multiplier: 1.0,
                    constant: 0))
                /******* END DATE ********/
                
                /******* HIT ********/
                messageLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                messageLabel.baselineAdjustment = UIBaselineAdjustment.none
                messageLabel.text = hit.url
                
                rowView.addConstraint(NSLayoutConstraint(item: messageLabel,
                    attribute: .left,
                    relatedBy: .equal,
                    toItem: dateLabel,
                    attribute: .right,
                    multiplier: 1.0,
                    constant: 10))
                
                rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[messageLabel]-12-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["messageLabel": messageLabel]))
                
                /******* END HIT ********/
                
                /******* HIT TYPE ********/
                switch(hit.getHitType()) {
                case Hit.HitType.touch:
                    hitTypeView.image = UIImage(named: "touch48", in: Bundle(for: Tracker.self), compatibleWith: nil)
                case Hit.HitType.adTracking:
                    hitTypeView.image = UIImage(named: "tv48", in: Bundle(for: Tracker.self), compatibleWith: nil)
                case Hit.HitType.audio:
                    hitTypeView.image = UIImage(named: "audio48", in: Bundle(for: Tracker.self), compatibleWith: nil)
                case Hit.HitType.video:
                    hitTypeView.image = UIImage(named: "video48", in: Bundle(for: Tracker.self), compatibleWith: nil)
                case Hit.HitType.productDisplay:
                    hitTypeView.image = UIImage(named: "product48", in: Bundle(for: Tracker.self), compatibleWith: nil)
                default:
                    hitTypeView.image = UIImage(named: "smartphone48", in: Bundle(for: Tracker.self), compatibleWith: nil)
                }
                
                rowView.addConstraint(NSLayoutConstraint(item: hitTypeView,
                    attribute: .left,
                    relatedBy: NSLayoutRelation.greaterThanOrEqual,
                    toItem: messageLabel,
                    attribute: .right,
                    multiplier: 1.0,
                    constant: 10))
                
                // align iconView from the top and bottom
                rowView.addConstraint(NSLayoutConstraint(item: hitTypeView,
                    attribute: .centerY,
                    relatedBy: .equal,
                    toItem: rowView,
                    attribute: .centerY,
                    multiplier: 1.0,
                    constant: -1))
                
                // width constraint
                rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[hitTypeView(==24)]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["hitTypeView": hitTypeView]))
                
                // height constraint
                rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[hitTypeView(==24)]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["hitTypeView": hitTypeView]))
                
                /******* DELETE BUTTON ********/
                
                deleteButton.setBackgroundImage(UIImage(named: "trash48", in: Bundle(for: Tracker.self), compatibleWith: nil), for: UIControlState())
                deleteButton.tag = i
                deleteButton.addTarget(self, action: #selector(Debugger.deleteOfflineHit(_:)), for: UIControlEvents.touchUpInside)
                
                rowView.addConstraint(NSLayoutConstraint(item: deleteButton,
                    attribute: .leading,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: hitTypeView,
                    attribute: .trailing,
                    multiplier: 1.0,
                    constant: 10))
                
                // align iconView from the top and bottom
                rowView.addConstraint(NSLayoutConstraint(item: deleteButton,
                    attribute: .centerY,
                    relatedBy: .equal,
                    toItem: rowView,
                    attribute: .centerY,
                    multiplier: 1.0,
                    constant: -1))
                
                // width constraint
                rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[deleteButton(==24)]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["deleteButton": deleteButton]))
                
                // height constraint
                rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[deleteButton(==24)]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["deleteButton": deleteButton]))
                
                rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[deleteButton]-5-|", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["deleteButton": deleteButton]))
                
                previousRow = rowView
            }
        }
    }
    
    /**
     Offline hit list row selected
     */
    @objc func offlineHitRowSelected(_ recogniser: UIPanGestureRecognizer) {
        self.windows[1].content.isHidden = true
        
        if let row = recogniser.view {
            let window = createEventDetailView(hits[row.tag].url)
            
            hidePreviousWindowMenuButtons(window)
        }
    }
    
    /**
     Delete offline hit
     */
    @objc func deleteOfflineHit(_ sender: UIButton) {
        //let storage = Storage(concurrencyType: .MainQueueConcurrencyType)
        _ = storage.delete(hits[sender.tag].url)
        getOfflineHitsList(self.windows[self.windows.count - 1])
    }
    
    /**
     Delete all offline hits
     */
    @objc func trashOfflineHits() {
        _ = storage.delete()
        
        getOfflineHitsList(self.windows[self.windows.count - 1])
    }
    
    //MARK: Window management
    
    /**
     Create a new window
     */
    func createWindow(_ windowTitle: String) -> (window:UIView, content:UIView, menu: UIView, windowTitle: String) {
        let window = UIView()
        if(windows.count == 0) {
            window.backgroundColor = UIColor.white
            window.layer.shadowOffset = CGSize(width: 1, height: 1)
            window.layer.shadowRadius = 4.0
            window.layer.shadowColor = UIColor.black.cgColor
            window.layer.shadowOpacity = 0.2
        } else {
            window.backgroundColor = UIColor.clear
        }
        
        window.frame = CGRect(x: self.viewController!.view.frame.width - 47, y: self.viewController!.view.frame.height - (self.viewController!.bottomLayoutGuide.length + 93), width: 0, height: 0)
        window.layer.borderColor = UIColor(red:211/255.0, green:215/255.0, blue:220/255.0, alpha:1.0).cgColor
        window.layer.borderWidth = 1.0
        window.layer.cornerRadius = 4.0
        
        window.translatesAutoresizingMaskIntoConstraints = false
        window.isHidden = true
        
        let windowId = "window" + String(self.windows.count)
        
        self.viewController!.view.addSubview(window)
        
        if(windows.count == 0) {
            self.viewController!.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[" + windowId + "]-10-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:[windowId: window]))
            
            self.viewController!.view.addConstraint(NSLayoutConstraint(item: window,
                attribute: NSLayoutAttribute.top,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.viewController!.topLayoutGuide,
                attribute: NSLayoutAttribute.bottom,
                multiplier: 1.0,
                constant: 10))
            
            let popupVsButtonConstraint = NSLayoutConstraint(item: self.debugButton,
                                                             attribute: .top,
                                                             relatedBy: .equal,
                                                             toItem: window,
                                                             attribute: .bottom,
                                                             multiplier: 1.0,
                                                             constant: 10.0)
            
            self.viewController!.view.addConstraint(popupVsButtonConstraint)
        } else {
            self.viewController!.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[" + windowId + "]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:[windowId: window]))
            
            self.viewController!.view.addConstraint(NSLayoutConstraint(item: window,
                attribute: NSLayoutAttribute.top,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.viewController!.topLayoutGuide,
                attribute: NSLayoutAttribute.bottom,
                multiplier: 1.0,
                constant: 10))
            
            self.viewController!.view.addConstraint(NSLayoutConstraint(item: window,
                attribute: NSLayoutAttribute.width,
                relatedBy: .equal,
                toItem: windows[0].window,
                attribute: NSLayoutAttribute.width,
                multiplier: 1.0,
                constant: 0.0))
            
            self.viewController!.view.addConstraint(NSLayoutConstraint(item: window,
                attribute: NSLayoutAttribute.height,
                relatedBy: .equal,
                toItem: windows[0].window,
                attribute: NSLayoutAttribute.height,
                multiplier: 1.0,
                constant: 0.0))
        }
        
        let menu = DebuggerTopBar()
        menu.alpha = 0.0;
        if(windows.count == 0) {
            menu.backgroundColor = UIColor(red: 7/255.0, green: 39/255, blue: 80/255, alpha: 1.0)
        } else {
            menu.backgroundColor = UIColor.clear
        }
        
        window.addSubview(menu)
        
        menu.translatesAutoresizingMaskIntoConstraints = false
        let menuId = "menu" + String(self.windows.count)
        
        // align topBar from the left and right
        window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[" + menuId + "]-0-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:[menuId : menu]))
        
        // align topBar from the top
        window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[" + menuId + "]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:[menuId: menu]))
        
        // height constraint
        window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[" + menuId + "(==60)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:[menuId: menu]))
        
        let contentId = "content" + String(self.windows.count)
        
        let content = UIView()
        content.frame = window.frame;
        content.backgroundColor = UIColor.white
        content.alpha = 0.0;
        content.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(content)
        
        // align eventLogContent from the left and right
        window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[" + contentId + "]-0-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:[contentId: content]))
        
        // align eventLogContent from the top and bottom@
        window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[" + contentId + "]-3-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:[contentId: content]))
        
        window.addConstraint(NSLayoutConstraint(item: content,
            attribute: NSLayoutAttribute.top,
            relatedBy: .equal,
            toItem: menu,
            attribute: NSLayoutAttribute.bottom,
            multiplier: 1.0,
            constant: 0.0))
        
        let tuple: (window: UIView, content: UIView, menu: UIView, windowTitle: String) = (window: window, content: content, menu: menu, windowTitle: windowTitle)
        
        windows.append(tuple)
        
        return tuple
    }
    
    /**
     Back button pressed
     */
    @objc func backButtonWasTouched(_ sender:UIButton) {
        for(_, view) in self.windows[sender.tag - 1].menu.subviews.enumerated() {
            if let button = view as? UIButton {
                button.isHidden = false
            }
        }
        
        windowTitleLabel.text = self.windows[sender.tag - 1].windowTitle
        self.windows[sender.tag - 1].content.isHidden = false
        
        windows[sender.tag].window.removeFromSuperview()
        self.windows.remove(at: sender.tag)
    }
    
    /**
     Hide menu buttons from previous window
     
     - parameter window: where buttons need to be hidden
     */
    private func hidePreviousWindowMenuButtons(_ window: UIView) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: UIViewAnimationOptions.curveLinear,
            animations: {
                for(_, view) in self.windows[self.windows.count - 2].menu.subviews.enumerated() {
                    if let button = view as? UIButton {
                        button.isHidden = true
                    }
                }
                
                window.alpha = 1.0;
            },
            completion: nil
        )
    }
    
    /**
     Sort hit by date from most recent to oldest
     
     - parameter first: hit to compare
     - parameter second: hit
     
     */
    func sortOfflineHits(_ hit1: Hit, hit2: Hit) -> Bool {
        return hit1.creationDate.timeIntervalSince1970 > hit2.creationDate.timeIntervalSince1970
    }
}

/**
 Event class
 */
public class DebuggerEvent {
    /// Date of event
    var date: Date
    /// Event message
    var message: String
    /// Type of event
    var type: String
    
    init() {
        date = Date()
        message = ""
        type = "sent48"
    }
}

/**
 Rounded corner for debugger menu
 */
class DebuggerTopBar: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], cornerRadii: CGSize(width: 4, height: 4))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
}
