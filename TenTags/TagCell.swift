//
//  TagCell.swift
//  TenTags
//
//  Created by D on 11/23/15.
//  Copyright © 2015 EchoWaves. All rights reserved.
//

import Foundation

class TagCell: UICollectionViewCell {
    
    @IBOutlet weak var tagName: UILabel!
    
    
    @IBOutlet weak var tagNameMaxWidthConstraint: NSLayoutConstraint!
    
    
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
//        self.tagName.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        self.layer.cornerRadius = 4
        
        self.tagNameMaxWidthConstraint.constant = UIScreen.mainScreen().bounds.width - 8 * 2 - 8 * 2
    }
    
    
}