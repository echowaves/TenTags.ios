//
//  CustomPin.swift
//  TenTags
//
//  Created by D on 11/27/15.
//  Copyright © 2015 EchoWaves. All rights reserved.
//

import UIKit
import MapKit

enum PinType: Int {
    case PinMe = 0
    case PinThem
}


class CustomPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var pinType: PinType?
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, type: PinType) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.pinType = type
    }
}