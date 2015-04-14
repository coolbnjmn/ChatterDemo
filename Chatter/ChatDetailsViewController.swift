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
    var sessionBids : NSMutableArray!
    
    @IBOutlet weak var bidTableView: UITableView!
    
    @IBOutlet weak var joinChatButton: UIButton!
    @IBAction func joinChat(sender : AnyObject){
        performSegueWithIdentifier("enterStream", sender: session)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tableViewHeight : CGFloat = 300
        let bufferSize : CGFloat = 20
        self.bidTableView.frame = CGRectMake(0, self.view.bounds.size.height - tableViewHeight - joinChatButton.frame.size.height - bufferSize, self.view.bounds.size.width, tableViewHeight)
        
        let buttonTextFieldOffset : CGFloat = 10
        let buttonWidth : CGFloat = self.view.bounds.size.width / 3
        let buttonHeight : CGFloat = 65
        bidTextField = UITextField()
        bidTextField.frame = CGRectMake(0, self.view.bounds.size.height - tableViewHeight - joinChatButton.frame.size.height - bufferSize * 2 - buttonHeight, 2 * self.view.bounds.size.width / 3, buttonHeight)
        bidTextField.borderStyle = .RoundedRect
        bidTextField.keyboardType = .NumberPad
        let addBidButton : UIButton = UIButton(frame: CGRectMake(self.view.bounds.size.width - buttonWidth, self.view.bounds.size.height - tableViewHeight - joinChatButton.frame.size.height - bufferSize * 2 - buttonHeight, buttonWidth, buttonHeight))
        addBidButton.backgroundColor = UIColor.redColor()
        addBidButton.setTitle("Add Bid", forState:.allZeros)
        addBidButton.setTitleColor(UIColor.whiteColor(), forState:.allZeros)
        addBidButton.addTarget(self, action: "addBid:", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(addBidButton)
        self.view.addSubview(bidTextField)
        self.bidTableView.reloadData()

    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "enterStream" {
            var session = sender as! PFObject
            var svc = segue.destinationViewController as! StreamViewController
            
            svc.session = session
        }
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
        
        sessionBids!.addObject(NSDictionary(objects: [PFUser.currentUser().objectId, PFUser.currentUser().objectForKey("username"), bidTextField.text], forKeys: ["user", "name", "bid"]))
        session.setObject(sessionBids, forKey: "bids")
        session.save()
        self.bidTableView.reloadData()
        
    }
    
    
}
