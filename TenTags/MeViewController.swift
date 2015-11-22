//
//  MeViewController.swift
//  TenTags
//
//  Created by D on 11/20/15.
//  Copyright © 2015 EchoWaves. All rights reserved.
//

import UIKit

class MeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func switchToThem(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(false) { () -> Void in
            let themViewController = self.storyboard?.instantiateViewControllerWithIdentifier("themController") as! ThemViewController
            
            if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.presentViewController(themViewController, animated: false, completion: nil)
            }
        }
    }
}

