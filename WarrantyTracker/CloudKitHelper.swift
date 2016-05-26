//
//  CloudKitHelper.swift
//  WarrantyTracker
//
//  Created by Jeff Chimney on 2016-05-25.
//  Copyright © 2016 Jeff Chimney. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitHelper {
    var container : CKContainer
    var publicDB : CKDatabase
    let privateDB : CKDatabase
    
    var returnedHeight = ""
    var returnedWeight = ""
    var returnedComfortableWalk = ""
    var returnedHardWalk = ""
    var returnedImpossibleWalk = ""
    var returnedHeightSystem = ""
    var returnedWeightSystem = ""
    var returnedDistanceSystem = ""
    
    init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }
    
    func saveDeviceIdRecord(deviceId : String) {
        let deviceIdRecordName = CKRecordID(recordName: deviceId)
        let deviceIdRecord = CKRecord(recordType: "User", recordID: deviceIdRecordName)
        
        publicDB.fetchRecordWithID(deviceIdRecordName, completionHandler: { record, error in
            if error != nil {
                print("Record was not found, so one was created.")
                deviceIdRecord.setValue(deviceId, forKey: "DeviceId")
                self.publicDB.saveRecord(deviceIdRecord, completionHandler: {(_,error) -> Void in
                    if (error != nil) {
                        print(error)
                    }
                })
            } else {
                record!.setObject(deviceId, forKey: "DeviceId")
                self.publicDB.saveRecord(record!, completionHandler: {(_,error) -> Void in
                    if (error != nil) {
                        print(error)
                    }
                })
            }
            
        })
    }
    
    func saveEntryToCloud(imageToSave: UIImage, receiptToSave: UIImage, label: String, description: String, startDate: NSDate, endDate: NSDate) {
        let newRecord:CKRecord = CKRecord(recordType: "Image")
        let filename = NSProcessInfo.processInfo().globallyUniqueString + ".png"
        let receiptFilename = NSProcessInfo.processInfo().globallyUniqueString + ".png"
        let url = NSURL.fileURLWithPath(NSTemporaryDirectory()).URLByAppendingPathComponent(filename)
        let receiptURL = NSURL.fileURLWithPath(NSTemporaryDirectory()).URLByAppendingPathComponent(receiptFilename)
        
        do {
            let data = UIImagePNGRepresentation(imageToSave)!
            try data.writeToURL(url, options: NSDataWritingOptions.AtomicWrite)
            let asset = CKAsset(fileURL: url)
            newRecord["Image"] = asset
            
            let receiptData = UIImagePNGRepresentation(receiptToSave)!
            try receiptData.writeToURL(receiptURL, options: NSDataWritingOptions.AtomicWrite)
            let receiptAsset = CKAsset(fileURL: receiptURL)
            newRecord["Receipt"] = receiptAsset
        
            newRecord["Title"] = label
            newRecord["Description"] = description
            newRecord["StartDate"] = startDate
            newRecord["EndDate"] = endDate
        }
        catch {
            print("Error writing data", error)
        }
        
        privateDB.saveRecord(newRecord, completionHandler: { (_, error) -> Void in
            if error != nil {
                NSLog(error!.localizedDescription)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    print("finished")
                }
            }
        })
    }
}