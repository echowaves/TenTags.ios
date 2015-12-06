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
        UINavigationBar.appearance().barTintColor = UIColor(rgb: 0x00C333)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor();
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        
        Localytics.autoIntegrate("84b2b28bcbe2930bfe1058b-67f6f9d4-8ff4-11e5-cc4a-0013a62af900", launchOptions: launchOptions)
        
        setupParse()
        setupLayer()

        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        Fabric.with([Crashlytics()])

        
        // Register for push
        self.registerApplicationForPushNotifications(application)

        
        return true
    }
    
    func registerApplicationForPushNotifications(application: UIApplication) {
        // Set up push notifications
        // For more information about Push, check out:
        // https://developer.layer.com/docs/guides/ios#push-notification
        
        // Register device for iOS8
        let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
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
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Store the deviceToken in the current installation and save it to Parse.
        let currentInstallation: PFInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.saveInBackground()
        
        // Send device token to Layer so Layer can send pushes to this device.
        // For more information about Push, check out:
        // https://developer.layer.com/docs/ios/guides#push-notification
        assert(self.layerClient != nil, "The Layer client has not been initialized!")
        do {
            try self.layerClient.updateRemoteNotificationDeviceToken(deviceToken)
            print("Application did register for remote notifications: \(deviceToken)")
        } catch let error as NSError {
            print("Failed updating device token with error: \(error)")
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        if userInfo["layer"] == nil {
            PFPush.handlePush(userInfo)
            completionHandler(UIBackgroundFetchResult.NewData)
            return
        }
        
        let userTappedRemoteNotification: Bool = application.applicationState == UIApplicationState.Inactive
        var conversation: LYRConversation? = nil
        if userTappedRemoteNotification {
//            SVProgressHUD.show()
            conversation = self.conversationFromRemoteNotification(userInfo)
            if conversation != nil {
                self.navigateToViewForConversation(conversation!)
            }
        }
        
        let success: Bool = self.layerClient.synchronizeWithRemoteNotification(userInfo, completion: { (changes, error) in
            completionHandler(self.getBackgroundFetchResult(changes, error: error))
            
            if userTappedRemoteNotification && conversation == nil {
                // Try navigating once the synchronization completed
                self.navigateToViewForConversation(self.conversationFromRemoteNotification(userInfo))
            }
        })
        
        if !success {
            // This should not happen?
            completionHandler(UIBackgroundFetchResult.NoData)
        }
    }
    
    func getBackgroundFetchResult(changes: [AnyObject]!, error: NSError!) -> UIBackgroundFetchResult {
        if changes?.count > 0 {
            return UIBackgroundFetchResult.NewData
        }
        return error != nil ? UIBackgroundFetchResult.Failed : UIBackgroundFetchResult.NoData
    }
    
    func conversationFromRemoteNotification(remoteNotification: [NSObject : AnyObject]) -> LYRConversation {
        let layerMap = remoteNotification["layer"] as! [String: String]
        let conversationIdentifier = NSURL(string: layerMap["conversation_identifier"]!)
        return self.existingConversationForIdentifier(conversationIdentifier!)!
    }
    
    func navigateToViewForConversation(conversation: LYRConversation) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
//                SVProgressHUD.dismiss()
                let conversationViewController: ConversationViewController = ConversationViewController(layerClient: self.layerClient)
                //                    conversationViewController.displaysAddressBar = shouldShowAddressBar
                conversationViewController.conversation = conversation
                //                        conversationViewController.typingIndicatorController = ATLTypingIndicatorViewController()

                if (self.getCurrentViewController() as? ConversationViewController)?.conversation != conversation {
                    self.getNavigationController()?.pushViewController(conversationViewController, animated: true)
                }
            });
    }
    
    
    // Returns the most recently presented UIViewController (visible)
    func getCurrentViewController() -> UIViewController? {
        
        // If the root view is a navigation controller, we can just return the visible ViewController
        if let navigationController = getNavigationController() {
            
            return navigationController.visibleViewController
        }
        
        // Otherwise, we must get the root UIViewController and iterate through presented views
        if let rootController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            
            var currentController: UIViewController! = rootController
            
            // Each ViewController keeps track of the view it has presented, so we
            // can move from the head to the tail, which will always be the current view
            while( currentController.presentedViewController != nil ) {
                
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }

    // Returns the navigation controller if it exists
    func getNavigationController() -> UINavigationController? {
        
        if let navigationController = UIApplication.sharedApplication().keyWindow?.rootViewController  {
            return navigationController as? UINavigationController
        }
        return nil
    }
    
    func existingConversationForIdentifier(identifier: NSURL) -> LYRConversation? {
        let query: LYRQuery = LYRQuery(queryableClass: LYRConversation.self)
        query.predicate = LYRPredicate(property: "identifier", predicateOperator: LYRPredicateOperator.IsEqualTo, value: identifier)
        query.limit = 1
        do {
            return try self.layerClient.executeQuery(query).firstObject as? LYRConversation
        } catch {
            // This should never happen?
            return nil
        }
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
        layerClient.autodownloadMIMETypes = NSSet(objects: ATLMIMETypeImagePNG, ATLMIMETypeImageJPEG, ATLMIMETypeImageJPEGPreview, ATLMIMETypeImageGIF, ATLMIMETypeImageGIFPreview, ATLMIMETypeLocation) as! Set<NSObject>
    }

    
    
}


// http://codentrick.com/create-a-tag-flow-layout-with-uicollectionview/
// http://nshipster.com/core-location-in-ios-8/
// http://www.raywenderlich.com/87008/overlay-views-mapkit-swift-tutorial
// https://github.com/kwkhaw/Layer-Parse-iOS-Swift-Example
// https://github.com/layerhq/documentation/blob/master/ios/guides/advanced-querying.md
