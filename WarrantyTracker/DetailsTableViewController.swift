//
//  DetailsTableViewController.swift
//  WarrantyTracker
//
//  Created by Jeff Chimney on 2016-05-26.
//  Copyright © 2016 Jeff Chimney. All rights reserved.
//

import UIKit
import CloudKit

class DetailsTableViewController: UITableViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    var recordToReceive: CKRecord!
    var imagesRecords: [CKRecord] = []
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var receiptImageView: UIImageView!
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var endDateLabel: UILabel!
    
    var itemWasInRecordsList: [CKRecord]!
    
    var container = CKContainer.defaultContainer()
    var publicDB : CKDatabase!
    var privateDB : CKDatabase!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
        
        getAssetsFromCloudKitByRecent()
        
        activityIndicator.hidden = false
        
        // add activity indicator
        //activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .Gray
        activityIndicator.backgroundColor = UIColor.whiteColor()
        activityIndicator.startAnimating()
        //self.view.addSubview(activityIndicator)
        
        // if using navbar, use 64 instead of 20 for inset.
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        self.tableView.allowsSelection = false
        
        let titleLabelString = recordToReceive["Title"] as! String
        let detailsLabelString = recordToReceive["Description"] as! String
        //var itemImage = recordToReceive["Item"] as! NSDate
        //var receiptImage = recordToReceive["Receipt"] as! NSDate
        let startDate = recordToReceive["StartDate"] as! NSDate
        let endDate = recordToReceive["EndDate"] as! NSDate
        
        titleLabel.text = titleLabelString
        detailsLabel.text = detailsLabelString
        
        // format date properly as string
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let startDateString = dateFormatter.stringFromDate(startDate)
        startDateLabel.text = startDateString
        let endDateString = dateFormatter.stringFromDate(endDate)
        endDateLabel.text = endDateString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func addActivityIndicator() {
//        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
//        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
//        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
//        activityIndicator.startAnimating()
//        self.view.addSubview(activityIndicator)
//    }
    
    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
    
    // MARK: - Table view data source

    /*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    } */

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - CloudKit Getters
    
    func getAssetsFromCloudKitByRecent() {
        let reference = CKReference(record: recordToReceive, action: CKReferenceAction.DeleteSelf)
        
        let predicate = NSPredicate(format: "AssociatedRecord = %@", reference)
        let query = CKQuery(recordType: "ImagesForRecord", predicate: predicate)
        
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results, error) in
            
            // tell the table how many rows it should have
            
            self.imagesRecords = results!
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.imagesRecords.count != 0 {
                    if let asset = self.imagesRecords[0]["Item"] as? CKAsset,
                        data = NSData(contentsOfURL: asset.fileURL),
                        image = UIImage(data: data) {
                        self.itemImageView.image = image
                    }
                    
                    if let receiptAsset = self.imagesRecords.first!["Receipt"] as? CKAsset,
                        receiptData = NSData(contentsOfURL: receiptAsset.fileURL),
                        receiptImage = UIImage(data: receiptData) {
                        self.receiptImageView.image = receiptImage
                    }
                    self.removeActivityIndicator()
                }
            })
        })
    }
}
