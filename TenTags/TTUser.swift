//
//  TTUser.swift
//  TenTags
//
//  Created by D on 11/26/15.
//  Copyright © 2015 EchoWaves. All rights reserved.
//

import Foundation
import Parse


let TTUSER:TTUser = TTUser()
class TTUser: NSObject {
    let CLASS_NAME = "User"
    let hashTags = "hashTags" //: String
    let location = "location" //PFGeoPint
    
    
    
    class func tenTagsProtectionSpace() -> (NSURLProtectionSpace) {
        let url:NSURL = NSURL(string: "http://tentags.com")!
        
        
        let protSpace =
        NSURLProtectionSpace(
            host: url.host!,
            port: 80,
            `protocol`: url.scheme,
            realm: nil,
            authenticationMethod: nil)
        
        print("prot space: \(protSpace)")
        return protSpace
    }
    
    class func storeCredential(uuid:String)  -> () {
        let protSpace = TTUser.tenTagsProtectionSpace()
        
        if let credentials: NSDictionary = NSURLCredentialStorage.sharedCredentialStorage().credentialsForProtectionSpace(protSpace) {
            
            //remove all credentials
            for credentialKey in credentials {
                let credential = (credentials.objectForKey(credentialKey.key) as! NSURLCredential)
                NSURLCredentialStorage.sharedCredentialStorage().removeCredential(credential, forProtectionSpace: protSpace)
            }
        }
        //store new credential
        let credential = NSURLCredential(user: uuid, password: uuid, persistence: NSURLCredentialPersistence.Permanent)
        NSURLCredentialStorage.sharedCredentialStorage().setCredential(credential, forProtectionSpace: protSpace)
    }
    
    
    class func getStoredCredential() -> (NSURLCredential?)  {
        //check if credentials are already stored, then show it in the tune in fields
        
        if let credentials: NSDictionary? = NSURLCredentialStorage.sharedCredentialStorage().credentialsForProtectionSpace(TTUser.tenTagsProtectionSpace()) {
            return credentials?.objectEnumerator().nextObject() as! NSURLCredential?
        }
        return nil
    }

    
    class func createOrloginUser(
        success:(user:PFUser) -> (),
        failed:(error: NSError?) -> ()
        ) -> () {
            PFUser.logOut()
            
            var uuid = ""
            if getStoredCredential() != nil {
                uuid = (getStoredCredential()?.user)!
            } else {
                uuid = NSUUID().UUIDString
                storeCredential(uuid)
            }
            
            let newUser = PFUser()
            newUser.username = uuid
            newUser.password = uuid
            newUser.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
                if succeeded == true {
                    TTHashTag.addHashTag("Local News")
                    TTHashTag.addHashTag("Shopping")
                    TTHashTag.addHashTag("Music")
                    TTHashTag.addHashTag("Poetry")
                    TTHashTag.addHashTag("Tech")
                    TTHashTag.addHashTag("Food")
                    PFUser.logInWithUsernameInBackground(uuid, password: uuid)
                    success(user: newUser)
                } else {
                    PFUser.logInWithUsernameInBackground(uuid, password: uuid) { (user:PFUser?, error:NSError?) -> Void in
                        if error == nil && user != nil {
                            success(user: user!)
                        } else {
                            failed(error: error)
                        }
                    }
                }
            }
    }
    
    class func clearStoredCredential() -> Void  {
        //check if credentials are already stored, then show it in the tune in fields
        NSURLCredentialStorage.sharedCredentialStorage().removeCredential(getStoredCredential()!, forProtectionSpace: tenTagsProtectionSpace())
    }
    
    
    class func searchUsersWithMatchingTagsCloseBy(
        succeeded:(results:[PFUser]) -> (),
        failed:(error: NSError!) -> ()
        ) -> () {
            
            var subQueries = [PFQuery]()
            
            let TAGS = PFUser.currentUser()?[TTUSER.hashTags] as? NSArray
            for tag in TAGS! {
                let subQuery = PFUser.query()!.whereKey(TTUSER.hashTags, equalTo: tag)
                subQueries.append(subQuery)
                NSLog("key query: \(tag)")
            }
            
            // User's location
            let userGeoPoint = PFUser.currentUser()?[TTUSER.location] as? PFGeoPoint
            // Create a query for places
            let mainQuery = PFQuery.orQueryWithSubqueries(subQueries)
            // Interested in locations near user.
            mainQuery.whereKey(TTUSER.location, nearGeoPoint: userGeoPoint!)
            
            // Limit what could be a lot of points.
            mainQuery.limit = 100
            
            // Final list of objects
            mainQuery.findObjectsInBackgroundWithBlock {
                (results: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    // results contains players with lots of wins or only a few wins.
                    NSLog("!!!!!!!!!!!!!!!!!! found \(results!.count) matching users nearby")
                    succeeded(results: (results as? [PFUser])!)
                } else {
                    failed(error: error)
                }
            }
    }
    
}
