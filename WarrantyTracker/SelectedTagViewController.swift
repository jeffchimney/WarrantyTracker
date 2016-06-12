//
//  SelectedTagViewController.swift
//  WarrantyTracker
//
//  Created by Jeff Chimney on 2016-06-09.
//  Copyright © 2016 Jeff Chimney. All rights reserved.
//

import UIKit
import CloudKit

class SelectedTagViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var SelectedTagTableView: UITableView!
    
    var selectedTag: String!
    var records: [CKRecord] = []
    var recordsWithTag: [CKRecord] = []
    //var activeRecordsList: [CKRecord] = []
    var recordsMatchingSearch: [CKRecord] = []
    
    var recordToPass: CKRecord!
    
    var container = CKContainer.defaultContainer()
    var publicDB : CKDatabase!
    var privateDB : CKDatabase!
    
    var searchBar:UISearchBar!
    
    var rowsInTable = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar = UISearchBar(frame: CGRectMake(0, 0, self.view.frame.width-60, 20))
        
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase

        SelectedTagTableView.delegate = self
        SelectedTagTableView.dataSource = self
        
        // add search bar to nav bar
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        
        let rightNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.rightBarButtonItem = rightNavBarButton
        
        getRecordsWithTag(selectedTag)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()

        // on leaving search, reset results to all tags
        recordsMatchingSearch = recordsWithTag
        rowsInTable = recordsWithTag.count
        
        SelectedTagTableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        
        recordsMatchingSearch = []
        
        for record in 0...recordsWithTag.count-1 {
            let searchTerm = searchBar.text?.lowercaseString
            let currentRecord = recordsWithTag[record]
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
        SelectedTagTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View Delegate Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsInTable
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! WarrantyTableViewCell
        let index = indexPath.row
        let currentRecord = recordsWithTag[index]
        
        if recordsWithTag.count > 0 {
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
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if searchBar.text == "" {
            recordsMatchingSearch = recordsWithTag
            let recordTapped = recordsWithTag[indexPath.row]
            
            recordToPass = recordTapped
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            let recordTapped = recordsMatchingSearch[indexPath.row]
            
            recordToPass = recordTapped
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        //self.navigationController?.pushViewController(detailsTableViewController, animated: true)
        performSegueWithIdentifier("showRecordDetail", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailsTableViewController = segue.destinationViewController as! DetailsTableViewController
        
        detailsTableViewController.recordToReceive = recordToPass
        detailsTableViewController.itemWasInRecordsList = recordsMatchingSearch
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Cloud Kit Get Methods
    
    func getRecordsWithTag(tag: String) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Record", predicate: predicate)
        //query.sortDescriptors = [NSSortDescriptor(key: "Name", ascending: true)]
        
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results, error) in
            
            // tell the table how many rows it should have
            self.records = results!
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                for record in self.records {
                    print(record["Tags"]!)
                    let currentRecordTags = record["Tags"]! as? String
                    if (currentRecordTags!.containsString(tag)) {
                        self.recordsWithTag.append(record)
                    }
                }
                self.rowsInTable = self.recordsWithTag.count
                self.SelectedTagTableView.reloadData()
            })
        })
    }
}
