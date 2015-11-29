//
//  MeViewController.swift
//  TenTags
//
//  Created by D on 11/20/15.
//  Copyright © 2015 EchoWaves. All rights reserved.
//

import UIKit

class MyTagsViewController: UIViewController,UICollectionViewDataSource {
    
    var TAGS:NSArray? = [""]
    
    var sizingCell: TagCell?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBOutlet weak var addTagButton: UIButton!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try PFUser.currentUser()?.fetch()
        } catch {
            NSLog("error refreshing current user")
        }
        reloadTags()
    }
    
    func reloadTags() {
        TAGS = PFUser.currentUser()?[TTUSER.hashTags] as? NSArray
        self.collectionView.reloadData()
        NSLog("loading tags")
        
        if TAGS?.count >= 10 {
            addTagButton.hidden = true
        } else {
            addTagButton.hidden = false
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        let cellNib = UINib(nibName: "TagCell", bundle: nil)
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "TagCell")
        self.collectionView.backgroundColor = UIColor.clearColor()
        
        self.sizingCell = (cellNib.instantiateWithOwner(nil, options: nil) as NSArray).firstObject as! TagCell?
        
        self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TAGS!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TagCell", forIndexPath: indexPath) as! TagCell
        self.configureCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: TagCell, forIndexPath indexPath: NSIndexPath) {
        let tag:String = TAGS![indexPath.row] as! String
        cell.tagName.text = tag
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        self.configureCell(self.sizingCell!, forIndexPath: indexPath)
        return self.sizingCell!.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        NSLog("tag selected \(TAGS![indexPath.row])")
        
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        //Create and add a second option action
        let choosePictureAction: UIAlertAction = UIAlertAction(title: "delete #\(TAGS![indexPath.row])", style: .Default) { action -> Void in

            PFUser.currentUser()?.removeObjectsInArray([self.TAGS![indexPath.row]], forKey: "hashTags")
            PFUser.currentUser()?.saveInBackground()

            self.reloadTags()

            self.collectionView.reloadData()
            self.collectionView.reloadInputViews()
        }
        actionSheetController.addAction(choosePictureAction)
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)

        
        self.collectionView.reloadData()
    }

}

