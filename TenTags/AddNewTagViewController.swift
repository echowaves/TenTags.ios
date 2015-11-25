//
//  AddNewTagViewController.swift
//  TenTags
//
//  Created by D on 11/22/15.
//  Copyright © 2015 EchoWaves. All rights reserved.
//

import UIKit

class AddNewTagViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        textField.becomeFirstResponder()
        textField.delegate = self
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
//        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        if (textField.text != nil && textField.text!.characters.count > 0) {
            TTHashTag.addHashTag(textField.text!)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool
    {
        let maxLength = 30
        let currentString: NSString = textField.text!
        let newString: NSString =
        currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxLength
    }

}

