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
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        let sessionBids : NSArray = NSArray()
        return sessionBids.count+1
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("bidCell", forIndexPath: indexPath) as! UITableViewCell
        let sessionBids : NSArray = NSArray()
        if(indexPath.row == sessionBids.count) {
            // add bid view
            let buttonTextFieldOffset : CGFloat = 10
            let buttonWidth : CGFloat = cell.bounds.size.width / 3
            bidTextField = UITextField()
            bidTextField.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, 2 * cell.bounds.size.width / 3, cell.frame.size.height)
            bidTextField.borderStyle = .RoundedRect
            
            let addBidButton : UIButton = UIButton(frame: CGRectMake(cell.bounds.size.width - buttonWidth, cell.frame.origin.y, buttonWidth, cell.frame.size.height))
            addBidButton.backgroundColor = UIColor.redColor()
            addBidButton.titleLabel?.text = "Add Bid"
            addBidButton.titleLabel?.textColor = UIColor.whiteColor()
            addBidButton.addTarget(self, action: "addBid:", forControlEvents: .TouchUpInside)
            
            cell.addSubview(addBidButton)
            cell.addSubview(bidTextField)
            
        } else {
            let bid : NSDictionary = sessionBids.objectAtIndex(indexPath.row) as! NSDictionary
            cell.textLabel?.text = bid.objectForKey("name") as? String
            cell.detailTextLabel?.text = bid.objectForKey("bid") as? String
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.bidTableView.deselectRowAtIndexPath(indexPath, animated:false)
    }
    
    
    func addBid(sender: AnyObject) {
        println("add bid")
    }
    
    
}
