//
//  TTUser.swift
//  TenTags
//
//  Created by D on 11/26/15.
//  Copyright © 2015 EchoWaves. All rights reserved.
//

import Foundation


let TTUSER:TTUser = TTUser()
class TTUser: NSObject {
    let CLASS_NAME = "User"
    let hashTags = "hashTags" //: String
    
    
    
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

    class func createOrloginUser() {
//        clearStoredCredential()
        PFUser.logOut()
        let user = PFUser()
        
        var uuid = ""
        if getStoredCredential() != nil {
            uuid = (getStoredCredential()?.user)!
        } else {
            uuid = NSUUID().UUIDString
            storeCredential(uuid)
        }

        
        
        do {
            try PFUser.logInWithUsername(uuid, password: uuid)
        } catch {
            // login failed, let's create new user
            user.username = uuid
            user.password = uuid
            do {
                try user.signUp()
                TTHashTag.addHashTag("Local News")
                TTHashTag.addHashTag("Shopping")
                TTHashTag.addHashTag("Music")
                TTHashTag.addHashTag("Poetry")
                TTHashTag.addHashTag("Tech")
                TTHashTag.addHashTag("Food")
                try PFUser.logInWithUsername(uuid, password: uuid)
            } catch {
                NSLog("user sign up failed")
            }
        }
        
    }
    
    class func clearStoredCredential() -> Void  {
        //check if credentials are already stored, then show it in the tune in fields
        NSURLCredentialStorage.sharedCredentialStorage().removeCredential(getStoredCredential()!, forProtectionSpace: tenTagsProtectionSpace())
    }

    
}
