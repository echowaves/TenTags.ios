//
//  ThemViewController.swift
//  TenTags
//
//  Created by D on 11/20/15.
//  Copyright © 2015 EchoWaves. All rights reserved.
//

import UIKit

class ThemViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func switchToMe(sender: AnyObject) {
        self.dismissViewControllerAnimated(false) { () -> Void in
            let meViewController = self.storyboard?.instantiateViewControllerWithIdentifier("meController") as! MeViewController
         
            if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.presentViewController(meViewController, animated: false, completion: nil)
            }
        }
        
    }
    
}

