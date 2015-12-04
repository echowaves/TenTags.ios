//
//  AppDelegate.swift
//  TenTags
//
//  Created by D on 11/20/15.
//  Copyright © 2015 EchoWaves. All rights reserved.
//

import UIKit
//import Parse
//import Bolts
import Fabric
import Crashlytics
//import TwitterCore
//import DigitsKit
//import TwitterKit
import Parse
import Atlas
//import SVProgressHUD




let LayerAppIDString: NSURL! = NSURL(string: "layer:///apps/staging/010170ac-978a-11e5-b517-3a8a16005a40")
let ParseAppIDString: String = "zoYLGIcwju9NnQJxX6Kg4zV839tdwHCc2qNWKQGu"
let ParseClientKeyString: String = "CduodgMDs0LjI5BnqdMRzxa5miXCkQmHhMTNDbsp"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var layerClient: LYRClient!
    

    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        
        //Set bar appearance
        UINavigationBar.appearance().barTintColor = UIColor(rgb: 0xFFA500)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor();
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        
        Localytics.autoIntegrate("84b2b28bcbe2930bfe1058b-67f6f9d4-8ff4-11e5-cc4a-0013a62af900", launchOptions: launchOptions)
        
        setupParse()
        setupLayer()

        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        Fabric.with([Crashlytics()])

        return true
    }
    
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    func setupParse() {
        // Enable Parse local data store for user persistence
        Parse.enableLocalDatastore()
        Parse.setApplicationId(ParseAppIDString, clientKey: ParseClientKeyString)
        
        // Set default ACLs
//        let defaultACL: PFACL = PFACL()
//        defaultACL.setPublicReadAccess(true)
//        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser: true)
    }
    
    func setupLayer() {
        layerClient = LYRClient(appID: LayerAppIDString)
        layerClient.autodownloadMIMETypes = NSSet(objects: ATLMIMETypeImagePNG, ATLMIMETypeImageJPEG, ATLMIMETypeImageJPEGPreview, ATLMIMETypeImageGIF, ATLMIMETypeImageGIFPreview, ATLMIMETypeLocation) as Set<NSObject>
    }

    
    
}


// http://codentrick.com/create-a-tag-flow-layout-with-uicollectionview/
// http://nshipster.com/core-location-in-ios-8/
// http://www.raywenderlich.com/87008/overlay-views-mapkit-swift-tutorial
// https://github.com/kwkhaw/Layer-Parse-iOS-Swift-Example