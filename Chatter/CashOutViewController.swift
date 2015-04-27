//
//  CashOutViewController.swift
//  Chatter
//
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
        
        let titleDict: NSMutableDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        titleDict.setObject(UIFont(name: "MyriadPro-Regular", size:20)!, forKey:NSFontAttributeName)
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as [NSObject : AnyObject]

        self.navigationItem.title = "Bank Information"
        // Do any additional setup after loading the view.
        var stripeQuery : PFQuery = PFQuery(className: "StripeRecipient")
        stripeQuery.whereKey("user_id", equalTo: PFUser.currentUser().objectId)

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
                text += " credits"
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
        
        let buttonHeight : CGFloat = 60
        let buttonOffset : CGFloat = 10
        self.cashOutButton.frame = CGRectMake(buttonOffset, self.view.bounds.size.height - buttonHeight*2, self.view.bounds.size.width - 2*buttonOffset, buttonHeight)
        self.cashOutButton.layer.cornerRadius = 5
        self.cashOutButton.backgroundColor = UIColor.init(red:231/255.0, green:231/255.0, blue:231/255.0, alpha:1.0)
        self.creditLabel.frame = CGRectMake(0, self.view.bounds.size.height - buttonHeight*3 - buttonOffset, self.view.bounds.size.width, buttonHeight)
        self.creditLabel.numberOfLines = 1
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.setupTextLabels()
        
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
    
    /**
    Method that simply sets up the text views at the top of the screen. Called in view did load.
    */
    func setupTextLabels() {
        let topBarHeight : CGFloat = self.navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height
        let headerView : UIView = UIView(frame: CGRectMake(0,topBarHeight,self.view.bounds.size.width, self.view.bounds.size.height / 3))
        
        let labelOffset : CGFloat = 30
        let heightOffset : CGFloat = 10
        let whatIsLabel : UILabel = UILabel(frame: CGRectMake(labelOffset,heightOffset, self.view.bounds.size.width - 2*labelOffset, 40))
        whatIsLabel.text = "Why does Chatter need bank info?"
        whatIsLabel.numberOfLines = 1
        whatIsLabel.font = UIFont(name: "MyriadPro-Regular", size: 18)
        whatIsLabel.textAlignment = .Center
        
        headerView.addSubview(whatIsLabel)
        
        let explainLabel : UILabel = UILabel(frame: CGRectMake(labelOffset, 40+heightOffset, self.view.bounds.size.width - 2*labelOffset, 60))
        explainLabel.text = "Chatter converts credits to $$$\n100 Credits = $5\nMinimum cashout = 100 credits"
        explainLabel.numberOfLines = 0
        explainLabel.textColor = UIColor.grayColor()
        explainLabel.font = UIFont(name: "MyriadPro-Regular", size: 16)
        explainLabel.textAlignment = .Center
        
        headerView.addSubview(explainLabel)
        headerView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(headerView)
        
    }
    
    /**
    Method that sets up the bank account information entry views only if needed.
    */
    func setupBankInfoViews() {
        self.creditLabel.text = "Enter information to cash out"
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
        routingNumberTextField.textColor = UIColor.init(red:5/255.0, green:5/255.0, blue:5/255.0, alpha:1.0)
        accountNumberTextField.textColor = UIColor.init(red:5/255.0, green:5/255.0, blue:5/255.0, alpha:1.0)
        routingNumberTextField.borderStyle = .RoundedRect
        accountNumberTextField.borderStyle = .RoundedRect
        
        routingNumberTextField.textAlignment = .Center
        accountNumberTextField.textAlignment = .Center
        routingNumberTextField.delegate = self
        accountNumberTextField.delegate = self
        routingNumberTextField.tag = 1
        accountNumberTextField.tag = 2
        
        routingNumberTextField.backgroundColor = UIColor.init(red:215/255.0, green:215/255.0, blue:215/255.0, alpha:1.0)
        accountNumberTextField.backgroundColor = UIColor.init(red:215/255.0, green:215/255.0, blue:215/255.0, alpha:1.0)
        
        
        self.view.addSubview(accountNumberTextField)
        self.view.addSubview(routingNumberTextField)

    }

    
    /** 
    Method that handles the cashing out OR adding bank account behavior of the bottom button
    */
    @IBAction func cashOutButtonPressed(sender: AnyObject) {
        if(self.isEnteringBankInfo && routingNumberTextField != nil && accountNumberTextField != nil) {
            if((routingNumberTextField.text.rangeOfString("^[0-9]{9,9}$", options: .RegularExpressionSearch)) != nil && (accountNumberTextField.text.rangeOfString("^[0-9]{12,12}$", options: .RegularExpressionSearch)) != nil) {
                SVProgressHUD.showWithStatus("Adding Bank Account")
                // 9 digit numbers for routing, 10 for account
                // make new stripe customer with banking info
                let completion : STPCompletionBlock = { [weak self] (token: STPToken!, error: NSError!) in
                    let wSelf = self
                    
                    if(error == nil) {
                        // call cloud function
                        let params = NSMutableDictionary()
                        params.setValue(token.tokenId, forKey: "token")
                        params.setValue(PFUser.currentUser().objectId, forKey: "userObjectId")
                        let block : (AnyObject!, NSError!) -> Void = {
                            (results: AnyObject!, error: NSError!) in
                            if(error == nil) {
                                SVProgressHUD.showSuccessWithStatus("Success!")
                                wSelf?.viewDidLoad()
                            } else {
                            }
                        }
                        PFCloud.callFunctionInBackground("addPaymentSource", withParameters:params as [NSObject : AnyObject], block: block)
                        
                    } else {
                        let alert = UIAlertView()
                        alert.title = "Invalid Bank Account Info"
                        alert.message = "Please try again."
                        alert.addButtonWithTitle("Ok")
                        alert.show()
                        SVProgressHUD.dismiss()
                    }
                    
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
            // need to credit the account
            var credits : String = PFUser.currentUser().objectForKey("credits") as! String
            SVProgressHUD.showProgress(20, status: "Cash out pressed")
            let params = NSMutableDictionary()
            params.setValue(credits, forKey: "credits")
            params.setValue(PFUser.currentUser().objectId, forKey: "userObjectId")
            let block : (AnyObject!, NSError!) -> Void = {
                (results: AnyObject!, error: NSError!) in
                SVProgressHUD.showProgress(80, status: "Server responded.")
                if(error == nil) {
                    SVProgressHUD.showSuccessWithStatus("Success!")
                } else {
                    SVProgressHUD.showErrorWithStatus("Bank Transfer Failed")
                }
            }
            
            PFCloud.callFunctionInBackground("startTransfer", withParameters:params as [NSObject : AnyObject], block: block)

            
        }
    }


}
