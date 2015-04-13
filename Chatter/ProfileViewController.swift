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
    var currentValidProducts : [AnyObject]!
    
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
    let ApplePaySwagMerchantID = "merchant.BenjaminHendricks.Chatter"
    override func viewDidLoad() {
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        product_id = "session_time"

        var editProfileButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action:"editProfileButtonTapped:")
        self.navigationItem.rightBarButtonItem = editProfileButton
        
        logoutButton.frame = CGRectMake(10, self.view.bounds.size.height - 100, self.view.bounds.size.width-20, 50)
        logoutButton.layer.borderWidth = 2
        logoutButton.layer.cornerRadius = logoutButton.frame.size.height * 0.5

        applePayButton.frame = CGRectMake(10, self.view.bounds.size.height - 165, self.view.bounds.size.width-20, 50)
        applePayButton.layer.borderWidth = 2
        applePayButton.layer.cornerRadius = logoutButton.frame.size.height * 0.5
        applePayButton.imageView?.frame = CGRectMake(0,0,applePayButton.frame.size.width, applePayButton.frame.size.height)


        cashOutButton.frame = CGRectMake(10, self.view.bounds.size.height - 230, self.view.bounds.size.width-20, 50)
        cashOutButton.layer.borderWidth = 2
        cashOutButton.layer.cornerRadius = logoutButton.frame.size.height * 0.5
        
        var facebookId = PFUser.currentUser().objectForKey("facebookId") as! String
        var imageURLString = "http://graph.facebook.com/" + facebookId + "/picture?type=large"
        var imageURL = NSURL(string: imageURLString)
        profilePhoto.sd_setImageWithURL(imageURL)
        coverPhoto.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width)

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
                wSelf.coverPhoto.frame = CGRectMake(0, 0, wSelf.view.bounds.size.width, wSelf.view.bounds.size.width)
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
        
        creditLabel = UILabel()
        creditLabel.text = "You have X credits."
        creditLabel.textColor = UIColor.orangeColor()
        creditLabel.sizeToFit()
        creditLabel.frame.origin = CGPointMake((self.view.bounds.size.width - creditLabel.frame.size.width)/2, coverPhoto.frame.size.height)
        
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
        
        creditLabel.text = "You have " + creditString + " credits. "
        creditLabel.sizeToFit()
        creditLabel.frame.origin = CGPointMake((self.view.bounds.size.width - creditLabel.frame.size.width)/2, coverPhoto.frame.size.height)
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
            var validProducts = response.products
            iapView = UIView(frame: CGRectMake(((self.view.bounds.size.width - self.view.bounds.size.width/2)/2),((self.view.bounds.size.height - self.view.bounds.size.height/2)/2),self.view.bounds.size.width/2, self.view.bounds.size.height/2))
            iapView.backgroundColor = UIColor.redColor()
            iapView.layer.cornerRadius = 25
            
            
            validProducts.sort(isOrderedBefore)
            currentValidProducts = validProducts

            for(var i = 0; i < validProducts.count; i++) {
                println(validProducts[i])
                println(validProducts[i].localizedTitle)
                var iapItemButton = UIButton(frame: CGRectMake(CGFloat(10),CGFloat(50*i+5*(i+1)),self.view.bounds.size.width/2 - 20,CGFloat(50)))
                iapItemButton.layer.cornerRadius = 10
                iapItemButton.backgroundColor = UIColor.whiteColor()
                iapItemButton.setTitle(validProducts[i].localizedTitle, forState:.Normal)
                iapItemButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
                iapItemButton.setTitleColor(UIColor.redColor(), forState: .Selected)
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