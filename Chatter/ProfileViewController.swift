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

class ProfileViewController : UIViewController {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var viewCards: UIButton!
    @IBOutlet weak var editCards: UIButton!
    
    override func viewDidLoad() {
        
        var editProfileButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action:"editProfileButtonTapped:")
        self.navigationItem.rightBarButtonItem = editProfileButton
        
        logoutButton.frame = CGRectMake(10, self.view.bounds.size.height - 100, self.view.bounds.size.width-20, 50)
        logoutButton.layer.borderWidth = 2
        logoutButton.layer.cornerRadius = logoutButton.frame.size.height * 0.5

        viewCards.frame = CGRectMake(10, self.view.bounds.size.height - 165, self.view.bounds.size.width-20, 50)
        viewCards.layer.borderWidth = 2
        viewCards.layer.cornerRadius = logoutButton.frame.size.height * 0.5
        editCards.frame = CGRectMake(10, self.view.bounds.size.height - 230, self.view.bounds.size.width-20, 50)
        editCards.layer.borderWidth = 2
        editCards.layer.cornerRadius = logoutButton.frame.size.height * 0.5
        
        var facebookId = PFUser.currentUser().objectForKey("facebookId") as String
        var imageURLString = "http://graph.facebook.com/" + facebookId + "/picture?type=large"
        var imageURL = NSURL(string: imageURLString)
        profilePhoto.sd_setImageWithURL(imageURL)
        coverPhoto.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width)
//        coverPhoto.sd_setImageWithURL(imageURL, placeholderImage: "centeredPeople.png")
//        coverPhoto.sd_setImageWithURL(imageURL, placeholderImage: UIImage(named: "centeredPeople.png"))
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
                let resultImage : CIImage = gaussianBlurFilter.valueForKey("outputImage") as CIImage
                let endImage : UIImage = UIImage(CIImage: resultImage)!
                
                
                wSelf.coverPhoto.image = endImage
                println(wSelf.coverPhoto.frame)
                wSelf.coverPhoto.frame = CGRectMake(0, 0, wSelf.view.bounds.size.width, wSelf.view.bounds.size.width)
//                wSelf.view.backgroundColor = wSelf.averageColor(image)
//                println(wSelf.view.backgroundColor)
                wSelf.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
                
            }
        })
        
        
        profilePhoto.backgroundColor = UIColor.redColor()
        coverPhoto.addSubview(profilePhoto)
        
        //Don't forget this line
        profilePhoto.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var constX = NSLayoutConstraint(item: profilePhoto, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: coverPhoto, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        coverPhoto.addConstraint(constX)
        
        var constY = NSLayoutConstraint(item: profilePhoto, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: coverPhoto, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        coverPhoto.addConstraint(constY)
        
        var constW = NSLayoutConstraint(item: profilePhoto, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 150)
        profilePhoto.addConstraint(constW)
        //view.addConstraint(constW) also works
        
        var constH = NSLayoutConstraint(item: profilePhoto, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 150)
        profilePhoto.addConstraint(constH)
        
        profilePhoto.layer.borderWidth = 1
        profilePhoto.layer.cornerRadius = profilePhoto.layer.frame.size.height * 0.5
        profilePhoto.layer.masksToBounds = true
        
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

        performSegueWithIdentifier("logout", sender: self)
    }
    
    @IBAction func editCards(sender: AnyObject) {
        performSegueWithIdentifier("showCards", sender: self)
    }
    
    func editProfileButtonTapped(sender: AnyObject) {
        println("edit tapped")
        performSegueWithIdentifier("editProfile", sender: self)
    }
    
    
}