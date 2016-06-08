//
//  TagsTableViewController.swift
//  WarrantyTracker
//
//  Created by Jeff Chimney on 2016-06-07.
//  Copyright © 2016 Jeff Chimney. All rights reserved.
//

import UIKit
import CloudKit

class TagsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var container = CKContainer.defaultContainer()
    var publicDB : CKDatabase!
    var privateDB : CKDatabase!
    
    let cloudKitHelper = CloudKitHelper()
    
    @IBOutlet weak var tagsTableView: UITableView!
    
    @IBOutlet weak var recentAndExpiringControl: UISegmentedControl!
    var searchBar:UISearchBar!
    
    var tagRecords: [CKRecord] = []
    var recordsMatchingSearch: [CKRecord] = []
    var occurrencesOfTags: [CKRecord: Int] = [:]
    
    var rowsInTable = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.placeholder = "Search"
        
        let rightNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.rightBarButtonItem = rightNavBarButton
    }
    
    override func viewWillAppear(animated: Bool) {
        print(rowsInTable)
        // load cloudkit assets or later use
        getTagsFromCloudKit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rowsInTable
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if searchBar.text == "" {
            let cell = tableView.dequeueReusableCellWithIdentifier("tagCell", forIndexPath: indexPath) as! TagTableViewCell
            let index = indexPath.row
            let currentRecord = tagRecords[index]
            
            cell.tagNameLabel.text = currentRecord["Name"] as? String
            cell.numberWithTagLabel.text = currentRecord["Record"] as? String
            
            return cell
            // if the user has entered a search term, only show those items that have a matching tag
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("tagCell", forIndexPath: indexPath) as! TagTableViewCell
            let index = indexPath.row
            let currentRecord = recordsMatchingSearch[index]
            
            cell.tagNameLabel.text = currentRecord["Name"] as? String
            cell.numberWithTagLabel.text = currentRecord["Record"] as? String
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // handle table view cell selection
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 
    @IBAction func recentAndExpiringValueChanged(sender: AnyObject) {
        
    }
    
    // MARK: - CloudKit 'Get'  Methods
    
    func getTagsFromCloudKit() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Tag", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "Name", ascending: true)]
        
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results, error) in
            
            let occurrencesPerTagDict = self.findOccurencesOfItemsInArray(results!)
            
            // tell the table how many rows it should have
            self.rowsInTable = (occurrencesPerTagDict.count)
            
            self.tagRecords = self.removeDuplicatesFromArray(results!)
            self.occurrencesOfTags = self.findOccurencesOfItemsInArray(results!)
            
            print(self.tagRecords)
            print(self.occurrencesOfTags)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tagsTableView.reloadData()
            })
        })
    }
    
    // helper method to get an array of discrete units
    func removeDuplicatesFromArray(inputArray: [CKRecord]) -> [CKRecord] {
        var uniqueArray: [CKRecord] = []
        
        for item in inputArray {
            if !uniqueArray.contains(item) {
                uniqueArray.append(item)
            }
        }
        return uniqueArray
    }
    
    // helper method to count occurrences of each tag
    func findOccurencesOfItemsInArray(inputArray: [CKRecord]) -> [CKRecord: Int] {
        var occurrencesOfItemsDict = [CKRecord: Int]()
        
        for item in inputArray {
            // if the key already exists in the dictionary, add one to value
            if occurrencesOfItemsDict[item] != nil {
                let numberOfOccurrences = occurrencesOfItemsDict[item]
                occurrencesOfItemsDict[item] = numberOfOccurrences! + 1
            } else {
            // add key to the dictionary and set value to 1
                occurrencesOfItemsDict[item] = 1
            }
        }
        
        return occurrencesOfItemsDict
    }
}
