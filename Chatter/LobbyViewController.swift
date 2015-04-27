//
//  LobbyViewController.swift
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
import CoreGraphics

class LobbyViewController : UIViewController {
    
    override func viewDidLoad() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if((defaults.objectForKey("timesLaunched") as! Int) < 2) {
            performSegueWithIdentifier("editProfile", sender: self)
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"profile.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "openProfile:")
        
    }
    
    @IBAction func startNewChat(sender: AnyObject) {
        performSegueWithIdentifier("startNewChat", sender: sender)
    }
    

    func openProfile(sender: AnyObject) {
        performSegueWithIdentifier("showProfile", sender: sender)
    }

    
}