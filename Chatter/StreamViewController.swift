//
//  StreamViewController.swift
//  Chatter
//
//  Created on 1/23/15.
//  
//
/*
The MIT License (MIT)

Copyright (c) 2015 Eddy Borja

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

import Foundation
import UIKit
import ParseUI
import Parse
import OpenTok


class StreamViewController : UIViewController, OTSessionDelegate, OTPublisherKitDelegate, OTSubscriberKitDelegate {
    
    @IBOutlet weak var waitingLabel: UILabel!
    let subscribeToSelf = false
    let apiKey = "45191152"
    var session : PFObject!
    
    var tokSession : OTSession? = nil
    var tokPublisher : OTPublisher? = nil
    var tokSubscriber : OTSubscriber? = nil
    
    var userView : UIView?
    var timer : NSTimer!
    var bidTimer : NSTimer!
    var timeLabel : UILabel!
    @IBOutlet weak var reportButton: UIButton!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sessionId = self.session["sessionID"] as! String
        tokSession = OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "doDisconnect", name: "ApplicationWillExit", object: nil)
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        doConnect()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    func doConnect() {
        
        
        let occupants = session["chatters"] as! NSArray?
        
        var array = NSMutableArray()
        
        if occupants != nil {
            array.addObjectsFromArray(occupants! as! [AnyObject])
        }
            println("Joining Channel")
            let deviceID = UIDevice.currentDevice().identifierForVendor.UUIDString
            array.addObject(deviceID)
            session.setObject(array, forKey: "chatters")
            
            session.saveInBackgroundWithBlock({ (success : Bool, error : NSError!) -> Void in
                if error != nil {
                    println(error.localizedDescription)
                }
                
            })
       
        
        if tokSession == nil {
            println("No session exists to connect with")
            return
        }
        
        var error : OTError?
        
        let publisherToken = session["publisherToken"] as! String
        println(publisherToken)
        tokSession!.connectWithToken(publisherToken, error: &error)
        if error != nil {
            showAlert(error!.localizedDescription)
        }
        
    
    }
    
    func doDisconnect(){
        if tokSession == nil {
            println("No session exists to disconnect")
            return
        }
        
        var error : OTError?
        
        tokSession!.disconnect(&error)
        if error != nil {
            showAlert(error!.localizedDescription)
        }
        
        
        
    }
    
    
    func doPublish() {
        
 
        
        tokPublisher = OTPublisher(delegate: self)
        
        var error : OTError?
        
        if tokSession == nil {
            println("No tokSession to publish with")
        }
        
        tokSession?.publish(tokPublisher, error: &error)
        
        if error != nil {
            showAlert(error!.localizedDescription)
        }
        println("Here")
        println(view.frame)
        
        let viewSize = CGSizeMake(view.frame.size.width*0.25, view.frame.size.height*0.25)
        userView = tokPublisher!.view
        
        if userView != nil {
            userView!.layer.cornerRadius = 7.5
            userView!.clipsToBounds = true
            view.insertSubview(userView!, atIndex: 0)
            userView!.frame = CGRectMake(view.frame.size.width - viewSize.width - 10, view.frame.size.height - viewSize.height - 10, viewSize.width, viewSize.height);
        }
        
        var endDate : NSDate = NSDate(timeInterval: NSTimeInterval(15), sinceDate: NSDate())
        session.setObject(endDate, forKey: "endBidsDate")
        session.saveInBackgroundWithBlock({ (success : Bool, error : NSError!) -> Void in
            if error != nil {
                println(error.localizedDescription)
            }
            
        })
        bidTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateBidTimer:"), userInfo: endDate, repeats: true)

        var timeLabelViewSize = CGSizeMake(view.frame.size.width*0.25, view.frame.size.height*0.25)
        self.timeLabel = UILabel()
        self.timeLabel.frame = CGRectMake(view.frame.size.width - timeLabelViewSize.width,view.frame.size.height - timeLabelViewSize.height,timeLabelViewSize.width, CGFloat(40))
        
        self.timeLabel.text = "00:00"
        self.timeLabel.textColor = UIColor.whiteColor()
        self.timeLabel.sizeToFit()
        self.timeLabel.textAlignment = .Center
        view.insertSubview(self.timeLabel, atIndex: 10)
    }
    
    func cleanupPublisher() {
        if tokPublisher != nil {
            tokPublisher!.view.removeFromSuperview()
            tokPublisher = nil
            notifyPublishingHasStopped()
        }
    }
    
    func doSubscribe(stream : OTStream) {
        tokSubscriber = OTSubscriber(stream: stream, delegate: self)
        
        var error : OTError?
        
        tokSession?.subscribe(tokSubscriber!, error: &error)
        if error != nil {
            showAlert(error!.localizedDescription)
        }
    }
    
    func cleanupSubscriber() {
        if tokSubscriber != nil {
            tokSubscriber!.view.removeFromSuperview()
            tokSubscriber = nil
        }
    }
    
    func sessionDidConnect(session : OTSession){
        println("Session did connect " + session.sessionId);
        doPublish()
        
        
    }
    
    func sessionDidDisconnect(openTokSession: OTSession!) {
        println("Session did disconnect")

        var userFacebookId = PFUser.currentUser().objectForKey("facebookId") as! String
        var sessionFacebookId = session["facebookId"] as! String
        if userFacebookId == sessionFacebookId {
            session.deleteInBackgroundWithBlock(nil)
        }
        
        performSegueWithIdentifier("exitStream", sender: self)
    }
    
    func session(session: OTSession!, streamCreated stream: OTStream!) {
        println("session streamCreated")
        
        if tokSubscriber == nil && subscribeToSelf == false {
            doSubscribe(stream)
        }
    }
    
    func session(session: OTSession!, streamDestroyed stream: OTStream!) {
        println("session streamDestroyed")
        
        if tokSubscriber != nil {
            if tokSubscriber!.stream.streamId == stream.streamId {
                cleanupSubscriber()
            }
        }
    }
    
    func session(session: OTSession!, connectionCreated connection: OTConnection!) {
        println("Session connectionCreated")
    }
    
    func session(session: OTSession!, connectionDestroyed connection: OTConnection!) {
        println("session connectionDestroyed")
        
        if tokSubscriber != nil {
            if tokSubscriber!.stream.connection.connectionId == connection.connectionId {
                cleanupSubscriber()
            }
        }
    }

    func session(session: OTSession!, didFailWithError error: OTError!) {
        println("Failed with error " + error.localizedDescription)
    }
    
    
    //helper for OTSubscriber delegate callback
    func checkTime(sender: NSTimer) {
        println(sender.userInfo);
    }
    
    
    @IBAction func showTools(sender: AnyObject) {
        let alertController = UIAlertController(title: "Tools For Chat", message:
            "Having issues?", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        alertController.addAction(UIAlertAction(title: "Report User", style: UIAlertActionStyle.Default, handler: { (action)  in
            self.reportUser(self);
        }))
    }
    func reportUser(sender: AnyObject) {
        println("butotn pressed");
    }
    /**
    Update Bid timer is a method that updates the actual view for the countdown timer for the bidding window on the publisher's side. It is mainly string conversion stuff
    
    :params: sender NSTimer that we want to reference
    
    :returns: no return value but sets self.timeLabel to the updated time
    */
    func updateBidTimer(sender: NSTimer) {
        var currentDate = NSDate()
        
        //Find the difference between current time and start time.
        var remainingTime: NSTimeInterval = (sender.userInfo as! NSDate).timeIntervalSinceDate(currentDate)
        
        if(remainingTime < 0) {
            return;
        }
        //calculate the minutes in elapsed time.
        let minutes = UInt8(remainingTime / 60.0)
        remainingTime -= (NSTimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        let seconds = UInt8(remainingTime)
        remainingTime -= NSTimeInterval(seconds)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        let strMinutes = minutes > 9 ? String(minutes):"0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds):"0" + String(seconds)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        self.timeLabel.text = "\(strMinutes):\(strSeconds)"
        
    }
    
    /**
    Update timer is a method that updates the actual view for the countdown timer for the chat window on the publisher's side. It is mainly string conversion stuff
    
    :params: sender NSTimer that we want to reference
    
    :returns: no return value but sets self.timeLabel to the updated time
    */
    func updateTime(sender: NSTimer) {
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        //Find the difference between current time and start time.
        var elapsedTime: NSTimeInterval = currentTime - (sender.userInfo as! NSTimeInterval)
        
        //calculate the minutes in elapsed time.
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        let seconds = UInt8(elapsedTime)
        elapsedTime -= NSTimeInterval(seconds)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        let strMinutes = minutes > 9 ? String(minutes):"0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds):"0" + String(seconds)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        self.timeLabel.text = "\(strMinutes):\(strSeconds)"

    }
    
    //OTSubscriber delegate callbacks
    
    
    func subscriberDidConnectToStream(subscriber : OTSubscriberKit){
        println("subscriber did connect to stream")
        if tokSubscriber != nil {
            var startTime = NSDate.timeIntervalSinceReferenceDate()
            bidTimer.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTime:"), userInfo: startTime, repeats: true)
            println(subscriber);
            let viewSize = CGSizeMake(view.frame.size.width, view.frame.size.height)
            tokSubscriber!.view.layer.cornerRadius = 7.5
            tokSubscriber!.view.clipsToBounds = true
            tokSubscriber!.view.frame = CGRectMake(0, 0, viewSize.width, viewSize.height)
            
            var timeLabelViewSize = CGSizeMake(view.frame.size.width*0.25, view.frame.size.height*0.25)
            self.timeLabel = UILabel()
            self.timeLabel.frame = CGRectMake(view.frame.size.width - timeLabelViewSize.width,view.frame.size.height - timeLabelViewSize.height,timeLabelViewSize.width, CGFloat(40))
            
            self.timeLabel.text = "00:00"
            self.timeLabel.textColor = UIColor.whiteColor()
            self.timeLabel.sizeToFit()
            self.timeLabel.textAlignment = .Center
            view.insertSubview(tokSubscriber!.view, atIndex: 0)
            self.timeLabel.removeFromSuperview();
            view.insertSubview(self.timeLabel, atIndex: 10)
            waitingLabel.hidden = true
            
        }
    }
    
    func subscriber(subscriber: OTSubscriberKit!, didFailWithError error: OTError!) {
        println("failed with error " + error.localizedDescription) 
    }
    
    
    //Publisher delegate callbacks
    
    func publisher(publisher: OTPublisherKit!, streamCreated stream: OTStream!) {
        if tokSubscriber != nil && subscribeToSelf {
            doSubscribe(stream)
        }
    }
 
    func publisher(publisher: OTPublisherKit!, streamDestroyed stream: OTStream!) {
        if tokSubscriber != nil {
            if tokSubscriber!.stream.streamId == stream.streamId {
                cleanupSubscriber()
            }
            
            cleanupPublisher()
        }
    }
    
    func publisher(publisher: OTPublisherKit!, didFailWithError error: OTError!) {
        println("Published failed with error " + error.localizedDescription)
        cleanupPublisher()
    }
    
    
    func notifyPublishingHasStopped() {
        println("Publishing has stopped.")
    }
    
    func showAlert(message : String) {
        println(message)
    }
    
    @IBAction func showActions(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let reportAction = UIAlertAction(title: "Report Inappropriate", style: .Destructive) { (action : UIAlertAction!) -> Void in
            self.exitStream(action)
        }
        
        alertController.addAction(reportAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func exitStream(sender: AnyObject) {
        
        doDisconnect()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "exitStream" {
            
        }
    }
    
}