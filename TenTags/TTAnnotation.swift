//
//  CustomPin.swift
//  TenTags
//
//  Created by D on 11/27/15.
//  Copyright © 2015 EchoWaves. All rights reserved.
//

import UIKit
import MapKit
import Parse


enum PinType: Int {
    case Me = 0
    case Them
}


class TTAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var pinType: PinType?
    var user: PFUser?
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, type: PinType, user: PFUser?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.pinType = type
        self.user = user
    }
}