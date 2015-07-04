//
//  AcceptTermsViewController.swift
//  Chatter
//
//  Created by Benjamin Hendricks on 7/4/15.
//  Copyright (c) 2015 Eddy Borja. All rights reserved.
//

import UIKit

class AcceptTermsViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var acceptButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let url : NSURL = NSURL(string: "http://chatterapp.parseapp.com/")!;
        let urlRequest : NSURLRequest = NSURLRequest(URL: url);
        self.webView.scalesPageToFit = true;
        self.webView.loadRequest(urlRequest);
        self.navigationItem.title = "Accept Terms of Use"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func acceptButtonPressed(sender: AnyObject) {
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true,  forKey:"acceptedTerms")
        self.navigationController?.popToRootViewControllerAnimated(true)

    }
}
