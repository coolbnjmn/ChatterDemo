//
//  StripeCardViewController.swift
//  Chatter
//
//  Created by Benjamin Hendricks on 4/5/15.
//  Copyright (c) 2015 Eddy Borja. All rights reserved.
//

import UIKit


class StripeCardViewController: UIViewController, PTKViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Card"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        let yOffset : CGFloat? = self.navigationController?.navigationBar.frame.size.height
        let yOffset2 : CGFloat? = UIApplication.sharedApplication().statusBarFrame.size.height
        var stripeView = PTKView(frame: CGRectMake(0, yOffset!+yOffset2!+10, self.view.bounds.size.width, 55))
        let xOffset = (self.view.bounds.size.width - stripeView.bounds.size.width) / 2
        stripeView.frame = CGRectMake(xOffset, yOffset!+yOffset2!+10, 290, 55)
        stripeView.delegate = self
        self.view.addSubview(stripeView)
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

}
