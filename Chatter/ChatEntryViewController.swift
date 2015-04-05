//
//  ChatEntryViewController.swift
//  Chatter
//
//  Created on 1/24/15.
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
import Parse

class ChatEntryViewController : UIViewController {
    
    @IBOutlet weak var logo: UIView!
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var gradientView: UIImageView!
    @IBOutlet weak var tagLine: UILabel!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var facebookDisclaimer: UILabel!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        var verticalMotionEffect : UIInterpolatingMotionEffect =
        UIInterpolatingMotionEffect(keyPath: "center.y",
            type: .TiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = 80
        verticalMotionEffect.maximumRelativeValue = -80
        
        // Set horizontal effect
        var horizontalMotionEffect : UIInterpolatingMotionEffect =
        UIInterpolatingMotionEffect(keyPath: "center.x",
            type: .TiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = 80
        horizontalMotionEffect.maximumRelativeValue = -80
        
        // Create group to combine both
        var group : UIMotionEffectGroup = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        // Add both effects to your view
        backgroundView.addMotionEffect(group)
    }
    

    
    @IBAction func FacebookLogin(sender: AnyObject) {
        
        println("facebook login is working")
        hideUI()
        
        SVProgressHUD.showWithStatus("Logging In")
        
        PFFacebookUtils.logInWithPermissions(["email", "user_about_me"], {
            (user: PFUser!, error: NSError!) -> Void in
            println(PFFacebookUtils.version())
            if error != nil {
                NSLog(error.description);
            }
            
            if user == nil {
                NSLog("Uh oh. The user cancelled the Facebook login.")
                return
            } else if user.isNew {
                NSLog("User signed up and logged in through Facebook!")
                
                FBRequestConnection.startForMeWithCompletionHandler({ (connection : FBRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                    
                    PFUser.currentUser().setObject(result["id"], forKey: "facebookId")
                    PFUser.currentUser().setObject(result["first_name"], forKey: "first_name")
                    PFUser.currentUser().setObject(result["last_name"], forKey: "last_name")
                    PFUser.currentUser().saveInBackgroundWithBlock({ (success : Bool, error : NSError!) -> Void in
                        if error != nil {
                            NSLog(error!.description);
                        } else if success {
                            self.performSegueWithIdentifier("login", sender: self);
                            SVProgressHUD.dismiss()

                        }
                    })
                
                })
                
            } else {
                NSLog("User logged in through Facebook!")
                self.performSegueWithIdentifier("login", sender: self);
                
                SVProgressHUD.dismiss()
            }
            
        })
        
    }
    
    
    func hideUI() {
        
        
        
        UIView.animateWithDuration(0.15, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.logo.alpha = 0.0
            self.tagLine.alpha = 0.0
            self.facebookLoginButton.alpha = 0.0
            self.facebookDisclaimer.alpha = 0.0
            }) { (success : Bool) -> Void in
        }
        
    }
    


    
    
}