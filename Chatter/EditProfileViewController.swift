//
//  EditProfileViewController.swift
//  Chatter
//
//  Created by Benjamin Hendricks on 4/5/15.
//  Copyright (c) 2015 Eddy Borja. All rights reserved.
//

import UIKit
import Parse


class EditProfileViewController: UITableViewController {

    let categoriesArray : NSArray = NSArray(objects: "First Name", "Last Name", "Email", "User Name", "About", "Gender", "Phone #")
    let categoriesKeys : NSArray = NSArray(objects: "first_name", "last_name", "email", "username", "about", "gender", "phone_number")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        var saveEditsButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "saveEdits:")
        self.navigationItem.rightBarButtonItem = saveEditsButton
        
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
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
        return categoriesArray.count
    
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("editProfileCell", forIndexPath: indexPath) as EditProfileCell

        // Configure the cell...
        cell.titleLabel?.text = categoriesArray.objectAtIndex(indexPath.row) as String
        
        var detailText : String = ""
        
        detailText = (PFUser.currentUser().objectForKey(categoriesKeys.objectAtIndex(indexPath.row) as String) != nil ? PFUser.currentUser().objectForKey(categoriesKeys.objectAtIndex(indexPath.row) as String) as String : "")

        cell.detailTextField?.placeholder = detailText
        
        return cell
    }

    func saveEdits(sender: AnyObject) {
        
        var phoneNumber = ""
        for(var i = 0; i < categoriesKeys.count; i++) {
            var myIndexPath = NSIndexPath(forRow: i, inSection: 0)
            var detailText = (self.tableView.cellForRowAtIndexPath(myIndexPath) as EditProfileCell).detailTextField.text
            if (detailText != nil && detailText != "") {
                println(detailText)
                if(categoriesKeys[i] as NSString == "phone_number") {
                    phoneNumber = detailText
                }
                PFUser.currentUser().setObject(detailText, forKey: (categoriesKeys.objectAtIndex(i) as String))
            }
        }
      
        
        let defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        let phoneVerified = defaults.boolForKey("phoneVerified")
        if(!phoneVerified) {
            var params : NSMutableDictionary = NSMutableDictionary()
            params.setValue(phoneNumber, forKey: "phoneNumber")

            let block : PFIdResultBlock = { [weak self] (result: AnyObject!, error: NSError!) in
                let wSelf = self
                if(error == nil) {
                    // no error
                    wSelf?.performSegueWithIdentifier("checkVerificationCode", sender: wSelf)
                } else {
                    // verification code was incorrect
                }
            }
            PFCloud.callFunctionInBackground("sendVerificationCode", withParameters: params, block: block)
        } else {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        PFUser.currentUser().saveInBackgroundWithBlock(nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
