//
//  VerifyPhoneCodeViewController.swift
//  Chatter
//
//  Created by Benjamin Hendricks on 4/5/15.
//  Copyright (c) 2015 Eddy Borja. All rights reserved.
//

import UIKit
import Parse

class VerifyPhoneCodeViewController: UIViewController {

    @IBOutlet weak var verifyCodeTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func enterVerificationCode(sender: AnyObject) {
        var params : NSMutableDictionary = NSMutableDictionary()
        params.setValue(verifyCodeTextField.text, forKey: "phoneVerificationCode")
        let block : PFIdResultBlock = { (result: AnyObject!, error: NSError!) in
            if(error == nil) {
                // no error
                self.navigationController?.popToRootViewControllerAnimated(true)
            } else {
                // verification code was incorrect
            }
        }
        PFCloud.callFunctionInBackground("verifyPhoneNumber", withParameters: params, block: block)
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
