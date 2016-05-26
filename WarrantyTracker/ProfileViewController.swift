//
//  FirstViewController.swift
//  WarrantyTracker
//
//  Created by Jeff Chimney on 2016-05-20.
//  Copyright © 2016 Jeff Chimney. All rights reserved.
//

import UIKit
import CloudKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var WarrantiesTableView: UITableView!
    @IBOutlet weak var settingsButton: UITabBarItem!
    
    var container = CKContainer.defaultContainer()
    var publicDB : CKDatabase!
    var privateDB : CKDatabase!
    
    let cloudKitHelper = CloudKitHelper()
    var rowsInTable = 0
    
    var warrantyImage: UIImage!
    var warrantyRecords: [CKRecord] = []
    
    // Use NSUserDefaults to store all images and variables associated
    // with the row the user selects
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
        
        WarrantiesTableView.delegate = self
        WarrantiesTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        // load cloudkit assets or later use
        getAssetsFromCloudKit()
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // ------------------------  UITableViewDataSource Delegate Methods --------------------------  //
    //////////////////////////////////////////////////////////////////////////////////////////////////
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsInTable // number of entries in cloudkit
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! WarrantyTableViewCell
        let index = indexPath.row
        let currentRecord = warrantyRecords[index]
        if let asset = currentRecord["Image"] as? CKAsset,
            data = NSData(contentsOfURL: asset.fileURL),
            image = UIImage(data: data)
        {
            warrantyImage = image
        }
        // populate cells with info from cloudkit
        cell.cellImageView.image = warrantyImage
        cell.warrantyLabel.text = currentRecord["Title"] as? String
        cell.descriptionLabel.text = currentRecord["Description"] as? String
        let endDate = currentRecord["EndDate"] as! NSDate
        
        // format date properly as string
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let endDateString = dateFormatter.stringFromDate(endDate)
        cell.endDateLabel.text = endDateString
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let record = warrantyRecords[indexPath.row]
        
        /*
        if let asset = record["Image"] as? CKAsset,
            data = NSData(contentsOfURL: asset.fileURL),
            image = UIImage(data: data)
        {
            defaults.setObject(image, forKey: "Image")
        }
        
        if let receiptAsset = record["Receipt"] as? CKAsset,
            data = NSData(contentsOfURL: receiptAsset.fileURL),
            receiptImage = UIImage(data: data)
        {
            defaults.setObject(receiptImage, forKey: "Receipt")
        }*/
        
        defaults.setObject(record["Title"] as? String, forKey: "Title")
        defaults.setObject(record["Description"] as? String, forKey: "Description")
        defaults.setObject(record["StartDate"] as? NSDate, forKey: "StartDate")
        defaults.setObject(record["EndDate"] as? NSDate, forKey: "EndDate")
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // --------------------------------  CloudKit 'Get'  Methods ---------------------------------- //
    /////////////////////////////// Set methods are in CloudKitHelper ////////////////////////////////
    
    func getAssetsFromCloudKit() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Image", predicate: predicate)
        
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results, error) in
            
            // tell the table how many rows it should have
            self.rowsInTable = (results?.count)!
            
            self.warrantyRecords = results!
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.WarrantiesTableView.reloadData()
            })
        })
    }
}

