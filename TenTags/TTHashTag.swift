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
        do {
            PFUser.currentUser()?.addUniqueObject(hashTagString, forKey:"hashTags" )
            try PFUser.currentUser()?.save()
        } catch {
            print("Error saving hasTag to the user")
        }
        //just add to tags table, we will check for duplicates in beforesave.
        do {
            let hashTag = PFObject(className: TTHASHTAG.CLASS_NAME)
            hashTag[TTHASHTAG.hashTag] = hashTagString
            try hashTag.save()
        } catch {
            print("Error saving new hastag")
        }
        
    }

    
//    class func autoComplete(
//        location: PFGeoPoint,
//        searchText: String,
//        succeeded:(results:[String]) -> (),
//        failed:(error: NSError!) -> ()
//        ) -> () {
//            let queryPost = PFQuery(className:PJPOST.CLASS_NAME)
//            // Interested in locations near user.
//            queryPost.whereKey(PJPOST.location, nearGeoPoint:location)
//            queryPost.whereKey(PJPOST.active, equalTo:true)
//            queryPost.whereKey(PJPOST.archived, equalTo:false)
//            queryPost.whereKey(PJPOST.createdBy, notEqualTo: PFUser.currentUser()!.objectId!)  //TODO: uncomment
//            NSLog("Searching for string \(searchText)")
//            
//            
//            let queryTag = PFQuery(className:PJHASHTAG.CLASS_NAME)
//            queryTag.whereKey(PJHASHTAG.post, matchesQuery:queryPost)
//            queryTag.whereKey(PJHASHTAG.hashTag, hasPrefix: searchText)
//            // Limit what could be a lot of points.
//            queryTag.limit = 100
//            // Final list of objects
//            //                self.postsNearMe =
//            
//            queryTag.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
//                if error == nil {
//                    // The find succeeded.
//                    // Do something with the found objects
//                    
//                    NSLog("results: \(objects!.count)")
//                    let alltags = (objects as! [PFObject]).map{$0[PJHASHTAG.hashTag]!}
//                    var hashTags:Set<String> = Set<String>()
//                    var orderedResults:[String] = [String]()
//                    for tag in alltags {
//                        hashTags.insert(tag as! String)
//                    }
//                    for tag in hashTags.sort() {
//                        orderedResults.append(tag)
//                    }
//                    
//                    succeeded(results: orderedResults)
//                } else {
//                    // Log details of the failure
//                    failed(error: error)
//                }
//            })
//    }
    
//    class func loadTagsForPost(post:PFObject)-> ([PFObject]) {
//        let query = PFQuery(className:PJHASHTAG.CLASS_NAME)
//        query.whereKey(PJHASHTAG.post, equalTo:post)
//        query.orderByAscending(PJHASHTAG.hashTag)
//        return query.findObjects() as! [PFObject]
//    }
//    
//    class func loadTagsForPostInBackground(post:PFObject,
//        succeeded:(hashTags:[PFObject]) -> (),
//        failed:(error: NSError!) -> ()
//        ) {
//            let query = PFQuery(className:PJHASHTAG.CLASS_NAME)
//            query.whereKey(PJHASHTAG.post, equalTo:post)
//            query.orderByAscending(PJHASHTAG.hashTag)
//            query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
//                if error == nil {
//                    succeeded(hashTags: objects as! [PFObject])
//                } else {
//                    // Log details of the failure
//                    failed(error: error)
//                }
//            })
//    }

    

}
