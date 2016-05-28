//
//  FirstViewController.swift
//  WarrantyTracker
//
//  Created by Jeff Chimney on 2016-05-20.
//  Copyright © 2016 Jeff Chimney. All rights reserved.
//

import UIKit
import CloudKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var WarrantiesTableView: UITableView!
    @IBOutlet weak var settingsButton: UITabBarItem!
    
    var container = CKContainer.defaultContainer()
    var publicDB : CKDatabase!
    var privateDB : CKDatabase!
    
    let cloudKitHelper = CloudKitHelper()
    var rowsInTable = 0
    
    var warrantyImage: UIImage!
    var warrantyRecords: [CKRecord] = []
    var recordsMatchingSearch: [CKRecord] = []
    
    var titleToPass:String!
    var detailsToPass:String!
    var itemImageToPass: UIImage!
    var receiptImageToPass: UIImage!
    var startDateToPass: NSDate!
    var endDateToPass: NSDate!
    
    var searchBar:UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar = UISearchBar(frame: CGRectMake(0, 0, self.view.frame.width, 20))
        
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
        
        WarrantiesTableView.delegate = self
        WarrantiesTableView.dataSource = self
        searchBar.delegate = self
        
        // add search bar to nav bar
        searchBar.placeholder = "Search"
        
        let rightNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.rightBarButtonItem = rightNavBarButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        // load cloudkit assets or later use
        getAssetsFromCloudKit()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        
        for record in warrantyRecords {
            let searchTerm = searchBar.text
            let recordTags = record["Tags"] as! String
            
            if recordTags.containsString(searchTerm!) {
                recordsMatchingSearch.append(record)
            }
        }
        
        rowsInTable = recordsMatchingSearch.count
        
        // reload table view with data matching search
        WarrantiesTableView.reloadData()
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // ------------------------  UITableViewDataSource Delegate Methods --------------------------  //
    //////////////////////////////////////////////////////////////////////////////////////////////////
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsInTable // number of entries in cloudkit or items matching search
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if searchBar.text == "" {
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
        // if the user has entered a search term, only show those items that have a matching tag
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! WarrantyTableViewCell
            let index = indexPath.row
            let currentRecord = recordsMatchingSearch[index]
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
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let recordTapped = warrantyRecords[indexPath.row]
        
        if let asset = recordTapped["Image"] as? CKAsset,
            data = NSData(contentsOfURL: asset.fileURL),
            image = UIImage(data: data)
        {
            itemImageToPass = image
        }
        
        if let receiptAsset = recordTapped["Receipt"] as? CKAsset,
            receiptData = NSData(contentsOfURL: receiptAsset.fileURL),
            receiptImage = UIImage(data: receiptData)
        {
            receiptImageToPass = receiptImage
        }
        
        titleToPass = recordTapped["Title"] as? String
        detailsToPass = recordTapped["Description"] as? String
        startDateToPass = recordTapped["StartDate"] as? NSDate
        endDateToPass = recordTapped["EndDate"] as? NSDate
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //self.navigationController?.pushViewController(detailsTableViewController, animated: true)
        performSegueWithIdentifier("showDetail", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailsTableViewController = segue.destinationViewController as! DetailsTableViewController
        
        detailsTableViewController.titleLabelString = titleToPass
        detailsTableViewController.detailsLabelString = detailsToPass
        detailsTableViewController.itemImage = itemImageToPass
        detailsTableViewController.receiptImage = receiptImageToPass
        detailsTableViewController.startDate = startDateToPass
        detailsTableViewController.endDate = endDateToPass
        
        //detailsTableViewController.titleLabel.text = recordTapped["Title"] as? String
        //detailsTableViewController.detailsLabel.text = recordTapped["Description"] as? String
        //detailsTableViewController.startDate = recordTapped["StartDate"] as? NSDate
        //detailsTableViewController.EndDate = recordTapped["EndDate"] as? NSDate
        //detailsTableViewController.itemImageView.image = itemImage
        //detailsTableViewController.receiptImageView.image = receiptImage
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

