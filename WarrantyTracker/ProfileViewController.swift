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
    
    var warrantyImages: [UIImage] = []
    
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
        return rowsInTable // for now
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! WarrantyTableViewCell
        
        if warrantyImages.count > 0 {
            cell.cellImageView.image = warrantyImages.popLast()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath)
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
            
            for record in results! {
                if let asset = record["Image"] as? CKAsset,
                    data = NSData(contentsOfURL: asset.fileURL),
                    image = UIImage(data: data)
                {
                    // Do something with the image
                    print(image)
                    self.warrantyImages.append(image)
                }
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.WarrantiesTableView.reloadData()
            })
        })
    }
}

