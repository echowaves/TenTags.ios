//
//  SignInViewController.swift
//  TenTags
//
//  Created by D on 11/21/15.
//  Copyright © 2015 EchoWaves. All rights reserved.
//

import UIKit
import DigitsKit

class SignInViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let session = Digits.sharedInstance().session() {
            print("session established: \(session.description)")
        } else {
            print("no session found")
        }
        
    }
    
    @IBAction func verifyPhoneNumberButtonClicked(sender: AnyObject) {
        let digits = Digits.sharedInstance()
        digits.authenticateWithCompletion { (session, error) in
            // Inspect session/error objects
            print("new session: \(session)")
        }
    }
}

