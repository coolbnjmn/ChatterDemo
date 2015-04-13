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
            }
            
        })
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
        
        routingNumberTextField.font = UIFont(name: "Standard", size: 32)
        accountNumberTextField.font = UIFont(name: "Standard", size: 32)
        routingNumberTextField.borderStyle = .RoundedRect
        accountNumberTextField.borderStyle = .RoundedRect
        
        routingNumberTextField.textAlignment = .Center
        accountNumberTextField.textAlignment = .Center
        routingNumberTextField.delegate = self
        accountNumberTextField.delegate = self
        routingNumberTextField.tag = 1
        accountNumberTextField.tag = 2
        
        self.view.addSubview(accountNumberTextField)
        self.view.addSubview(routingNumberTextField)

    }

    @IBAction func cashOutButtonPressed(sender: AnyObject) {
        if(self.isEnteringBankInfo && routingNumberTextField != nil && accountNumberTextField != nil) {
            if((routingNumberTextField.text.rangeOfString("^[0-9]{10,10}$", options: .RegularExpressionSearch)) != nil && (accountNumberTextField.text.rangeOfString("^[0-9]{10,10}$", options: .RegularExpressionSearch)) != nil) {
                // 10 digit numbers for both
            } else if((routingNumberTextField.text.rangeOfString("^[0-9]{10,10}$", options: .RegularExpressionSearch)) != nil && (accountNumberTextField.text.rangeOfString("^[0-9]{10,10}$", options: .RegularExpressionSearch)) == nil) {
                let animation = CABasicAnimation(keyPath: "position")
                animation.duration = 0.07
                animation.repeatCount = 4
                animation.autoreverses = true
                animation.fromValue = NSValue(CGPoint: CGPointMake(accountNumberTextField.center.x - 10, accountNumberTextField.center.y))
                animation.toValue = NSValue(CGPoint: CGPointMake(accountNumberTextField.center.x + 10, accountNumberTextField.center.y))
                accountNumberTextField.layer.addAnimation(animation, forKey: "position")

                accountNumberTextField.backgroundColor = UIColor.redColor()
            } else if((routingNumberTextField.text.rangeOfString("^[0-9]{10,10}$", options: .RegularExpressionSearch)) == nil && (accountNumberTextField.text.rangeOfString("^[0-9]{10,10}$", options: .RegularExpressionSearch)) != nil) {
                let animation = CABasicAnimation(keyPath: "position")
                animation.duration = 0.07
                animation.repeatCount = 4
                animation.autoreverses = true
                animation.fromValue = NSValue(CGPoint: CGPointMake(routingNumberTextField.center.x - 10, routingNumberTextField.center.y))
                animation.toValue = NSValue(CGPoint: CGPointMake(routingNumberTextField.center.x + 10, routingNumberTextField.center.y))
                routingNumberTextField.layer.addAnimation(animation, forKey: "position")

                routingNumberTextField.backgroundColor = UIColor.redColor()
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
                
                routingNumberTextField.backgroundColor = UIColor.redColor()
                accountNumberTextField.backgroundColor = UIColor.redColor()
                
            }
   
        } else {
            println("cash out pressed")
            
        }
    }


}
