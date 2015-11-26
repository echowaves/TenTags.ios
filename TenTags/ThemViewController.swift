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


class ThemViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locations = [MKPointAnnotation]()

    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters//kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        let location = "1 Infinity Loop, Cupertino, CA"
//        var geocoder:CLGeocoder = CLGeocoder()
//        geocoder.geocodeAddressString(location, completionHandler: {(placemarks, error) -> Void in
//            
//            if((error) != nil){
//                
//                print("Error", error)
//            }
//                
//            else if let placemark = placemarks![0] as? CLPlacemark {
//                
//                var placemark:CLPlacemark = placemarks![0] as! CLPlacemark
//                var coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
//                
//                var pointAnnotation:MKPointAnnotation = MKPointAnnotation()
//                pointAnnotation.coordinate = coordinates
//                pointAnnotation.title = "Apple HQ"
//                
//                self.mapView?.addAnnotation(pointAnnotation)
//                self.mapView?.centerCoordinate = coordinates
//                self.mapView?.selectAnnotation(pointAnnotation, animated: true)
//                
//                print("Added annotation to map view")
//            }
//            
//        })
        
    }

    @IBAction func accuracyChanged(sender: UISegmentedControl) {
        let accuracyValues = [
            kCLLocationAccuracyBestForNavigation,
            kCLLocationAccuracyBest,
            kCLLocationAccuracyNearestTenMeters,
            kCLLocationAccuracyHundredMeters,
            kCLLocationAccuracyKilometer,
            kCLLocationAccuracyThreeKilometers]
        
        locationManager.desiredAccuracy = accuracyValues[sender.selectedSegmentIndex];
    }
    
    @IBAction func enabledChanged(sender: UISwitch) {
        if sender.on {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        // Add another annotation to the map.
        let annotation = MKPointAnnotation()
        annotation.coordinate = newLocation.coordinate
        
        // Also add to our map so we can remove old values later
        locations.append(annotation)
        
        // Remove values if the array is too big
        while locations.count > 100 {
            let annotationToRemove = locations.first!
            locations.removeAtIndex(0)
            
            // Also remove from the map
            mapView.removeAnnotation(annotationToRemove)
        }
        
        if UIApplication.sharedApplication().applicationState == .Active {
            mapView.showAnnotations(locations, animated: true)
        } else {
            NSLog("App is backgrounded. New location is %@", newLocation)
        }
    }
    
}

