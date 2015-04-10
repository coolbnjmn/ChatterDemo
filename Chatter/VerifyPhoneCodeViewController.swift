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
    @IBOutlet weak var doneButton: UIButton!
    
    @IBAction func finishVerification(sender: AnyObject) {
        self.enterVerificationCode(sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        verifyCodeTextField.keyboardType = UIKeyboardType.NumberPad
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
                var defaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(true,  forKey:"phoneVerified")
                self.navigationController?.popToRootViewControllerAnimated(true)
            } else {
                // verification code was incorrect
            }
        }
        PFCloud.callFunctionInBackground("verifyPhoneNumber", withParameters: params as [NSObject : AnyObject], block: block)
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
