//
//  TagsTableViewController.swift
//  WarrantyTracker
//
//  Created by Jeff Chimney on 2016-06-07.
//  Copyright © 2016 Jeff Chimney. All rights reserved.
// this is a comment

import UIKit
import CloudKit

class TagsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var container = CKContainer.default()
    var publicDB : CKDatabase!
    var privateDB : CKDatabase!
    
    let cloudKitHelper = CloudKitHelper()
    
    @IBOutlet weak var tagsTableView: UITableView!
    
    @IBOutlet weak var recentAndExpiringControl: UISegmentedControl!
    var searchBar:UISearchBar!
    
    var tagRecords: [CKRecord] = []
    var activeRecords: [CKRecord] = []
    var occurrencesOfTags: [String: Int] = [:]
    
    var selectedTag = ""
    var recordsToPass: [CKRecord] = []
    
    var rowsInTable = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tagsTableView.delegate = self
        tagsTableView.dataSource = self
        
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase

        searchBar = UISearchBar(frame: CGRect(x: 0,y: 0, width: self.view.frame.width-40, height: 20))
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        
        let rightNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.rightBarButtonItem = rightNavBarButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // load cloudkit assets or later use
        getTagsFromCloudKit()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        
        // on leaving search, reset results to all tags
        activeRecords = tagRecords
        rowsInTable = activeRecords.count
        
        tagsTableView.reloadData()
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        
        activeRecords = []
        
        for record in 0...tagRecords.count-1 {
            let searchTerm = searchBar.text?.lowercased()
            let currentRecord = tagRecords[record]
            let recordTags = currentRecord["Name"] as? String
            let recordTagsLowerCase = recordTags?.lowercased()
            
            // make sure there is a tag before trying to compare it
            if recordTags == nil {
                print("Found Nil")
            } else if recordTagsLowerCase!.contains(searchTerm!) {
                activeRecords.append(currentRecord)
            }
        }
        
        rowsInTable = activeRecords.count
        
        // reload table view with data matching search
        self.tagsTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rowsInTable
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if searchBar.text == "" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath as IndexPath) as! TagTableViewCell
            let index = indexPath.row
            let currentRecord = tagRecords[index]
            
            cell.tagNameLabel.text = currentRecord["Name"] as? String
            cell.numberWithTagLabel.text = String(occurrencesOfTags[currentRecord["Name"] as! String]!)
            
            return cell
            // if the user has entered a search term, only show those items that have a matching tag
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath as IndexPath) as! TagTableViewCell
            let index = indexPath.row
            let currentRecord = activeRecords[index]
            
            cell.tagNameLabel.text = currentRecord["Name"] as? String
            cell.numberWithTagLabel.text = String(occurrencesOfTags[currentRecord["Name"] as! String]!)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // handle table view cell selection
        let recordTapped = activeRecords[indexPath.row]
        selectedTag = recordTapped["Name"] as! String
        
        performSegue(withIdentifier: "toRecordsWithTag", sender: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let selectedTagTableViewController = segue.destination as! SelectedTagViewController
        
        selectedTagTableViewController.selectedTag = selectedTag
    }
 
    @IBAction func recentAndExpiringValueChanged(sender: AnyObject) {
        
    }
    
    // MARK: - CloudKit 'Get'  Methods
    
    func getTagsFromCloudKit() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Tag", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "Name", ascending: true)]
        
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results, error) in
            
            // tell the table how many rows it should have
            self.tagRecords = self.removeDuplicatesFromArray(inputArray: results!)
            self.activeRecords = self.tagRecords
            self.rowsInTable = self.activeRecords.count
            self.occurrencesOfTags = self.findOccurencesOfItemsInArray(inputArray: results!)
            
            DispatchQueue.main.async {
                self.tagsTableView.reloadData()
            }
        })
    }
    
    // helper method to get an array of discrete units
    func removeDuplicatesFromArray(inputArray: [CKRecord]) -> [CKRecord] {
        var uniqueArray: [String] = []
        var uniqueItemArray: [CKRecord] = []
        
        for item in inputArray {
            if !uniqueArray.contains(item["Name"] as! String) {
                uniqueArray.append(item["Name"] as! String)
                uniqueItemArray.append(item)
            }
        }
        return uniqueItemArray
    }
    
    // helper method to count occurrences of each tag
    func findOccurencesOfItemsInArray(inputArray: [CKRecord]) -> [String: Int] {
        var occurrencesOfItemsDict = [String: Int]()
        
        for item in inputArray {
            // if the key already exists in the dictionary, add one to value
            if occurrencesOfItemsDict[item["Name"] as! String] != nil {
                let numberOfOccurrences = occurrencesOfItemsDict[item["Name"] as! String]
                occurrencesOfItemsDict[item["Name"] as! String] = numberOfOccurrences! + 1
            } else {
            // add key to the dictionary and set value to 1
                occurrencesOfItemsDict[item["Name"] as! String] = 1
            }
        }
        
        return occurrencesOfItemsDict
    }
}
