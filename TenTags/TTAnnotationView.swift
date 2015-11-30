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
    
    var ttAnnotation:TTAnnotation? = nil
    
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
        ttAnnotation = self.annotation as? TTAnnotation
        switch (ttAnnotation!.pinType!) {
        case .Me:
            image = UIImage(named: "logo")
        case .Them:
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 25))
            label.layer.cornerRadius = 5
            label.layer.masksToBounds = true
            label.textAlignment = .Center
            label.text = ttAnnotation!.title
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