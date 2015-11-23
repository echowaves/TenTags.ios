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


class ThemViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let location = "1 Infinity Loop, Cupertino, CA"
        var geocoder:CLGeocoder = CLGeocoder()
        geocoder.geocodeAddressString(location, completionHandler: {(placemarks, error) -> Void in
            
            if((error) != nil){
                
                print("Error", error)
            }
                
            else if let placemark = placemarks![0] as? CLPlacemark {
                
                var placemark:CLPlacemark = placemarks![0] as! CLPlacemark
                var coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                
                var pointAnnotation:MKPointAnnotation = MKPointAnnotation()
                pointAnnotation.coordinate = coordinates
                pointAnnotation.title = "Apple HQ"
                
                self.mapView?.addAnnotation(pointAnnotation)
                self.mapView?.centerCoordinate = coordinates
                self.mapView?.selectAnnotation(pointAnnotation, animated: true)
                
                print("Added annotation to map view")
            }
            
        })
        
    }
    
    
    @IBAction func switchToMe(sender: AnyObject) {
        self.dismissViewControllerAnimated(false) { () -> Void in
            let meViewController = self.storyboard?.instantiateViewControllerWithIdentifier("meController") as! MeViewController
         
            if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.presentViewController(meViewController, animated: false, completion: nil)
            }
        }
        
    }
    
}

