//
//  NavTabBarController.swift
//  
//
//  Created by D on 11/22/15.
//
//

import Foundation
import DigitsKit


class NavTabBarController : UITabBarController {
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let session = Digits.sharedInstance().session() {
            print("session established: \(session.description)")
            print("session established phone number: \(session.phoneNumber)")
            SignInViewController.createOrloginUser(session)
        } else {
            print("no session found, validating the device phone number")
            let signInViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SignInViewController") as! SignInViewController
            self.navigationController?.pushViewController(signInViewController, animated: false)
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

}