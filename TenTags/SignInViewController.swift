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
        
        let digitsButton = DGTAuthenticateButton(authenticationCompletion: { (session, error) in
            // Inspect session/error objects
        })
        self.view.addSubview(digitsButton)
        digitsButton.center = self.view.center
        
    }
    
}

