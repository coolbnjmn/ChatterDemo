//
//  VerifyPhoneCodeViewController.swift
//  Chatter
//
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
            let wSelf = self
            if(error == nil) {
                // no error
                var defaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(true,  forKey:"phoneVerified")
//                self.navigationController?.popToRootViewControllerAnimated(true)
                wSelf.performSegueWithIdentifier("acceptTerms", sender: wSelf)

            } else {
                // verification code was incorrect
            }
        }
        PFCloud.callFunctionInBackground("verifyPhoneNumber", withParameters: params as [NSObject : AnyObject], block: block)
    }

}
