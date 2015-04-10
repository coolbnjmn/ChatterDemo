//
//  LoginSegue.swift
//  Chatter
//
//  Created on 2/12/15.
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


class LoginSegue : UIStoryboardSegue {
    

    
    override func perform() {
        
        var firstView = sourceViewController.view as UIView!
        var secondView = UIView()
        
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        
        secondView.frame = CGRectOffset(firstView.frame, 0, 0)
        secondView.backgroundColor = UIColor(red: 0/255.0, green: 208/255.0, blue: 127/255.0, alpha: 1.0)
        secondView.alpha = 0.0
        
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(secondView, aboveSubview: firstView)
        
        UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            secondView.alpha = 1.0
           
            }) { (success : Bool) -> Void in
                
            self.sourceViewController.presentViewController(self.destinationViewController as! UIViewController, animated: false, completion: nil)
            
            window?.clipsToBounds = true
            window?.layer.cornerRadius = 8.0
            var animation = CABasicAnimation(keyPath: "cornerRadius");
            animation.fromValue = 0.0
            animation.toValue = 8.0
            animation.duration = 0.25
            window?.layer.addAnimation(animation, forKey: "cornerRadiusAnimation");
                
            UIView.animateWithDuration(0.15, delay: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                secondView.alpha = 0;
                }, completion: { (finished : Bool) -> Void in
                
            })
        }
        
    }
    
    
    
    
    
    
}