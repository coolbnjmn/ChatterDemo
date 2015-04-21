//
//  AddCreditTableViewController.swift
//  Chatter
//
//  Created by Benjamin Hendricks on 4/18/15.
//  Copyright (c) 2015 Eddy Borja. All rights reserved.
//

import UIKit
import StoreKit
import Parse


class AddCreditTableViewController: UITableViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    var currentValidProducts : [AnyObject]!

    let productIDArray: [AnyObject!] = ["10_credits", "55_credits", "110_credits", "270_credits", "530_credits"]
    let productIDValue: [String] = ["10", "55", "110", "270", "530"]
    let productIDPrice: [String] = ["0.99", "4.99", "9.99", "19.99", "39.99"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        if (SKPaymentQueue.canMakePayments())
        {
            
            var productID:NSSet = NSSet(array: productIDArray)
            
            var productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as Set<NSObject>);
            productsRequest.delegate = self;
            productsRequest.start();
            println("Fething Products");
        } else {
            println("can not make purchases");
        }
        
        let titleDict: NSMutableDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        titleDict.setObject(UIFont(name: "MyriadPro-Regular", size:20)!, forKey:NSFontAttributeName)

        self.navigationController!.navigationBar.titleTextAttributes = titleDict as [NSObject : AnyObject]
        
        self.navigationItem.title = "Purchase Credits"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.productIDArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("addCreditCell", forIndexPath: indexPath) as! UITableViewCell
        var row = indexPath.row as Int
        var buyButtonWidth :CGFloat = 80
        var buyButtonOffset : CGFloat = 20
        let buyButton : UIButton = UIButton(frame: CGRectMake(cell.frame.size.width - buyButtonWidth - buyButtonOffset, buyButtonOffset, buyButtonWidth, cell.frame.size.height - 2*buyButtonOffset))
        let titleFont = UIFont(name: "MyriadPro-Regular", size:24)
        let detailFont = UIFont(name: "MyriadPro-Regular", size:18)
        buyButton.titleLabel?.font = titleFont
        buyButton.setTitle("Buy", forState: .allZeros)
        buyButton.backgroundColor = UIColor.init(red:75/255.0, green:193/255.0, blue:210/255.0, alpha:1.0)
        buyButton.layer.cornerRadius = 5
        buyButton.titleLabel?.textColor = UIColor.whiteColor()
        buyButton.tag = indexPath.row
        buyButton.addTarget(self, action: "buyButtonPressed:", forControlEvents: .TouchUpInside)
        
        cell.textLabel?.text = self.productIDValue[row] + " Credits"
        cell.detailTextLabel?.text = "$" + self.productIDPrice[row]
        cell.accessoryView = buyButton
        cell.textLabel?.font = titleFont
        cell.detailTextLabel?.textColor = UIColor.grayColor()
        cell.detailTextLabel?.font = detailFont
        return cell
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 110
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView : UIView = UIView(frame: CGRectMake(0,0,self.view.bounds.size.width, 110))
        
        let labelOffset : CGFloat = 40
        let heightOffset : CGFloat = 10
        let whatIsLabel : UILabel = UILabel(frame: CGRectMake(labelOffset,heightOffset, self.view.bounds.size.width - 2*labelOffset, 40))
        whatIsLabel.text = "What is Chatter Credit?"
        whatIsLabel.numberOfLines = 1
        whatIsLabel.font = UIFont(name: "MyriadPro-Regular", size: 26)
        whatIsLabel.textAlignment = .Center
        
        headerView.addSubview(whatIsLabel)
        
        let explainLabel : UILabel = UILabel(frame: CGRectMake(labelOffset, 40+heightOffset, self.view.bounds.size.width - 2*labelOffset, 60))
        explainLabel.text = "Chatter credits allow you to bid on chat sessions"
        explainLabel.numberOfLines = 2
        explainLabel.textColor = UIColor.grayColor()
        explainLabel.font = UIFont(name: "MyriadPro-Regular", size: 22)
        explainLabel.textAlignment = .Center
        
        headerView.addSubview(explainLabel)
        headerView.backgroundColor = UIColor.whiteColor()
        return headerView
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func buyProduct(product: SKProduct){
        println("Sending the Payment Request to Apple");
        var payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment);
        
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
//            let productHeight : CGFloat = 40
//            let productOffset : CGFloat = 10
//            let floatCount : CGFloat = CGFloat(count)
//            let iapViewHeight : CGFloat = (productHeight * floatCount) + (productOffset * (floatCount+1))
            var validProducts = response.products
//            iapView = UIView(frame: CGRectMake( (self.view.bounds.size.width - self.view.bounds.size.width/2)/2, (self.view.bounds.size.height - iapViewHeight)/2, self.view.bounds.size.width/2,iapViewHeight))
//            
//            iapView.backgroundColor = UIColor.init(red:14/255.0, green: 14/255.0, blue: 14/255.0, alpha: 1.0)
//            iapView.layer.cornerRadius = 5
//            
//            
            validProducts.sort(isOrderedBefore)
            currentValidProducts = validProducts
//
//            for(var i = 0; i < validProducts.count; i++) {
//                println(validProducts[i])
//                println(validProducts[i].localizedTitle)
//                var iapItemButton = UIButton(frame: CGRectMake(productOffset,CGFloat(productHeight*CGFloat(i)+productOffset*CGFloat(i+1)),self.view.bounds.size.width/2 - productOffset * 2,productHeight))
//                iapItemButton.layer.cornerRadius = 5
//                iapItemButton.backgroundColor = UIColor.init(red: 0, green: 104/255.0, blue: 174/255.0, alpha: 1.0)
//                iapItemButton.setTitle(validProducts[i].localizedTitle, forState:.Normal)
//                iapItemButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//                iapItemButton.setTitleColor(UIColor.blueColor(), forState: .Selected)
//                iapItemButton.titleLabel!.font = UIFont.init(name: "MyriadPro-Regular", size: 22)
//                iapItemButton.addTarget(self, action: "iapItemPressed:", forControlEvents: .TouchUpInside)
//                iapItemButton.tag = i
//                iapView.addSubview(iapItemButton)
//                
//            }
//            
//            iapButton = UIButton(frame: CGRectMake(0,0,self.view.bounds.size.width, self.view.bounds.size.height))
//            iapButton.backgroundColor = UIColor.clearColor()
//            self.view.addSubview(iapView)
//            self.view.insertSubview(iapButton, belowSubview: iapView)
//            
//            iapButton.addTarget(self, action: "dismissIAP:", forControlEvents: .TouchUpInside)
//            
//            
            
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
                    
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                    
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
    
    func buyButtonPressed(sender: AnyObject) {
        var senderButton : UIButton = sender as! UIButton
        var tag : Int = senderButton.tag
        
        let alertTitle : String = self.productIDValue[tag] + " Credits"
        let alertMessage : String = "Buy " + self.productIDValue[tag] + " Chatter Credits"
        
        let alertAction : String = "Buy this for $" + self.productIDPrice[tag]
        
        var alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: alertAction, style: .Default, handler: { action in
            switch action.style{
            case .Default:
                println("default")
                self.buyProduct(self.currentValidProducts[tag] as! SKProduct)
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))

        self.presentViewController(alert, animated: true, completion: nil)
        
    }


}
