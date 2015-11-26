//
//  AddNewTagViewController.swift
//  TenTags
//
//  Created by D on 11/22/15.
//  Copyright © 2015 EchoWaves. All rights reserved.
//

import UIKit

class AddNewTagViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    
    @IBOutlet weak var autocompleteTableView: UITableView!
    var completions = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        textField.becomeFirstResponder()
        textField.delegate = self
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(
            self,
            selector: "textFieldTextChanged:",
            name:UITextFieldTextDidChangeNotification,
            object: textField
        )

        
        autocompleteTableView.hidden = true
        autocompleteTableView.delegate      =   self
        autocompleteTableView.dataSource    =   self

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
        let maxLength = 50
        let currentString: NSString = textField.text!
        let newString: NSString =
        currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxLength
    }

    
    func textFieldTextChanged(sender : AnyObject) {
        NSLog("searching for text: " + textField.text!); //the textView parameter is the textView where text was changed
        TTHashTag.autoComplete(textField.text!, succeeded: { (results) -> () in
            
            self.autocompleteTableView.hidden = false
            self.completions = results
            self.autocompleteTableView.reloadData()
            self.autocompleteTableView.reloadInputViews()
            
            }) { (error) -> () in
                NSLog("error autocompleting")
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.completions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = autocompleteTableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        cell.textLabel?.text = self.completions[indexPath.row]
        cell.textLabel?.textColor = UIColor(rgb: 0xff8000)
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        autocompleteTableView.hidden = true
        NSLog("You selected cell #\(self.completions[indexPath.row])!")
        textField.text = self.completions[indexPath.row]
    }
    

    
}

