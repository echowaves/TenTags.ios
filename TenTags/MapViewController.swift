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


class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var currentLocation = [MKPointAnnotation()]

    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        return manager
    }()
    
    @IBAction func buttonPushed(sender: AnyObject) {
        let myTagsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MyTagsViewController") as! MyTagsViewController
        navigationController?.pushViewController(myTagsViewController, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TTUser.createOrloginUser()
        
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringVisits()
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
        
        
        
//        if CLLocationManager.authorizationStatus() == .NotDetermined {
//            locationManager.requestAlwaysAuthorization()
//        }
//        
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.startUpdatingLocation()
//        }
    }

    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        // Add another annotation to the map.
        let annotation = MKPointAnnotation()
        annotation.coordinate = newLocation.coordinate
        
        mapView.removeAnnotations(currentLocation)
        // Also add to our map so we can remove old values later
        currentLocation[0] = annotation
        if UIApplication.sharedApplication().applicationState == .Active {
            mapView.showAnnotations(currentLocation, animated: true)
            NSLog("App is active. New location is %@", newLocation)
        } else {
            NSLog("App is backgrounded. New location is %@", newLocation)
        }
    }
    
    
    
    
}

