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

class ProfileViewController : UIViewController , SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
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
        
        //Don't forget this line
        profilePhoto.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var constX = NSLayoutConstraint(item: profilePhoto, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: coverPhoto, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        coverPhoto.addConstraint(constX)
        
        var constY = NSLayoutConstraint(item: profilePhoto, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: coverPhoto, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        coverPhoto.addConstraint(constY)
        
        var constW = NSLayoutConstraint(item: profilePhoto, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 225)
        profilePhoto.addConstraint(constW)
        //view.addConstraint(constW) also works
        
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
        println("edit tapped")
        performSegueWithIdentifier("editProfile", sender: self)
    }
    @IBAction func applePayButtonPressed(sender : AnyObject) {
        // apple pay stuff here
        println("button pressed")

        if (SKPaymentQueue.canMakePayments())
        {
            var productIDArray: [AnyObject!] = ["10_credits", "55_credits", "110_credits", "270_credits", "530_credits"]
            
            var productID:NSSet = NSSet(array: productIDArray)
            
            var productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as Set<NSObject>);
            productsRequest.delegate = self;
            productsRequest.start();
            println("Fething Products");
        } else {
            println("can not make purchases");
        }
    }
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
    
    func buyProduct(product: SKProduct){
        println("Sending the Payment Request to Apple");
        var payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment);
        
    }
    
    func dismissIAP(sender: AnyObject!) {
        iapView.removeFromSuperview()
        iapButton.removeFromSuperview()
    }
    
    func iapItemPressed(sender: AnyObject!) {
        var senderButton : UIButton = sender as! UIButton
        var tag : Int = senderButton.tag
        buyProduct(currentValidProducts[tag] as! SKProduct)
    }
    
    func isOrderedBefore(a: AnyObject, b: AnyObject) -> Bool {
        let aA = a as! SKProduct
        let bB = b as! SKProduct
        let aPrice = aA.price.integerValue
        let bPrice = bB.price.integerValue
        if(aPrice < bPrice) {
            return true
        } else {
            return false
        }
    }
    
    func productsRequest (request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        println("got the request from Apple")
        var count : Int = response.products.count
        if (count>0) {
            let productHeight : CGFloat = 40
            let productOffset : CGFloat = 10
            let floatCount : CGFloat = CGFloat(count)
            let iapViewHeight : CGFloat = (productHeight * floatCount) + (productOffset * (floatCount+1))
            var validProducts = response.products
            iapView = UIView(frame: CGRectMake( (self.view.bounds.size.width - self.view.bounds.size.width/2)/2, (self.view.bounds.size.height - iapViewHeight)/2, self.view.bounds.size.width/2,iapViewHeight))
            
            iapView.backgroundColor = UIColor.init(red:14/255.0, green: 14/255.0, blue: 14/255.0, alpha: 1.0)
            iapView.layer.cornerRadius = 5
            
            
            validProducts.sort(isOrderedBefore)
            currentValidProducts = validProducts

            for(var i = 0; i < validProducts.count; i++) {
                println(validProducts[i])
                println(validProducts[i].localizedTitle)
                var iapItemButton = UIButton(frame: CGRectMake(productOffset,CGFloat(productHeight*CGFloat(i)+productOffset*CGFloat(i+1)),self.view.bounds.size.width/2 - productOffset * 2,productHeight))
                iapItemButton.layer.cornerRadius = 5
                iapItemButton.backgroundColor = UIColor.init(red: 0, green: 104/255.0, blue: 174/255.0, alpha: 1.0)
                iapItemButton.setTitle(validProducts[i].localizedTitle, forState:.Normal)
                iapItemButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                iapItemButton.setTitleColor(UIColor.blueColor(), forState: .Selected)
                iapItemButton.titleLabel!.font = UIFont.init(name: "MyriadPro-Regular", size: 22)
                iapItemButton.addTarget(self, action: "iapItemPressed:", forControlEvents: .TouchUpInside)
                iapItemButton.tag = i
                iapView.addSubview(iapItemButton)
                
            }
            
            iapButton = UIButton(frame: CGRectMake(0,0,self.view.bounds.size.width, self.view.bounds.size.height))
            iapButton.backgroundColor = UIColor.clearColor()
            self.view.addSubview(iapView)
            self.view.insertSubview(iapButton, belowSubview: iapView)
            
            iapButton.addTarget(self, action: "dismissIAP:", forControlEvents: .TouchUpInside)
            
            
            
            var validProduct: SKProduct = response.products[0] as! SKProduct
        } else {
            println("nothing")
        }
    }
    
    
    func request(request: SKRequest!, didFailWithError error: NSError!) {
        println("La vaina fallo");
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!)    {
        println("Received Payment Transaction Response from Apple");
        
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .Purchased:
                    println("Product Purchased");
                    var currentCreditString: String = PFUser.currentUser().objectForKey("credits") as! String
                    var currentCredits : Int = currentCreditString.toInt()!
                    
                    println(trans.payment.productIdentifier)
                    switch trans.payment.productIdentifier {
                        case "10_credits":
                            currentCredits += 10
                            break;
                        case "55_credits":
                            currentCredits += 55
                            break;
                        case "110_credits":
                            currentCredits += 110
                            break;
                        case "270_credits":
                            currentCredits += 270
                            break;
                        case "530_credits":
                            currentCredits += 530
                            break;
                        default:
                            println("error")
                            break;
                    }
                    PFUser.currentUser().setObject(currentCredits.description, forKey: "credits")
                    var error : NSErrorPointer = NSErrorPointer()
                    PFUser.currentUser().save(error)
                    if(error != nil) {
                        /// Do error handling
                        println("error in credit giving")
                    }
                    
                    self.updateCreditLabel()
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                    self.dismissIAP(self)
                    
                    break;
                case .Failed:
                    println("Purchased Failed");
                    println((transaction as! SKPaymentTransaction).error)
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                    // case .Restored:
                    //[self restoreTransaction:transaction];
                default:
                    break;
                }
            }
        }
        
    }
    
    
}