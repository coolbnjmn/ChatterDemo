//
//  StripeCardViewController.swift
//  Chatter
//
//  Created by Benjamin Hendricks on 4/5/15.
//  Copyright (c) 2015 Eddy Borja. All rights reserved.
//

import UIKit
import Parse


class StripeCardViewController: UITableViewController, PTKViewDelegate {
    
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
        return cardsArray.count+1
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("creditCardCell", forIndexPath: indexPath) as! UITableViewCell
        
        if(indexPath.row == cardsArray.count) {
            let xOffset = (cell.bounds.size.width - 290) / 2
            stripeView = PTKView(frame: CGRectMake(xOffset, 20, 290, 55))
            stripeView.delegate = self
            cell.addSubview(stripeView)
            
//            var doneButton = UIButton(frame: CGRectMake(cell.bounds.size.width - 110, 80, 100, 25))
            var doneButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            doneButton.frame = CGRectMake(cell.bounds.size.width - 110, 80, 100, 25)
            doneButton.backgroundColor = UIColor.blueColor()
            doneButton.tintColor = UIColor.whiteColor()
            doneButton.titleLabel?.text = "Add Card"
            doneButton.titleLabel?.textAlignment = .Center
            doneButton.layer.borderWidth = 1.5
            doneButton.layer.borderColor = UIColor.blackColor().CGColor
            doneButton.layer.cornerRadius = 15
            doneButton.addTarget(self, action: "addCard:", forControlEvents: UIControlEvents.TouchUpInside)
//            doneButton.enabled = true
            
            cell.addSubview(doneButton)
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
    
    func addCard(sender: AnyObject) {
        println("addCard")
//        var params : NSMutableDictionary = NSMutableDictionary()
//        params.setValue(stripeView.card.number, forKey:"card_number")
//        params.setValue(stripeView.card.cvc, forKey: "card_cvc")
//        params.setValue(stripeView.card.expMonth, forKey: "card_exp_month")
//        params.setValue(stripeView.card.expYear, forKey: "card_exp_year")
//
//        
        let completion : STPCompletionBlock = { [weak self] (token: STPToken!, error: NSError!) in
            let wSelf = self
            if(error == nil) {
                var params : NSMutableDictionary = NSMutableDictionary()
                params.setValue(token.tokenId, forKey: "cardToken")
                params.setValue(PFUser.currentUser().objectId, forKey: "objectId")
                
                let block : PFIdResultBlock = { [weak self] (result: AnyObject!, error: NSError!) in
                    let wSelf = self
                    if(error == nil) {
                        // no error
                        var cardQuery = PFQuery(className: "Cards")
                        cardQuery.whereKey("user", equalTo: PFUser.currentUser())
                        cardQuery.findObjectsInBackgroundWithBlock({ (NSArray array, NSError error) -> Void in
                            println(array.count)
                            wSelf!.cardsArray = NSMutableArray(array:array)
                            
                            wSelf!.tableView.reloadData()
                            
                            
                        })
                    } else {
                        // verification code was incorrect
                    }
                }
                PFCloud.callFunctionInBackground("saveCardInformation", withParameters: params as [NSObject : AnyObject], block: block)
            } else {
                println("uh oh")
                println(error)
            }
            
        }
        
        let stpcard : STPCard = STPCard()
        stpcard.number = stripeView.card.number
        stpcard.expMonth = stripeView.card.expMonth
        stpcard.expYear = stripeView.card.expYear
        stpcard.cvc = stripeView.card.cvc
        
        println(stpcard.number)
        STPAPIClient.sharedClient().createTokenWithCard(stpcard, completion:completion)

        
//        let block : PFIdResultBlock = { [weak self] (result: AnyObject!, error: NSError!) in
//            let wSelf = self
//            if(error == nil) {
//                // no error
//                var cardQuery = PFQuery(className: "Cards")
//                cardQuery.whereKey("user", equalTo: PFUser.currentUser())
//                cardQuery.findObjectsInBackgroundWithBlock({ (NSArray array, NSError error) -> Void in
//                    println(array.count)
//                    wSelf!.cardsArray = NSMutableArray(array:array)
//                    
//                    wSelf!.tableView.reloadData()
//
//                    
//                })
//            } else {
//                // verification code was incorrect
//            }
//        }
//        PFCloud.callFunctionInBackground("addCreditCard", withParameters: params, block: block)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
