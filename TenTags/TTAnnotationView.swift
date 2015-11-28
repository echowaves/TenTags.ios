//
//  CustomAnnotationView.swift
//  TenTags
//
//  Created by D on 11/28/15.
//  Copyright © 2015 EchoWaves. All rights reserved.
//

import UIKit
import MapKit

class TTAnnotationView: MKAnnotationView {
    // Required for MKAnnotationView
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    // Called when drawing the AttractionAnnotationView
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        let ttAnnotation = self.annotation as! TTAnnotation
        switch (ttAnnotation.pinType!) {
        case .Me:
            image = UIImage(named: "green_circle")
        case .Them:
            image = UIImage(named: "blue_circle")
        }
    }
}