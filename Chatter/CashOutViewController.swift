//
//  CashOutViewController.swift
//  Chatter
//
//  Created by Benjamin Hendricks on 4/12/15.
//  Copyright (c) 2015 Eddy Borja. All rights reserved.
//

import UIKit
import Parse

class CashOutViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var cashOutButton: UIButton!
    
    var routingNumberTextField : UITextField!
    var accountNumberTextField : UITextField!
    
    var isEnteringBankInfo : Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        var stripeQuery : PFQuery = PFQuery(className: "StripeCustomer")
        stripeQuery.whereKey("userObj", equalTo: PFUser.currentUser().objectId)

        stripeQuery.findObjectsInBackgroundWithBlock({ (NSArray array, NSError error) -> Void in
            println(array.count)
            if(array.count == 0) {
             // setup bank add views
                self.setupBankInfoViews()
                self.isEnteringBankInfo = true
            } else {
                var credits : String = PFUser.currentUser().objectForKey("credits") as! String
                var text = "You have "
                text += credits
                text += " credits. Cash out now for XXX dollars"
                self.creditLabel.text = text
                self.isEnteringBankInfo = false
                if(self.routingNumberTextField != nil) {
                    self.routingNumberTextField.removeFromSuperview()
                }
                if(self.accountNumberTextField != nil) {
                    self.accountNumberTextField.removeFromSuperview()
                }
                self.cashOutButton.setTitle("Cash Out", forState: UIControlState.allZeros)

            }
            
        })
        
        let buttonHeight : CGFloat = 50
        let buttonOffset : CGFloat = 10
        self.cashOutButton.frame = CGRectMake(0, self.view.bounds.size.height - buttonHeight, self.view.bounds.size.width, buttonHeight)
        self.creditLabel.frame = CGRectMake(0, self.view.bounds.size.height - buttonHeight*3 - buttonOffset, self.view.bounds.size.width, buttonHeight*2)
        self.view.backgroundColor = UIColor.init(red: 14/255.0, green: 14/255.0, blue: 14/255.0, alpha:0.5)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red:75/255.0, green:193/255.0, blue:210/255.0, alpha:1.0)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if(routingNumberTextField != nil) {
            routingNumberTextField.resignFirstResponder()
        }
        if(accountNumberTextField != nil) {
            accountNumberTextField.resignFirstResponder()
        }
        
    }
    
    func setupBankInfoViews() {
        println("bank info")
        self.creditLabel.text = "Please enter your banking information to cash out."
        self.cashOutButton.setTitle("Add Bank Account", forState: UIControlState.allZeros)
        let textFieldWidth : CGFloat = self.view.bounds.size.width * 0.8
        let textFieldHeight : CGFloat = 60
        let yOffset : CGFloat = self.view.bounds.size.height/3
        let xOffset : CGFloat = (self.view.bounds.size.width - textFieldWidth)/2
        routingNumberTextField = UITextField(frame: CGRectMake(xOffset, yOffset, textFieldWidth, textFieldHeight))
        accountNumberTextField = UITextField(frame: CGRectMake(xOffset, yOffset+textFieldHeight*1.1, textFieldWidth, textFieldHeight))
        routingNumberTextField.placeholder = "Routing Number"
        accountNumberTextField.placeholder = "Account Number"
        routingNumberTextField.keyboardType = UIKeyboardType.NumberPad
        accountNumberTextField.keyboardType = UIKeyboardType.NumberPad
        
        routingNumberTextField.font = UIFont(name: "MyriadPro-Regular", size: 32)
        accountNumberTextField.font = UIFont(name: "MyriadPro-Regular", size: 32)
        routingNumberTextField.textColor = UIColor.whiteColor()
        accountNumberTextField.textColor = UIColor.whiteColor()
        routingNumberTextField.borderStyle = .RoundedRect
        accountNumberTextField.borderStyle = .RoundedRect
        
        routingNumberTextField.textAlignment = .Center
        accountNumberTextField.textAlignment = .Center
        routingNumberTextField.delegate = self
        accountNumberTextField.delegate = self
        routingNumberTextField.tag = 1
        accountNumberTextField.tag = 2
        
        routingNumberTextField.backgroundColor = UIColor.init(red: 120/255.0, green: 120/255.0, blue: 120/255.0, alpha: 1.0)
        accountNumberTextField.backgroundColor = UIColor.init(red: 120/255.0, green: 120/255.0, blue: 120/255.0, alpha: 1.0)

        
        self.view.addSubview(accountNumberTextField)
        self.view.addSubview(routingNumberTextField)

    }

    @IBAction func cashOutButtonPressed(sender: AnyObject) {
        if(self.isEnteringBankInfo && routingNumberTextField != nil && accountNumberTextField != nil) {
            if((routingNumberTextField.text.rangeOfString("^[0-9]{9,9}$", options: .RegularExpressionSearch)) != nil && (accountNumberTextField.text.rangeOfString("^[0-9]{12,12}$", options: .RegularExpressionSearch)) != nil) {
                SVProgressHUD.showWithStatus("Adding Bank Account")
                // 9 digit numbers for routing, 10 for account
                // make new stripe customer with banking info
                let completion : STPCompletionBlock = { [weak self] (token: STPToken!, error: NSError!) in
                    let wSelf = self
                    
                    println("#######")
                    if(error == nil) {
                        // call cloud function
                        println(token)
                        let params = NSMutableDictionary()
                        params.setValue(token.tokenId, forKey: "token")
                        params.setValue(PFUser.currentUser().objectId, forKey: "userObjectId")
                        let block : (AnyObject!, NSError!) -> Void = {
                            (results: AnyObject!, error: NSError!) in
                            println("********")
                            if(error == nil) {
                                println(results)
                                SVProgressHUD.showSuccessWithStatus("Success!")
                                wSelf?.viewDidLoad()
                            } else {
                                println(error)
                            }
                            println("********")
                        }
                        PFCloud.callFunctionInBackground("addPaymentSource", withParameters:params as [NSObject : AnyObject], block: block)
                        
                    } else {
                        print(error)
                        let alert = UIAlertView()
                        alert.title = "Invalid Bank Account Info"
                        alert.message = "Please try again."
                        alert.addButtonWithTitle("Ok")
                        alert.show()
                        SVProgressHUD.dismiss()
                    }
                    println("#######")
                    
                }
                let bankAccount = STPBankAccount()
                bankAccount.routingNumber = routingNumberTextField.text
                bankAccount.accountNumber = accountNumberTextField.text
                bankAccount.country = "US"
                
                STPAPIClient.sharedClient().createTokenWithBankAccount(bankAccount, completion: completion)
            } else if((routingNumberTextField.text.rangeOfString("^[0-9]{9,9}$", options: .RegularExpressionSearch)) != nil && (accountNumberTextField.text.rangeOfString("^[0-9]{12,12}$", options: .RegularExpressionSearch)) == nil) {
                let animation = CABasicAnimation(keyPath: "position")
                animation.duration = 0.07
                animation.repeatCount = 4
                animation.autoreverses = true
                animation.fromValue = NSValue(CGPoint: CGPointMake(accountNumberTextField.center.x - 10, accountNumberTextField.center.y))
                animation.toValue = NSValue(CGPoint: CGPointMake(accountNumberTextField.center.x + 10, accountNumberTextField.center.y))
                accountNumberTextField.layer.addAnimation(animation, forKey: "position")

            } else if((routingNumberTextField.text.rangeOfString("^[0-9]{9,9}$", options: .RegularExpressionSearch)) == nil && (accountNumberTextField.text.rangeOfString("^[0-9]{12,12}$", options: .RegularExpressionSearch)) != nil) {
                let animation = CABasicAnimation(keyPath: "position")
                animation.duration = 0.07
                animation.repeatCount = 4
                animation.autoreverses = true
                animation.fromValue = NSValue(CGPoint: CGPointMake(routingNumberTextField.center.x - 10, routingNumberTextField.center.y))
                animation.toValue = NSValue(CGPoint: CGPointMake(routingNumberTextField.center.x + 10, routingNumberTextField.center.y))
                routingNumberTextField.layer.addAnimation(animation, forKey: "position")


            } else {
                let animation = CABasicAnimation(keyPath: "position")
                animation.duration = 0.07
                animation.repeatCount = 4
                animation.autoreverses = true
                animation.fromValue = NSValue(CGPoint: CGPointMake(routingNumberTextField.center.x - 10, routingNumberTextField.center.y))
                animation.toValue = NSValue(CGPoint: CGPointMake(routingNumberTextField.center.x + 10, routingNumberTextField.center.y))
                routingNumberTextField.layer.addAnimation(animation, forKey: "position")

                animation.fromValue = NSValue(CGPoint: CGPointMake(accountNumberTextField.center.x - 10, accountNumberTextField.center.y))
                animation.toValue = NSValue(CGPoint: CGPointMake(accountNumberTextField.center.x + 10, accountNumberTextField.center.y))
                accountNumberTextField.layer.addAnimation(animation, forKey: "position")
                
                
            }
   
        } else {
            println("cash out pressed")
            
        }
    }


}
