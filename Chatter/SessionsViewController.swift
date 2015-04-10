//
//  SessionsViewController.swift
//  Chatter
//
//  Created on 2/20/15.
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
import ParseUI

class SessionsViewController : PFQueryTableViewController {
    
    

    
    override init!(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "Session"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = true
        self.objectsPerPage = 20
    }

    
    

    override func queryForTable() -> PFQuery! {
        var query = PFQuery(className: "Session")
        
        if count(objects) == 0 {
            query.cachePolicy = kPFCachePolicyCacheThenNetwork
        }
        
        query.orderByDescending("createdAt")
        
        return query
    }
    
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFTableViewCell! {
        
        var identifier = "sessionCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! SessionCell
        
        var session = objectAtIndexPath(indexPath) as PFObject
        
        cell.hostAvatar.sd_cancelCurrentImageLoad();
        if (session["facebookId"] != nil) {
            var facebookId = session["facebookId"] as! String
            var imageString = "http://graph.facebook.com/" + facebookId + "/picture?type=large"
            var imageURL = NSURL(string: imageString)
            cell.hostAvatar.sd_setImageWithURL(imageURL);
        }
 
        if session["hostName"] != nil {
            cell.hostName.text = session["hostName"] as! String
        }
        
        if session["chatTitle"] != nil {
            cell.subjectTitle.text = session["chatTitle"] as! String
        }
        
        
        return cell
    }
    


    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        var session = objects[indexPath.row] as! PFObject
        

    }

    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var session = objects[indexPath.row] as! PFObject
        performSegueWithIdentifier("viewDetails", sender: session)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewDetails" {
           
            var d = segue.destinationViewController as! ChatDetailsViewController
            d.session = sender as! PFObject
            
        }
    }

    
}