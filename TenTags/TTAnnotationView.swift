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
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 22))
            label.text = ttAnnotation.title
            label.backgroundColor = UIColor(rgb: 0xFF9900)
            label.layer.cornerRadius = 5
            label.layer.masksToBounds = true
            label.textAlignment = .Center
            image = UIImage.imageWithLabel(label)
        case .Them:
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 22))
            label.text = ttAnnotation.title
            label.backgroundColor = UIColor(rgb: 0xcccff)
            image = UIImage.imageWithLabel(label)
        }
    }
}

extension UIImage {
    class func imageWithLabel(label: UILabel) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}