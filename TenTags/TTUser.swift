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
    
    
    
//    class func tenTagsProtectionSpace() -> (NSURLProtectionSpace) {
//        let url:NSURL = NSURL(string: "http://tentags.com")!
//        
//        
//        let protSpace =
//        NSURLProtectionSpace(
//            host: url.host!,
//            port: 80,
//            `protocol`: url.scheme,
//            realm: nil,
//            authenticationMethod: nil)
//        
//        println("prot space: \(protSpace)")
//        return protSpace
//    }
//    
//    class func storeCredential(waveName: String, wavePassword:String)  -> () {
//        let protSpace = EWWave.echowavesProtectionSpace()
//        
//        if let credentials: NSDictionary = NSURLCredentialStorage.sharedCredentialStorage().credentialsForProtectionSpace(protSpace) {
//            
//            //remove all credentials
//            for credentialKey in credentials {
//                let credential = (credentials.objectForKey(credentialKey.key) as NSURLCredential)
//                NSURLCredentialStorage.sharedCredentialStorage().removeCredential(credential, forProtectionSpace: protSpace)
//            }
//        }
//        //store new credential
//        let credential = NSURLCredential(user: waveName, password: wavePassword, persistence: NSURLCredentialPersistence.Permanent)
//        NSURLCredentialStorage.sharedCredentialStorage().setCredential(credential, forProtectionSpace: protSpace)
//        
//    }
//    
//    
//    class func getStoredCredential() -> (NSURLCredential?)  {
//        //check if credentials are already stored, then show it in the tune in fields
//        
//        if let credentials: NSDictionary? = NSURLCredentialStorage.sharedCredentialStorage().credentialsForProtectionSpace(EWWave.echowavesProtectionSpace()) {
//            return credentials?.objectEnumerator().nextObject() as NSURLCredential?
//        }
//        return nil
//    }
//
//    
    
}
