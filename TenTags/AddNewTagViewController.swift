//
//  AddNewTagViewController.swift
//  TenTags
//
//  Created by D on 11/22/15.
//  Copyright © 2015 EchoWaves. All rights reserved.
//

import UIKit

class AddNewTagViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
//        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
}

