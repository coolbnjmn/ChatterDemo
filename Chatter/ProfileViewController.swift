//
//  ProfileViewController.swift
//  Chatter
//
//  Created on 2/23/15.
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
import PassKit

class ProfileViewController : UIViewController  {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var cashOutButton: UIButton!
    @IBOutlet weak var applePayButton: UIButton!
    
    var product_id: NSString?
    var iapView: UIView!
    var iapButton : UIButton!
    var creditLabel : UILabel!
    var nameLabel: UILabel!
    var currentValidProducts : [AnyObject]!
    
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
    let ApplePaySwagMerchantID = "merchant.BenjaminHendricks.Chatter"
    override func viewDidLoad() {
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        product_id = "session_time"
        var editProfileButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action:"editProfileButtonTapped:")
        self.navigationItem.rightBarButtonItem = editProfileButton
        
        let buttonHeight: CGFloat = 40
        let buttonOffset : CGFloat = 10
        let buttonWidth : CGFloat = self.view.bounds.size.width - 2*buttonOffset
        
        logoutButton.frame = CGRectMake(buttonOffset, self.view.bounds.size.height - 1*(buttonHeight+buttonOffset),buttonWidth, buttonHeight)
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.cornerRadius = 5
        logoutButton.backgroundColor = UIColor.init(red: 0, green: 104/255.0, blue: 174/255.0, alpha: 1.0)

        applePayButton.frame = CGRectMake(buttonOffset, self.view.bounds.size.height - 2*(buttonHeight+buttonOffset), buttonWidth, buttonHeight)
        applePayButton.layer.borderWidth = 1
        applePayButton.layer.cornerRadius = 5
        applePayButton.backgroundColor = UIColor.init(red: 0, green: 104/255.0, blue: 174/255.0, alpha: 1.0)


        cashOutButton.frame = CGRectMake(buttonOffset, self.view.bounds.size.height - 3*(buttonHeight+buttonOffset), buttonWidth, buttonHeight)
        cashOutButton.layer.borderWidth = 1
        cashOutButton.layer.cornerRadius = 5
        cashOutButton.backgroundColor = UIColor.init(red: 0, green: 104/255.0, blue: 174/255.0, alpha: 1.0)

        
        var facebookId = PFUser.currentUser().objectForKey("facebookId") as! String
        var imageURLString = "http://graph.facebook.com/" + facebookId + "/picture?type=large"
        var imageURL = NSURL(string: imageURLString)
        profilePhoto.sd_setImageWithURL(imageURL)
        println(self.navigationController!.navigationBar.frame.size.height)
        coverPhoto.frame = CGRectMake(0, self.navigationController!.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.width)

        SDWebImageDownloader.sharedDownloader().downloadImageWithURL(imageURL, options: nil, progress: nil, completed: {[weak self] (image, data, error, finished) in
            if let wSelf = self {
                // do what you want with the image/self
                UIGraphicsBeginImageContext(wSelf.coverPhoto.bounds.size)
                wSelf.coverPhoto.layer.renderInContext(UIGraphicsGetCurrentContext())
                let viewImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                let imageToBlur : CIImage = CIImage(image: image)
                var gaussianBlurFilter : CIFilter = CIFilter(name: "CIGaussianBlur")
                gaussianBlurFilter.setValue(imageToBlur, forKey: "inputImage")
                gaussianBlurFilter.setValue(NSNumber(float: 10), forKey: "inputRadius")
                let resultImage : CIImage = gaussianBlurFilter.valueForKey("outputImage") as! CIImage
                let endImage : UIImage = UIImage(CIImage: resultImage)!
                
                
                wSelf.coverPhoto.image = endImage
                println(wSelf.coverPhoto.frame)
                wSelf.coverPhoto.frame = CGRectMake(0, wSelf.navigationController!.navigationBar.frame.size.height, wSelf.view.bounds.size.width, wSelf.view.bounds.size.width)
                wSelf.view.backgroundColor = UIColor.init(red:14/255.0, green:14/255.0, blue:14/255.0, alpha:1.0).colorWithAlphaComponent(0.5)
                
            }
        })
        
        
        profilePhoto.backgroundColor = UIColor.redColor()
        coverPhoto.addSubview(profilePhoto)
        
        profilePhoto.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var constX = NSLayoutConstraint(item: profilePhoto, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: coverPhoto, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        coverPhoto.addConstraint(constX)
        
        var constY = NSLayoutConstraint(item: profilePhoto, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: coverPhoto, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        coverPhoto.addConstraint(constY)
        
        var constW = NSLayoutConstraint(item: profilePhoto, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 225)
        profilePhoto.addConstraint(constW)
        
        var constH = NSLayoutConstraint(item: profilePhoto, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 225)
        profilePhoto.addConstraint(constH)
        
        profilePhoto.layer.borderWidth = 1
        profilePhoto.layer.cornerRadius = profilePhoto.layer.frame.size.height * 0.5
        profilePhoto.layer.masksToBounds = true
        
        nameLabel = UILabel()
        let fullname : String? = (PFUser.currentUser().objectForKey("first_name") as! String) + " " + (PFUser.currentUser().objectForKey("last_name") as! String)
        
        for family in UIFont.familyNames() {
            println(family)
            let familyName : String! = family as! String
            for name in UIFont.fontNamesForFamilyName(familyName) {
                println(name)
            }
        }
        
        nameLabel.text = fullname
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.font = UIFont.init(name: "MyriadPro-Regular", size: 36)
        nameLabel.sizeToFit()
        nameLabel.frame.origin = CGPointMake((self.view.bounds.size.width - nameLabel.frame.size.width)/2, coverPhoto.frame.size.height+buttonOffset)
        self.view.addSubview(nameLabel)
        
        creditLabel = UILabel()
        creditLabel.text = "X credits"
        creditLabel.textColor = UIColor.whiteColor()
        creditLabel.font = UIFont.init(name: "MyriadPro-Regular", size: 26)
        creditLabel.sizeToFit()
        creditLabel.frame.origin = CGPointMake((self.view.bounds.size.width - creditLabel.frame.size.width)/2, coverPhoto.frame.size.height+nameLabel.frame.size.height+2*buttonOffset)
        
        self.view.addSubview(creditLabel)
        self.updateCreditLabel()
    }
    
    
    @IBAction func unwindToProfile(segue : UIStoryboardSegue){
        println("unwinding to profile")
        var svc = slidingViewController()
        if svc.currentTopViewPosition == ECSlidingViewControllerTopViewPosition.Centered {
            svc.anchorTopViewToRightAnimated(true)
        } else {
            svc.resetTopViewAnimated(true)
        }
    }
    
    @IBAction func logout(sender : AnyObject) {
        PFUser.logOut()
        performSegueWithIdentifier("logout", sender: self)
    }
    
    @IBAction func cashOut(sender: AnyObject) {
        performSegueWithIdentifier("cashOut", sender: self)
    }
    
    func editProfileButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("editProfile", sender: self)
    }
    @IBAction func applePayButtonPressed(sender : AnyObject) {
        performSegueWithIdentifier("addCredits", sender: self)
    }
    
    /**
    Update Credit Label
    This method updates the credit label with the appropriate value, then sizes it, and adds it as a subview. 
    
    :returns: no return value, but does layout subviews.
    */
    func updateCreditLabel() {
        var creditStringObj : AnyObject? = PFUser.currentUser().objectForKey("credits")
        var creditString : String
        if(creditStringObj == nil) {
            creditString = "0"
        } else {
            creditString = creditStringObj as! String
        }
        
        creditLabel.text = creditString + " credits"
        creditLabel.sizeToFit()
        creditLabel.frame.origin = CGPointMake((self.view.bounds.size.width - creditLabel.frame.size.width)/2, coverPhoto.frame.size.height+nameLabel.frame.size.height+20)
        self.view.layoutSubviews()
    }
    
}