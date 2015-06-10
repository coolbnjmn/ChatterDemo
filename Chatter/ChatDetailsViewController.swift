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
    
    var keyboardShowing : Bool = false
    var session : PFObject!
    var bidTextField : UITextField!
    var addBidButton : UIButton!
    var sessionBids : NSMutableArray!
    var timer : NSTimer!
    var bidWindow : CGFloat = 10 // 15 minutes @ 60 sec a min
    
    @IBOutlet weak var bidTableView: UITableView!
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let topBarHeight : CGFloat = self.navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height
        self.bidTableView.frame = CGRectMake(0.0, topBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - topBarHeight)
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
    
    // MARK: - Key board inset methods, to make sure text views are in the right place

    func keyboardWillHide(notification: NSNotification) {
        keyboardShowing = false
        let userInfoDict : NSDictionary = notification.userInfo!
        let rate : NSNumber = userInfoDict.objectForKey(UIKeyboardAnimationDurationUserInfoKey) as! NSNumber
        let theRate : NSTimeInterval = rate as! NSTimeInterval
        UIView.animateWithDuration(theRate, animations:{
            self.bidTableView.contentInset = UIEdgeInsetsZero
            self.bidTableView.scrollIndicatorInsets = UIEdgeInsetsZero

        })
    }
    
    func keyboardWillShow(notification: NSNotification) {
        keyboardShowing = true
        println(notification.userInfo)
        let userInfoDict : NSDictionary = notification.userInfo!
        let keyboardSize = (userInfoDict[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        let rate : NSNumber = userInfoDict.objectForKey(UIKeyboardAnimationDurationUserInfoKey) as! NSNumber
        
        var contentInsets = UIEdgeInsets()
        if(UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation)) {
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize!.height), 0.0)
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
            

    /**
    Update time, which updates the bid window based from the publisher's timer. 
    
    :params: sender NSTimer that is to be sent in
    
    :returns: nothing, but changes the string, and enters the session for the highest bidder, and pops the view controller for the others
    */
    func updateTime(sender: NSTimer) {
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        var remainingTime : NSTimeInterval?
        //Find the difference between current time and start time.
        session.fetchIfNeeded();
        if let bidWindowClose : NSDate = session.objectForKey("endBidsDate") as? NSDate {
            remainingTime = bidWindowClose.timeIntervalSinceDate(NSDate())
        }
        
        if remainingTime == nil {
            return;
        }
        
        if (remainingTime < 0) {
            
            timer.invalidate()
            let finalBids : NSMutableArray = session.objectForKey("bids") as! NSMutableArray
            var lastSessionBid : NSDictionary
            var highestBidderID : String
            lastSessionBid = finalBids.objectAtIndex(finalBids.count - 1) as! NSDictionary
            highestBidderID = (lastSessionBid.objectForKey("user") as! String)
            if(PFUser.currentUser().objectId == highestBidderID) {
                performSegueWithIdentifier("enterStream", sender: session)
            } else {
                self.navigationController?.popViewControllerAnimated(true)
            }
            return;
        }
        
        //calculate the minutes in elapsed time.
        let minutes = UInt8(remainingTime! / 60.0)
        remainingTime! -= (NSTimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        let seconds = UInt8(remainingTime!)
        remainingTime! -= NSTimeInterval(seconds)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        let strMinutes = minutes > 9 ? String(minutes):"0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds):"0" + String(seconds)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\(strMinutes):\(strSeconds)", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        
        self.reloadSessionBids()

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
    
    /**
    Reload session bids, called during update time every second, and upon entering a new bid to check the validity
    
    :returns: no return value, but reloads the table view and gets the data in the background with a PFQuery.
    */
    func reloadSessionBids() {

        var sessionQuery : PFQuery = PFQuery(className: "Session")
        sessionQuery.whereKey("objectId", equalTo: session.objectId)
        sessionQuery.findObjectsInBackgroundWithBlock({ (NSArray array, NSError error) -> Void in
            println(array.count)
            if(array.count == 0) {
                println("no objects in background")
            } else {
                self.sessionBids = array[0].objectForKey("bids") as? NSMutableArray
                
                if(!self.keyboardShowing) {
                    self.bidTableView.reloadData()
                }
            }
        })
    }
    
    /**
    Add bid to the bid array, checking that the bid is valid
    
    :param: sender AnyObject which is actually the button that is pressed
    
    :returns: no return value, but adds the bid if possible, and tells user if bid is below current bid
    */
    func addBid(sender: AnyObject) {
        SVProgressHUD.showProgress(0)
        var sessionQuery : PFQuery = PFQuery(className: "Session")
        sessionQuery.whereKey("objectId", equalTo: session.objectId)
        sessionQuery.findObjectsInBackgroundWithBlock({ (NSArray array, NSError error) -> Void in
            println(array.count)
            if(array.count == 0) {
                println("no current session")
            } else {
                SVProgressHUD.showProgress(25)
                if(self.bidTextField.text.rangeOfString("^[0-9]*$", options: .RegularExpressionSearch) != nil) {
                    self.sessionBids = array[0].objectForKey("bids") as? NSMutableArray
                    var lastSessionBid : NSDictionary
                    SVProgressHUD.showProgress(50)
                    var previousHighBid : Int! = 0
                    if(self.sessionBids == nil) {
                        self.sessionBids = NSMutableArray()
                        
                    } else {
                        lastSessionBid = self.sessionBids.objectAtIndex(self.sessionBids.count - 1) as! NSDictionary
                        previousHighBid = (lastSessionBid.objectForKey("bid") as! String).toInt()
                    }
                    
                    if( previousHighBid >= self.bidTextField.text.toInt()) {
                        println("bid is lower than current bid")
                        SVProgressHUD.showErrorWithStatus("Bid is lower than current bid!")
                        return
                    } else {
                        self.sessionBids!.addObject(NSDictionary(objects: [PFUser.currentUser().objectId, PFUser.currentUser().objectForKey("username"), self.bidTextField.text, PFUser.currentUser().objectForKey("facebookId")], forKeys: ["user", "name", "bid", "fbId"]))
                        SVProgressHUD.showProgress(75)
                        self.session.setObject(self.sessionBids, forKey: "bids")
                        self.session.save()
                        self.keyboardShowing = false
                        self.reloadSessionBids()
                        SVProgressHUD.showProgress(100)
                        SVProgressHUD.showSuccessWithStatus("Successfully Added Bid")
                    }
                } else {
                    SVProgressHUD.showErrorWithStatus("Bid must be a number!")
                }
            }
        })
    }
    
    
}
