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



class MapViewController: UIViewController, CLLocationManagerDelegate {

    var timer:NSTimer?

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
    
    @IBAction func centerMapAction(sender: AnyObject) {
        self.centerMap()
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
    
//    @IBAction func buttonPushed(sender: AnyObject) {
//        let myTagsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MyTagsViewController") as! MyTagsViewController
//        navigationController?.pushViewController(myTagsViewController, animated: true)
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        TTUser.clearStoredCredential()
//        exit(0)

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
        }
        
        
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                NSLog("about to sign in")
                TTUser.createOrloginUser({ (user) -> () in
                    self.locationManager.startUpdatingLocation()
                    // do something with the new geoPoint
                    let coordinates = CLLocationCoordinate2D(latitude: (geoPoint?.latitude)!, longitude: (geoPoint?.longitude)!)
                    
                    let annotation = TTAnnotation(coordinate: coordinates, title: "me", subtitle: "", type: .Me, user: user)
                    self.mapView.centerCoordinate = annotation.coordinate
                    self.mapView.addAnnotation(annotation)
                    self.currentAnnotation = annotation
                    let span = MKCoordinateSpanMake(0.05, 0.05)
                    let region = MKCoordinateRegion(center: coordinates, span: span)
                    self.mapView.setRegion(region, animated: true)
                    let currentUser = PFUser.currentUser()
                    NSLog("current user: \(currentUser)")
                    if currentUser != nil {
                        // Do stuff with the user
                        currentUser?.setValue(PFGeoPoint(latitude: coordinates.latitude, longitude: coordinates.longitude), forKey: TTUSER.location)
                        currentUser?.saveInBackground()
                        NSLog("saving current user")
                        // start updating annotations
                        if self.timer == nil {
                            self.timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("updateAnnotations"), userInfo: nil, repeats: true)
                            self.updateAnnotations()
                        }
                    }
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
        }
    }
    
    func updateAnnotations() -> Void {
        NSLog("updating annotations")
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
    
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        // Add another annotation to the map.

        let annotation = TTAnnotation(coordinate: newLocation.coordinate, title: "me", subtitle: "", type: .Me, user: PFUser.currentUser()!)
        //        mapView.centerCoordinate = annotation.coordinate
        //        mapView.scrollEnabled = false
        //        mapView.rotateEnabled = false
        mapView.addAnnotation(annotation)
        mapView.removeAnnotations([currentAnnotation])
        currentAnnotation = annotation
        
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            // Do stuff with the user
            currentUser?.setValue(PFGeoPoint(location: newLocation), forKey: TTUSER.location)
            currentUser?.saveInBackground()
        } else {
            // Show the signup or login screen
        }
        
        if UIApplication.sharedApplication().applicationState == .Active {
//            mapView.showAnnotations(currentLocation, animated: true)
            NSLog("App is active. New location is %@", newLocation)
        } else {
            NSLog("App is backgrounded. New location is %@", newLocation)
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