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
    
    var container = CKContainer.default()
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
    
    var recordToPass:CKRecord?
    
    var searchBar:UISearchBar!
    
    @IBOutlet weak var recentOrExpiringControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width-40, height: 20))
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        // load cloudkit assets or later use
        getAssetsFromCloudKitByRecent()
        
        if activeRecordsList.count != 0 {
            rowsInTable = activeRecordsList.count
        } else {
            // load cloudkit assets or later use
            getAssetsFromCloudKitByRecent()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        
        // on leaving search, reset results to all tags
        activeRecordsList = warrantyRecords
        rowsInTable = activeRecordsList.count
        
        WarrantiesTableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        
        recordsMatchingSearch = []
        
        for record in 0...warrantyRecords.count-1 {
            let searchTerm = searchBar.text?.lowercased()
            let currentRecord = warrantyRecords[record]
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
        WarrantiesTableView.reloadData()
    }
    
    @IBAction func toggleRecentExpiringControllerChanged(sender: AnyObject) {
        // if recent is selected
        if recentOrExpiringControl.selectedSegmentIndex == 0 {
            
        } else {
        // if expiring is selected
            
        }
    }
    

    // MARK: - UITableViewDataSource Delegate Methods
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsInTable // number of entries in cloudkit or items matching search
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //if (activeRecordsList.count == 0) {
        if searchBar.text == "" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! WarrantyTableViewCell
            let index = indexPath.row
            let currentRecord = warrantyRecords[index]
            
            // populate cells with info from cloudkit
            cell.warrantyLabel.text = currentRecord["Title"] as? String
            cell.descriptionTextView.text = currentRecord["Description"] as? String
            let endDate = currentRecord["EndDate"] as! NSDate
        
            // format date properly as string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let endDateString = dateFormatter.string(from: endDate as Date)
            cell.endDateLabel.text = endDateString
            
            let startDate = currentRecord["StartDate"] as! NSDate
            
            //format properly as string
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let startDateString = dateFormatter.string(from: startDate as Date)
            cell.startDateLabel.text = startDateString
        
            return cell
        // if the user has entered a search term, only show those items that have a matching tag
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! WarrantyTableViewCell
            let index = indexPath.row
            let currentRecord = recordsMatchingSearch[index]
            
            // populate cells with info from cloudkit
            cell.warrantyLabel.text = currentRecord["Title"] as? String
            cell.descriptionTextView.text = currentRecord["Description"] as? String
            let endDate = currentRecord["EndDate"] as! NSDate
            
            // format date properly as string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let endDateString = dateFormatter.string(from: endDate as Date)
            cell.endDateLabel.text = endDateString
            
            let startDate = currentRecord["StartDate"] as! NSDate
            
            //format properly as string
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let startDateString = dateFormatter.string(from: startDate as Date)
            cell.startDateLabel.text = startDateString
            
            return cell
        }
    } //else {
//            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! WarrantyTableViewCell
//            let index = indexPath.row
//            let currentRecord = activeRecordsList[index]
//            
//            // populate cells with info from cloudkit
//            cell.warrantyLabel.text = currentRecord["Title"] as? String
//            cell.descriptionTextView.text = currentRecord["Description"] as? String
//            let endDate = currentRecord["EndDate"] as! NSDate
//            
//            // format date properly as string
//            let dateFormatter = NSDateFormatter()
//            dateFormatter.dateFormat = "dd/MM/yyyy"
//            let endDateString = dateFormatter.stringFromDate(endDate)
//            cell.endDateLabel.text = endDateString
//            
//            let startDate = currentRecord["StartDate"] as! NSDate
//            
//            //format properly as string
//            dateFormatter.dateFormat = "dd/MM/yyyy"
//            let startDateString = dateFormatter.stringFromDate(startDate)
//            cell.startDateLabel.text = startDateString
//            
//            return cell
//        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchBar.text == "" {
            activeRecordsList = warrantyRecords
            let recordTapped = warrantyRecords[indexPath.row]
        
            recordToPass = recordTapped
        
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        } else {
            activeRecordsList = recordsMatchingSearch
            let recordTapped = recordsMatchingSearch[indexPath.row]
            
            recordToPass = recordTapped
            
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
        //self.navigationController?.pushViewController(detailsTableViewController, animated: true)
        performSegue(withIdentifier: "showDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailsTableViewController = segue.destination as! DetailsTableViewController
        
        detailsTableViewController.recordToReceive = recordToPass
        detailsTableViewController.itemWasInRecordsList = activeRecordsList
    }
    
    // MARK: - CloudKit 'Get'  Methods
    
    func getAssetsFromCloudKitByRecent() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Record", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "StartDate", ascending: false)]
        
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results, error) in
            
            // tell the table how many rows it should have
            self.rowsInTable = (results?.count)!
            self.recordsMatchingSearch = results!
            self.warrantyRecords = results!
            
            DispatchQueue.main.async {
                self.WarrantiesTableView.reloadData()
            }
        })
    }
    
    func getAssetsFromCloudKitByExpiring() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Record", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "EndDate", ascending: true)]
        
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results, error) in
            
            // tell the table how many rows it should have
            self.rowsInTable = (results?.count)!
            self.recordsMatchingSearch = results!
            self.warrantyRecordsByExpiring = results!
            
            DispatchQueue.main.async{
                self.WarrantiesTableView.reloadData()
            }
        })
    }
}

