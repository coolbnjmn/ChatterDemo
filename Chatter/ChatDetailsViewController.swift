//
//  ChatDetailsViewController.swift
//  Chatter
//
//  Created on 2/24/15.
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

import UIKit
import Parse


class ChatDetailsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var session : PFObject!
    var bidTextField : UITextField!
    var addBidButton : UIButton!
    var sessionBids : NSMutableArray!
    var timer : NSTimer!
    var bidWindow : CGFloat = 15*60 // 15 minutes @ 60 sec a min
    
    @IBOutlet weak var bidTableView: UITableView!
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let topBarHeight : CGFloat = self.navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height
        self.bidTableView.frame.origin = CGPointMake(0.0, topBarHeight)
        let buttonHeight : CGFloat = 40
        let bufferSize : CGFloat = 20
        let buttonTextFieldOffset : CGFloat = 10

        println(session)
        let bids : NSMutableArray? = session.objectForKey("bids") as? NSMutableArray
        if(bids != nil) {
            self.sessionBids = session.objectForKey("bids") as! NSMutableArray
            self.bidTableView.reloadData()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        var startTime = NSDate.timeIntervalSinceReferenceDate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTime:"), userInfo: startTime, repeats: true)
        self.view.backgroundColor = UIColor.init(red: 120/255.0, green: 120/255.0, blue: 120/255.0, alpha: 1)
        
        

    }

    func keyboardWillHide(notification: NSNotification) {
        let userInfoDict : NSDictionary = notification.userInfo!
        let rate : NSNumber = userInfoDict.objectForKey(UIKeyboardAnimationDurationUserInfoKey) as! NSNumber
        let theRate : NSTimeInterval = rate as! NSTimeInterval
        UIView.animateWithDuration(theRate, animations:{
            self.bidTableView.contentInset = UIEdgeInsetsZero
            self.bidTableView.scrollIndicatorInsets = UIEdgeInsetsZero

        })
    }
    
    func keyboardWillShow(notification: NSNotification) {
        println(notification.userInfo)
        let userInfoDict : NSDictionary = notification.userInfo!
        let keyboardSize = (userInfoDict[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        let rate : NSNumber = userInfoDict.objectForKey(UIKeyboardAnimationDurationUserInfoKey) as! NSNumber
        
        var contentInsets = UIEdgeInsets()
        if(UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation)) {
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize!.height)+64, 0.0)
        } else {
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize!.width), 0.0)
        }
        
        let block : () -> Void = {
            self.bidTableView.contentInset = contentInsets
            self.bidTableView.scrollIndicatorInsets = contentInsets
        }
        
        let theRate : NSTimeInterval = rate as! NSTimeInterval
        UIView.animateWithDuration(theRate, animations: block)
    }
            

    func updateTime(sender: NSTimer) {
        bidWindow--
        var tempBidWindow : CGFloat = bidWindow
        let minutes = UInt8(bidWindow / 60.0)
        tempBidWindow -= CGFloat(minutes) * 60
        let seconds = UInt8(tempBidWindow)
        let strMinutes = minutes > 9 ? String(minutes):"0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds):"0" + String(seconds)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\(strMinutes):\(strSeconds)", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        
        if(bidWindow <= 0) {
            timer.invalidate()
            // TODO : enter session for highest bidder
        }
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "enterStream" {
            var session = sender as! PFObject
            var svc = segue.destinationViewController as! StreamViewController
            
            svc.session = session
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 2*40))
        footerView.backgroundColor = UIColor.blackColor()
        bidTextField = UITextField()
        bidTextField.frame = CGRectMake(0, 0, self.view.bounds.size.width, 40)
        bidTextField.borderStyle = .RoundedRect
        bidTextField.keyboardType = .NumberPad
        bidTextField.returnKeyType = UIReturnKeyType.Done
        footerView.addSubview(bidTextField)
        
        addBidButton = UIButton(frame: CGRectMake(0, 40, tableView.frame.size.width, 40))
        addBidButton.backgroundColor = UIColor.init(red: 0, green: 104/255.0, blue: 174/255.0, alpha: 1.0)
        addBidButton.setTitle("ADD BID", forState:.allZeros)
        addBidButton.layer.cornerRadius = 5
        addBidButton.titleLabel!.font = UIFont(name:"MyriadPro-Regular", size: 18)
        addBidButton.setTitleColor(UIColor.whiteColor(), forState:.allZeros)
        addBidButton.addTarget(self, action: "addBid:", forControlEvents: .TouchUpInside)
        
        footerView.addSubview(addBidButton)
        return footerView
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80.0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(sessionBids == nil) {
            return 0
        }
        return sessionBids.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("bidCell", forIndexPath: indexPath) as! UITableViewCell
        if(sessionBids != nil && sessionBids.count != 0) {
            let bid : NSDictionary = sessionBids.objectAtIndex(sessionBids.count - indexPath.row - 1) as! NSDictionary
            cell.detailTextLabel?.text = bid.objectForKey("name") as? String
            cell.textLabel?.text = bid.objectForKey("bid") as? String
            var facebookId = bid.objectForKey("fbId") as! String
            var imageURLString = "http://graph.facebook.com/" + facebookId + "/picture?type=small"
            var imageURL = NSURL(string: imageURLString)
            cell.imageView?.frame.size = CGSize(width: 30, height: 30)
            cell.imageView?.sd_setImageWithURL(imageURL)


        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.bidTableView.deselectRowAtIndexPath(indexPath, animated:false)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if(bidTextField != nil) {
            bidTextField.resignFirstResponder()
        }
        
    }
    
    func addBid(sender: AnyObject) {
        println("add bid")
        sessionBids = session.objectForKey("bids") as? NSMutableArray
        if(sessionBids == nil) {
            sessionBids = NSMutableArray()
        }
        
        var lastSessionBid : NSDictionary
        if(sessionBids.count != 0) {
            lastSessionBid = sessionBids.objectAtIndex(sessionBids.count - 1) as! NSDictionary
            var previousHighBid : Int! = (lastSessionBid.objectForKey("bid") as! String).toInt()
            if( previousHighBid >= bidTextField.text.toInt()) {
                println("bid is lower than current bid")
                SVProgressHUD.showErrorWithStatus("Bid is lower than current bid!")
                return
            }
        }
        
        if(bidTextField.text.rangeOfString("^[0-9]*$", options: .RegularExpressionSearch) != nil) {
            sessionBids!.addObject(NSDictionary(objects: [PFUser.currentUser().objectId, PFUser.currentUser().objectForKey("username"), bidTextField.text, PFUser.currentUser().objectForKey("facebookId")], forKeys: ["user", "name", "bid", "fbId"]))
            session.setObject(sessionBids, forKey: "bids")
            session.save()
            self.bidTableView.reloadData()
        } else {
            SVProgressHUD.showErrorWithStatus("Bid must be a number!")
        }
        
    }
    
    
}
