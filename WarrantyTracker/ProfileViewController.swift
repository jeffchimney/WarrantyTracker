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
    // sorted by start date
    var warrantyRecords: [CKRecord] = []
    // sorted by end date
    var warrantyRecordsByExpiring: [CKRecord] = []
    var recordsMatchingSearch: [CKRecord] = []
    var activeRecordsList: [CKRecord] = []
    
    var titleToPass:String!
    var detailsToPass:String!
    var itemImageToPass: UIImage!
    var receiptImageToPass: UIImage!
    var startDateToPass: NSDate!
    var endDateToPass: NSDate!
    
    var searchBar:UISearchBar!
    var navBar: UINavigationBar = UINavigationBar()
    
    @IBOutlet weak var recentOrExpiringControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.frame.origin.y = -10
        
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
        getAssetsFromCloudKitByRecent()
        
        if activeRecordsList.count != 0 {
            rowsInTable = activeRecordsList.count
        } else {
            // load cloudkit assets or later use
            getAssetsFromCloudKitByRecent()
        }
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
        
        for record in 0...warrantyRecords.count-1 {
            let searchTerm = searchBar.text?.lowercaseString
            let currentRecord = warrantyRecords[record]
            let recordTags = currentRecord["Tags"] as? String
            let recordTagsLowerCase = recordTags?.lowercaseString
            
            // make sure there is a tag before trying to compare it
            if recordTags == nil {
                print("Found Nil")
            } else if recordTagsLowerCase!.containsString(searchTerm!) {
                recordsMatchingSearch.append(currentRecord)
            }
        }
        
        rowsInTable = recordsMatchingSearch.count
        
        // reload table view with data matching search
        WarrantiesTableView.reloadData()
    }
    
    @IBAction func toggleRecentExpiringControllerChanged(sender: AnyObject) {
        // if recent is selected
        if recentOrExpiringControl.selectedSegmentIndex == 0 {
            
        } else {
        // if expiring is selected
            
        }
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
        if (activeRecordsList.count == 0) {
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
                cell.descriptionTextView.text = currentRecord["Description"] as? String
                let endDate = currentRecord["EndDate"] as! NSDate
            
                // format date properly as string
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let endDateString = dateFormatter.stringFromDate(endDate)
                cell.endDateLabel.text = endDateString
                
                let startDate = currentRecord["StartDate"] as! NSDate
                
                //format properly as string
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let startDateString = dateFormatter.stringFromDate(startDate)
                cell.startDateLabel.text = startDateString
            
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
                cell.descriptionTextView.text = currentRecord["Description"] as? String
                let endDate = currentRecord["EndDate"] as! NSDate
                
                // format date properly as string
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let endDateString = dateFormatter.stringFromDate(endDate)
                cell.endDateLabel.text = endDateString
                
                let startDate = currentRecord["StartDate"] as! NSDate
                
                //format properly as string
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let startDateString = dateFormatter.stringFromDate(startDate)
                cell.startDateLabel.text = startDateString
                
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! WarrantyTableViewCell
            let index = indexPath.row
            let currentRecord = activeRecordsList[index]
            if let asset = currentRecord["Image"] as? CKAsset,
                data = NSData(contentsOfURL: asset.fileURL),
                image = UIImage(data: data)
            {
                warrantyImage = image
            }
            // populate cells with info from cloudkit
            cell.cellImageView.image = warrantyImage
            cell.warrantyLabel.text = currentRecord["Title"] as? String
            cell.descriptionTextView.text = currentRecord["Description"] as? String
            let endDate = currentRecord["EndDate"] as! NSDate
            
            // format date properly as string
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let endDateString = dateFormatter.stringFromDate(endDate)
            cell.endDateLabel.text = endDateString
            
            let startDate = currentRecord["StartDate"] as! NSDate
            
            //format properly as string
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let startDateString = dateFormatter.stringFromDate(startDate)
            cell.startDateLabel.text = startDateString
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if searchBar.text == "" {
            activeRecordsList = warrantyRecords
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
        } else {
            activeRecordsList = recordsMatchingSearch
            let recordTapped = recordsMatchingSearch[indexPath.row]
            
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
        }
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
        detailsTableViewController.itemWasInRecordsList = activeRecordsList
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // --------------------------------  CloudKit 'Get'  Methods ---------------------------------- //
    /////////////////////////////// Set methods are in CloudKitHelper ////////////////////////////////
    
    func getAssetsFromCloudKitByRecent() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Image", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "StartDate", ascending: false)]
        
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results, error) in
            
            // tell the table how many rows it should have
            self.rowsInTable = (results?.count)!
            
            self.warrantyRecords = results!
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.WarrantiesTableView.reloadData()
            })
        })
    }
    
    func getAssetsFromCloudKitByExpiring() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Image", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "EndDate", ascending: true)]
        
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results, error) in
            
            // tell the table how many rows it should have
            self.rowsInTable = (results?.count)!
            
            self.warrantyRecordsByExpiring = results!
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.WarrantiesTableView.reloadData()
            })
        })
    }
}

