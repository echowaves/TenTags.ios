//
//  TTHashTag.swift
//  TenTags
//
//  Created by D on 11/23/15.
//  Copyright © 2015 EchoWaves. All rights reserved.
//

import Foundation

let TTHASHTAG:TTHashTag = TTHashTag()
class TTHashTag: NSObject {
    let CLASS_NAME = "HashTag"
    let hashTag = "hashTag" //: String
    
    
    class func addHashTag(var hashTagString: String) -> () {
        hashTagString = hashTagString.lowercaseString
        PFUser.currentUser()?.addUniqueObject(hashTagString, forKey:"hashTags" )
        PFUser.currentUser()?.saveInBackgroundWithBlock({ (success:Bool, error: NSError?) -> Void in
            if success == true {
                let hashTag = PFObject(className: TTHASHTAG.CLASS_NAME)
                hashTag[TTHASHTAG.hashTag] = hashTagString
                hashTag.saveInBackground()
            }
        })
    }
    
    class func autoComplete(
        var searchText: String,
        succeeded:(results:[String]) -> (),
        failed:(error: NSError!) -> ()
        ) -> () {
            searchText = searchText.lowercaseString

            let queryTag = PFQuery(className:TTHASHTAG.CLASS_NAME)
            queryTag.whereKey(TTHASHTAG.hashTag, hasPrefix:searchText)
            // Limit what could be a lot of points.
            queryTag.limit = 10
//            queryTag.orderByAscending(TTHASHTAG.hashTag)
            
            queryTag.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    // The find succeeded.
                    // Do something with the found objects
                    
                    NSLog("results: \(objects!.count)")
                    let alltags = objects?.map{$0[TTHASHTAG.hashTag]!}
                    var hashTags:Set<String> = Set<String>()
                    var orderedResults:[String] = [String]()
                    for tag in alltags! {
                        hashTags.insert(tag as! String)
                    }
                    for tag in hashTags.sort() {
                        orderedResults.append(tag)
                    }
                    succeeded(results: orderedResults)
                } else {
                    // Log details of the failure
                    failed(error: error)
                }
            }
    }
    
}
