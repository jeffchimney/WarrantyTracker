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
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var receiptImageView: UIImageView!
    
    var container = CKContainer.defaultContainer()
    var publicDB : CKDatabase!
    var privateDB : CKDatabase!
    
    // Use NSUserDefaults to store all images and variables associated
    // with the row the user selects
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
        
        // if using navbar, use 64 instead of 20 for inset.
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        self.tableView.allowsSelection = false
        
        /*
        if let asset = currentRecord["Image"] as? CKAsset,
            data = NSData(contentsOfURL: asset.fileURL),
            image = UIImage(data: data)
        {
            warrantyImage = image
        } */
        
        let titleString = defaults.objectForKey("Title") as? String
        let descriptionString = defaults.objectForKey("Description") as? String
        let receiptURLString = defaults.objectForKey("ReceiptURLString") as? String
        let imageURLString = defaults.objectForKey("AssetURLString") as? String
        
        titleLabel.text = titleString
        detailsLabel.text = descriptionString
        
        /*
        let receiptDataURL = NSURL(fileURLWithPath: receiptURLString!)
        let receiptData = NSData(contentsOfURL: receiptDataURL)
        let receiptImage = UIImage(data: receiptData!)
        receiptImageView.image = receiptImage
        
        let imageDataURL = NSURL(fileURLWithPath: imageURLString!)
        let imageData = NSData(contentsOfURL: imageDataURL)
        let imageImage = UIImage(data: imageData!)
        itemImageView.image = imageImage */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

}
