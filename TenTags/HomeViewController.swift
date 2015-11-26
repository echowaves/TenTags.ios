//
//  HomeViewController.swift
//  TenTags
//
//  Created by D on 11/24/15.
//  Copyright © 2015 EchoWaves. All rights reserved.
//

import UIKit
import DigitsKit

class HomeViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        Digits.sharedInstance().logOut()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let signInViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SignInViewController") as! SignInViewController
        
        // Do any additional setup after loading the view, typically from a nib.
        if let session = Digits.sharedInstance().session() {
            NSLog("session established: \(session.description)")
            NSLog("session established phone number: \(session.phoneNumber)")
            signInViewController.createOrloginUser(self, session: session)
        } else {
            NSLog("no session found, validating the device phone number")
            presentViewController(signInViewController, animated: true, completion: { () -> Void in
                NSLog("finished signing in")
            })
        }
    }

    
    
}

