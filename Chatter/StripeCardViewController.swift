//
//  StripeCardViewController.swift
//  Chatter
//
//  Copyright (c) 2015 Eddy Borja. All rights reserved.
//

import UIKit
import Parse


class StripeCardViewController: UITableViewController, PTKViewDelegate, UITextFieldDelegate {
    let textFieldHeight : CGFloat = 40
    var cardsArray : NSMutableArray = NSMutableArray()
    var stripeView : PTKView = PTKView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Card"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        var cardQuery = PFQuery(className: "Cards")
        cardQuery.whereKey("user", equalTo: PFUser.currentUser())
        cardQuery.findObjectsInBackgroundWithBlock({ (NSArray array, NSError error) -> Void in
                println(array.count)
        
        })
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "addCard:")
        
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "creditCardCell")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return cardsArray.count+2
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("creditCardCell", forIndexPath: indexPath) as! UITableViewCell
        
        if(indexPath.row == cardsArray.count) {
            let xOffset = (cell.bounds.size.width - 290) / 2
            stripeView = PTKView(frame: CGRectMake(xOffset, 20, 290, 55))
            stripeView.delegate = self
            cell.addSubview(stripeView)
        } else if(indexPath.row == cardsArray.count+1) {
            cell.frame.size.height = textFieldHeight * 3
            let routingNumberTextField = UITextField(frame: CGRectMake(0, 0, cell.bounds.size.width, textFieldHeight))
            let accountNumberTextField = UITextField(frame: CGRectMake(0, textFieldHeight, cell.bounds.size.width, textFieldHeight))
            routingNumberTextField.placeholder = "Routing Number"
            accountNumberTextField.placeholder = "Account Number"
            routingNumberTextField.keyboardType = UIKeyboardType.NumberPad
            accountNumberTextField.keyboardType = UIKeyboardType.NumberPad
            
            routingNumberTextField.borderStyle = .RoundedRect
            accountNumberTextField.borderStyle = .RoundedRect
            
            routingNumberTextField.textAlignment = .Center
            accountNumberTextField.textAlignment = .Center
            routingNumberTextField.delegate = self
            accountNumberTextField.delegate = self
            routingNumberTextField.tag = 1
            accountNumberTextField.tag = 2
            
            let doneButton = UIButton(frame: CGRectMake(0, textFieldHeight*2, cell.bounds.size.width, textFieldHeight))
            doneButton.backgroundColor = UIColor.redColor()
            doneButton.titleLabel?.textAlignment = .Center
            doneButton.setTitle("Submit Banking Information -- This won't leave your device", forState: UIControlState.allZeros)
            doneButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            doneButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)

            doneButton.addTarget(self, action: "submitBanking:", forControlEvents: .TouchUpInside)
            cell.addSubview(doneButton)
            cell.addSubview(routingNumberTextField)
            cell.addSubview(accountNumberTextField)
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated:true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func submitBanking(sender: AnyObject) {
        println("submit banking")
    }
    func addCard(sender: AnyObject) {
        println("addCard")
        let card : PTKCard = stripeView.card
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
                    } else {
                        println(error)
                    }
                    println("********")
                }
                PFCloud.callFunctionInBackground("addCard", withParameters:params as [NSObject : AnyObject], block: block)
                
            } else {
                print(error)
            }
            println("#######")

        }
        var finalCard : STPCard = STPCard()
        finalCard.number = card.number
        finalCard.expMonth = card.expMonth
        finalCard.expYear = card.expYear
        finalCard.cvc = card.cvc
        STPAPIClient.sharedClient().createTokenWithCard(finalCard, completion:completion)

    }

    func paymentView(paymentView: PTKView!, withCard card: PTKCard!, isValid valid: Bool) {
        println("changing validity of button")
        self.navigationItem.rightBarButtonItem?.enabled = valid
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        let text : String! = textField.text
        if(textField.tag == 1) { // routing number
            if((text.rangeOfString("^[0-9]{10,10}$", options: .RegularExpressionSearch)) != nil) {
                // match
                println("regex match for routing number")
                return true
            }
        } else if(textField.tag == 2) { // account number
            if((text.rangeOfString("^[0-9]{10,10}$", options: .RegularExpressionSearch)) != nil) {
                // match
                println("regex match for account number")
                return true
            }
        }
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(textField.center.x - 10, textField.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(textField.center.x + 10, textField.center.y))
        textField.layer.addAnimation(animation, forKey: "position")
        return false
    }


}
