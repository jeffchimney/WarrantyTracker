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
    
    var container = CKContainer.default()
    var publicDB : CKDatabase!
    var privateDB : CKDatabase!
    
    var searchBar:UISearchBar!
    
    var rowsInTable = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width-60, height: 20))
        
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()

        // on leaving search, reset results to all tags
        recordsMatchingSearch = recordsWithTag
        rowsInTable = recordsWithTag.count
        
        SelectedTagTableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        
        recordsMatchingSearch = []
        
        for record in 0...recordsWithTag.count-1 {
            let searchTerm = searchBar.text?.lowercased()
            let currentRecord = recordsWithTag[record]
            let recordTags = currentRecord["Tags"] as? String
            let recordTagsLowerCase = recordTags?.lowercased()
            
            // make sure there is a tag before trying to compare it
            if recordTags == nil {
                print("Found Nil")
            } else if recordTagsLowerCase!.contains(searchTerm!) {
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsInTable
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WarrantyTableViewCell
        let index = (indexPath as NSIndexPath).row
        let currentRecord = recordsWithTag[index]
        
        if recordsWithTag.count > 0 {
            cell.warrantyLabel.text = currentRecord["Title"] as? String
            cell.descriptionTextView.text = currentRecord["Description"] as? String
            
            let endDate = currentRecord["EndDate"] as! Date
            
            // format date properly as string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let endDateString = dateFormatter.string(from: endDate)
            cell.endDateLabel.text = endDateString
            
            let startDate = currentRecord["StartDate"] as! Date
            
            //format properly as string
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let startDateString = dateFormatter.string(from: startDate)
            cell.startDateLabel.text = startDateString
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchBar.text == "" {
            recordsMatchingSearch = recordsWithTag
            let recordTapped = recordsWithTag[(indexPath as NSIndexPath).row]
            
            recordToPass = recordTapped
            
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            let recordTapped = recordsMatchingSearch[(indexPath as NSIndexPath).row]
            
            recordToPass = recordTapped
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
        //self.navigationController?.pushViewController(detailsTableViewController, animated: true)
        performSegue(withIdentifier: "showRecordDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
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
    
    func getRecordsWithTag(_ tag: String) {
        let predicate = Predicate(value: true)
        let query = CKQuery(recordType: "Record", predicate: predicate)
        //query.sortDescriptors = [NSSortDescriptor(key: "Name", ascending: true)]
        
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results, error) in
            
            // tell the table how many rows it should have
            self.records = results!
            
            DispatchQueue.main.async(execute: { () -> Void in
                for record in self.records {
                    print(record["Tags"]!)
                    let currentRecordTags = record["Tags"]! as? String
                    if (currentRecordTags!.contains(tag)) {
                        self.recordsWithTag.append(record)
                    }
                }
                self.rowsInTable = self.recordsWithTag.count
                self.SelectedTagTableView.reloadData()
            })
        })
    }
}
