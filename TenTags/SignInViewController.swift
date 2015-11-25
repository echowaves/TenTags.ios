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
    
    @IBOutlet weak var verifyPhoneNumberButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    @IBAction func verifyPhoneNumberButtonClicked(sender: AnyObject) {
        verifyPhoneNumberButton.enabled = false
        let digits = Digits.sharedInstance()
        digits.authenticateWithCompletion { (session, error) in
            // Inspect session/error objects
            if(session != nil) {
                print("new session: \(session.description)")
                print("new session phone number: \(session.phoneNumber)")
                self.createOrloginUser(self, session: session)
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }
    
    func createOrloginUser(caller: UIViewController, session: DGTSession) {
        
        let user = PFUser()
        user.username = session.phoneNumber
        user.password = session.phoneNumber
        PFUser.logOut()
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo["error"] as? NSString
                // Show the errorString somewhere and let the user try again.
                print("error signing up: \(errorString!)")
            } else {
                // Hooray! Let them use the app now.
                print("sign up new user is successfull")
                //let's add some default tags here
                TTHashTag.addHashTag("Local News")
                TTHashTag.addHashTag("Shopping")
                TTHashTag.addHashTag("Music")
                TTHashTag.addHashTag("Poetry")
                TTHashTag.addHashTag("Tech")
                TTHashTag.addHashTag("Food")
            }
            //sign in the user
            PFUser.logInWithUsernameInBackground(session.phoneNumber, password:session.phoneNumber) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    // Do stuff after successful login.
                    print("signed in as: \(PFUser.currentUser()!.username!)")
                    // instantiate next view controller
                    //                    let navController = self.storyboard?.instantiateViewControllerWithIdentifier("navController") as! NavController
                    //
                    //                    if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                    //                        while let presentedViewController = topController.presentedViewController {
                    //                            topController = presentedViewController
                    //                        }
                    //                        topController.presentViewController(navController, animated: false, completion: nil)
                    //                    }
                    
                    let navController = self.storyboard?.instantiateViewControllerWithIdentifier("NavController") as! NavController
                    caller.presentViewController(navController, animated: true, completion: { () -> Void in
                        print("finished presenting navController")
                    })

                    
                } else {
                    // The login failed. Check error to see why.
                    print("signin in failed....")
                }
            }
        }
    }

}

