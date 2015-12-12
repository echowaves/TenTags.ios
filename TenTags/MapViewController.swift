//
//  ThemViewController.swift
//  TenTags
//
//  Created by D on 11/20/15.
//  Copyright © 2015 EchoWaves. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse
//import SVProgressHUD


class MapViewController: UIViewController, CLLocationManagerDelegate {
    let APP_DELEGATE:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    
    var timer:NSTimer?
    var layerClient: LYRClient!

    @IBOutlet weak var converstaionsButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!

    var currentAnnotation = TTAnnotation(coordinate: CLLocationCoordinate2D(), title: "", subtitle: "", type: .Me, user: PFUser.currentUser())

    var allAnnotations = [TTAnnotation]()
    
    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        return manager
    }()
    
    @IBAction func conversationsButtonClicked(sender: AnyObject) {
        self.presentConversationListViewController()
    }
    
    @IBAction func centerMapAction(sender: AnyObject) {
        self.centerMap()
    }


    func presentConversationListViewController() {
        let conversationListViewController: ConversationListViewController! = ConversationListViewController(layerClient: self.layerClient)
//        conversationListViewController.displaysAvatarItem = true
        conversationListViewController.allowsEditing = false
        conversationListViewController.shouldDisplaySearchController = false
        self.navigationController!.pushViewController(conversationListViewController, animated: true)
    }


    func updateUnreadMessageCount() {
        
        // Fetches the count of all unread messages for the authenticated user
        let query:LYRQuery! = LYRQuery(queryableClass: LYRMessage.self)
    
        // Messages must be unread
        let unreadPredicate:LYRPredicate! = LYRPredicate(property: "isUnread", predicateOperator: LYRPredicateOperator.IsEqualTo, value: true)
        
        // Messages must not be sent by the authenticated user
        let userPredicate:LYRPredicate! = LYRPredicate(property: "sender.userID", predicateOperator: LYRPredicateOperator.IsNotEqualTo, value: self.layerClient.authenticatedUserID)
        
        
        query.predicate = LYRCompoundPredicate(type: LYRCompoundPredicateType.And, subpredicates: [unreadPredicate, userPredicate])
        
        query.resultType = LYRQueryResultType.Count
        var error:NSError? = nil
        let unreadMessageCount = self.layerClient.countForQuery(query!, error: &error)

        converstaionsButton.setTitle("\(unreadMessageCount)", forState: UIControlState.Normal)
    }
    
    
    func centerMap() {
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                // do something with the new geoPoint
                let coordinates = CLLocationCoordinate2D(latitude: (geoPoint?.latitude)!, longitude: (geoPoint?.longitude)!)
                self.mapView.centerCoordinate = coordinates
            } else {
                NSLog("error brining map to center")
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        TTUser.clearStoredCredential()
//        exit(0)
//        SVProgressHUD.show()

        self.title = ""

        layerClient = APP_DELEGATE.layerClient
        
        mapView.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            locationManager.distanceFilter = 10; // meters
            // ...
        case .NotDetermined:
            locationManager.requestAlwaysAuthorization()
        case .AuthorizedWhenInUse, .Restricted, .Denied:
            let alertController = UIAlertController(
                title: "Background Location Access Disabled",
                message: "In order to be notified about adorable taggers near you, please open this app's settings and set location access to 'Always'.",
                preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            self.presentViewController(alertController, animated: true, completion: nil)
//            SVProgressHUD.dismiss()

        }
        
        
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                NSLog("about to sign in")
                TTUser.createOrloginUser({ (user) -> () in
                    self.locationManager.startUpdatingLocation()
//                    self.locationManager.startMonitoringSignificantLocationChanges()
                    self.locationManager.pausesLocationUpdatesAutomatically = true

                    // do something with the new geoPoint
                    let coordinates = CLLocationCoordinate2D(latitude: (geoPoint?.latitude)!, longitude: (geoPoint?.longitude)!)
                    
                    
                    self.updateMyAnnotation(coordinates)
                    
                    let span = MKCoordinateSpanMake(0.05, 0.05)
                    let region = MKCoordinateRegion(center: coordinates, span: span)
                    self.mapView.setRegion(region, animated: true)
                    
                    // start updating annotations
                    if self.timer == nil {
                        self.timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("updateAnnotations"), userInfo: nil, repeats: true)
                        self.updateAnnotations()
                        //                            SVProgressHUD.dismiss()
                    }
                    self.loginLayer()
                    }, failed: { (error) -> () in
                        NSLog("failed login!!!!!!!!!!!!!!!!!!!!!!!!!")
                })
            }
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSLog("view will appear")
        if self.timer != nil {
            updateAnnotations()
            
            let currentUser = PFUser.currentUser()
            let coordinates = CLLocationCoordinate2D(latitude: ((currentUser![TTUSER.location] as? PFGeoPoint)?.latitude)!, longitude: ((currentUser![TTUSER.location] as? PFGeoPoint)?.longitude)!)
            //without the following call the myAnnotation button does not work after coming back from a previous screen until location changes
            updateMyAnnotation(coordinates)
        }
    }
    
    func updateAnnotations() -> Void {
        NSLog("updating annotations")
        updateUnreadMessageCount()
        
        // do something with the new geoPoint
        TTUser.searchUsersWithMatchingTagsCloseBy({ (results) -> () in
            self.mapView.removeAnnotations(self.allAnnotations)
            self.allAnnotations  = [TTAnnotation]()
            for user in results.reverse() {
                if user != PFUser.currentUser() {
                    let overlappingTags = TTHashTag.overlappingTagsString(PFUser.currentUser()!, secondUser: user)
                    let coordinates = CLLocationCoordinate2D(latitude: ((user[TTUSER.location] as? PFGeoPoint)?.latitude)!, longitude: ((user[TTUSER.location] as? PFGeoPoint)?.longitude)!)
                    let annotation = TTAnnotation(coordinate: coordinates, title: overlappingTags, subtitle: "", type: .Them, user: user)
                    self.mapView.addAnnotation(annotation)
                    self.allAnnotations.append(annotation)
                }
            }
            }) { (error) -> () in
                NSLog("??????????????????? error: \(error)")
        }
        
        
    }
    
    func updateMyAnnotation(coordinates:CLLocationCoordinate2D) -> Void  {
        let annotation = TTAnnotation(coordinate: coordinates, title: "me", subtitle: "", type: .Me, user: PFUser.currentUser()!)
        //        mapView.centerCoordinate = annotation.coordinate
        //        mapView.scrollEnabled = false
        //        mapView.rotateEnabled = false
        mapView.addAnnotation(annotation)
        mapView.removeAnnotations([currentAnnotation])
        currentAnnotation = annotation
        
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            // Do stuff with the user
            currentUser?.setValue(PFGeoPoint(latitude: coordinates.latitude, longitude: coordinates.longitude), forKey: TTUSER.location)
            currentUser?.saveInBackground()
        } else {
            // Show the signup or login screen
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let newLocation = locations.last
        let currentLocation = manager.location!.coordinate
//        let currentCoordinates = CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        updateMyAnnotation(currentLocation)
        
        if UIApplication.sharedApplication().applicationState == .Active {
//            mapView.showAnnotations(currentLocation, animated: true)
            NSLog("App is active. New location is \(currentLocation.latitude) \(currentLocation.longitude)")
        } else {
            NSLog("App is backgrounded. New location is \(currentLocation.latitude) \(currentLocation.longitude)")
        }
    }
    

//    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        let addNewTagViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AddNewTagViewController") as! AddNewTagViewController
//        navigationController?.pushViewController(addNewTagViewController, animated: true)
//    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let ttAnnotationView = view as! TTAnnotationView
        if ttAnnotationView.ttAnnotation?.pinType == .Me {
            let myTagsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MyTagsViewController") as! MyTagsViewController
            navigationController?.pushViewController(myTagsViewController, animated: true)
        } else {
            let usersSet = NSMutableSet()
            usersSet.addObject(PFUser.currentUser()!.objectId!)
            usersSet.addObject((ttAnnotationView.ttAnnotation?.user?.objectId!)!)


                let query: LYRQuery = LYRQuery(queryableClass: LYRConversation.self)
                query.predicate = LYRPredicate(property: "participants", predicateOperator: LYRPredicateOperator.IsEqualTo, value: usersSet)
//                query.limit = 1
            
                var conversation:LYRConversation?
            
                self.layerClient.executeQuery(query, completion: { (results, error:NSError!) -> Void in
                    if error == nil {
                        if results.count > 0 {
                            conversation = results[0] as? LYRConversation
                        } else {
                            do {
                                conversation = try self.layerClient.newConversationWithParticipants(usersSet as Set<NSObject>, options: nil)
                            } catch {
                                    NSLog("failed to create new conversation")
                            }
                        }
                        
                        
                        let conversationViewController: ConversationViewController = ConversationViewController(layerClient: self.layerClient)
                        //                    conversationViewController.displaysAddressBar = shouldShowAddressBar
                        conversationViewController.conversation = conversation
//                        conversationViewController.typingIndicatorController = ATLTypingIndicatorViewController()
                        self.navigationController?.pushViewController(conversationViewController, animated: true)
                    }
                })
                    
            
        }
    }
    
    
    
    // MARK - Layer Authentication Methods
    
    func loginLayer() {
        // Connect to Layer
        // See "Quick Start - Connect" for more details
        // https://developer.layer.com/docs/quick-start/ios#connect
        self.layerClient.connectWithCompletion { success, error in
            if (!success) {
                NSLog("!!!!!!!!!!!!!!!!!!!!!!!Failed to connect to Layer: \(error)")
            } else {
                let userID: String = PFUser.currentUser()!.objectId!
                // Once connected, authenticate user.
                // Check Authenticate step for authenticateLayerWithUserID source
                self.authenticateLayerWithUserID(userID, completion: { success, error in
                    if (!success) {
                        NSLog("!!!!!!!!!!!!!!!!!!!!!Failed Authenticating Layer Client with error:\(error)")
                    } else {
                        NSLog("!!!!!!!!!!!!!!!!!!!Layer Authenticated")
//                        self.presentConversationListViewController()
                    }
                })
            }
        }
    }

    
    func authenticateLayerWithUserID(userID: NSString, completion: ((success: Bool , error: NSError!) -> Void)!) {
        // Check to see if the layerClient is already authenticated.
        if self.layerClient.authenticatedUserID != nil {
            // If the layerClient is authenticated with the requested userID, complete the authentication process.
            if self.layerClient.authenticatedUserID == userID {
                print("Layer Authenticated as User \(self.layerClient.authenticatedUserID)")
                if completion != nil {
                    completion(success: true, error: nil)
                }
                return
            } else {
                //If the authenticated userID is different, then deauthenticate the current client and re-authenticate with the new userID.
                self.layerClient.deauthenticateWithCompletion { (success: Bool, error: NSError!) in
                    if error != nil {
                        self.authenticationTokenWithUserId(userID, completion: { (success: Bool, error: NSError?) in
                            if (completion != nil) {
                                completion(success: success, error: error)
                            }
                        })
                    } else {
                        if completion != nil {
                            completion(success: true, error: error)
                        }
                    }
                }
            }
        } else {
            // If the layerClient isn't already authenticated, then authenticate.
            self.authenticationTokenWithUserId(userID, completion: { (success: Bool, error: NSError!) in
                if completion != nil {
                    completion(success: success, error: error)
                }
            })
        }
    }
    
    func authenticationTokenWithUserId(userID: NSString, completion:((success: Bool, error: NSError!) -> Void)!) {
        /*
        * 1. Request an authentication Nonce from Layer
        */
        self.layerClient.requestAuthenticationNonceWithCompletion { (nonce: String!, error: NSError!) in
            if (nonce.isEmpty) {
                if (completion != nil) {
                    completion(success: false, error: error)
                } else {
                    NSLog("nonce completion erro!!!!!!!!!!!!!!!!!!!!")
                }
                return
            }
            
            /*
            * 2. Acquire identity Token from Layer Identity Service
            */
            PFCloud.callFunctionInBackground("generateToken", withParameters: ["nonce": nonce, "userID": userID]) { (object:AnyObject?, error: NSError?) -> Void in
                if error == nil {
                    let identityToken = object as! String
                    self.layerClient.authenticateWithIdentityToken(identityToken) { authenticatedUserID, error in
                        if (!authenticatedUserID.isEmpty) {
                            if (completion != nil) {
                                completion(success: true, error: nil)
                            }
                            NSLog("Layer Authenticated as User: \(authenticatedUserID)")
                        } else {
                            completion(success: false, error: error)
                            NSLog("!!!!!!!!!!!!!!!!!!!Layer Authenticated failed: \(error)")
                        }
                    }
                } else {
                    NSLog("!!!!!!!!!!!!!!!!!!Parse Cloud function failed to be called to generate token with error: \(error)")
                }
            }
        }
    }
}


extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = TTAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        annotationView.canShowCallout = false
        self.mapView.bringSubviewToFront(annotationView)
        return annotationView
    }
    
    
    
    
    
}