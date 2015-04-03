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
    let apiKey = "45198012"
    var session : PFObject!
    
    var tokSession : OTSession? = nil
    var tokPublisher : OTPublisher? = nil
    var tokSubscriber : OTSubscriber? = nil
    
    var userView : UIView?
    

    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sessionId = self.session["sessionID"] as String
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
        
        
        let occupants = session["chatters"] as NSArray?
        
        var array = NSMutableArray()
        
        if occupants != nil {
            array.addObjectsFromArray(occupants!)
        }
        /*
        switch array.count {
        case 0:
            println("Joining Empty Channel")
            fallthrough
        case 1:*/
            println("Joining Channel")
            let deviceID = UIDevice.currentDevice().identifierForVendor.UUIDString
            array.addObject(deviceID)
            session.setObject(array, forKey: "chatters")
            
            session.saveInBackgroundWithBlock({ (success : Bool, error : NSError!) -> Void in
                if error != nil {
                    println(error.localizedDescription)
                }
                
            })
       /* default:
            println("Channel is Full")
            performSegueWithIdentifier("exitStream", sender: self)
            return;
        }
        */
        
        if tokSession == nil {
            println("No session exists to connect with")
            return
        }
        
        var error : OTError?
        
        let publisherToken = session["publisherToken"] as String
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
        
        let viewSize = CGSizeMake(view.frame.size.height*0.5, view.frame.size.height*0.5)
        userView = tokPublisher!.view
        
        if userView != nil {
            userView!.layer.cornerRadius = viewSize.height * 0.5
            userView!.clipsToBounds = true
            view.insertSubview(userView!, atIndex: 0)
            userView!.frame = CGRectMake(0, 0, viewSize.width, viewSize.height)
            userView!.center = CGPointMake(view.frame.size.width*0.5,
                                           view.frame.size.height*0.5)
        }
        
        
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

        var userFacebookId = PFUser.currentUser().objectForKey("facebookId") as String
        var sessionFacebookId = session["facebookId"] as String
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
    
    
    //OTSubscriber delegate callbacks
    
    
    func subscriberDidConnectToStream(subscriber : OTSubscriberKit){
        println("subscriber did connect to stream")
        if tokSubscriber != nil {
            let viewSize = CGSizeMake(view.frame.size.width, view.frame.size.height*0.5)
            tokSubscriber!.view.layer.cornerRadius = 7.5
            tokSubscriber!.view.clipsToBounds = true
            tokSubscriber!.view.frame = CGRectMake(0, 0, viewSize.width, viewSize.height)
            view.insertSubview(tokSubscriber!.view, atIndex: 0)
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

/*
- (void)cleanupSubscriber
{
[_subscriber.view removeFromSuperview];
_subscriber = nil;
}
*/