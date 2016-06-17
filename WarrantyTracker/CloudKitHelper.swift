//
//  CloudKitHelper.swift
//  WarrantyTracker
//
//  Created by Jeff Chimney on 2016-05-25.
//  Copyright © 2016 Jeff Chimney. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class CloudKitHelper {
    var container : CKContainer
    var publicDB : CKDatabase
    let privateDB : CKDatabase
    let defaults = UserDefaults()
    
    var returnedHeight = ""
    var returnedWeight = ""
    var returnedComfortableWalk = ""
    var returnedHardWalk = ""
    var returnedImpossibleWalk = ""
    var returnedHeightSystem = ""
    var returnedWeightSystem = ""
    var returnedDistanceSystem = ""
        
    init() {
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }
    
    func saveDeviceIdRecord(_ deviceId : String) {
        let deviceIdRecordName = CKRecordID(recordName: deviceId)
        let deviceIdRecord = CKRecord(recordType: "User", recordID: deviceIdRecordName)
        
        publicDB.fetch(withRecordID: deviceIdRecordName, completionHandler: { record, error in
            if error != nil {
                print("Record was not found, so one was created.")
                deviceIdRecord.setValue(deviceId, forKey: "DeviceId")
                self.publicDB.save(deviceIdRecord, completionHandler: {(_,error) -> Void in
                    if (error != nil) {
                        print(error)
                    }
                })
            } else {
                record!.setObject(deviceId, forKey: "DeviceId")
                self.publicDB.save(record!, completionHandler: {(_,error) -> Void in
                    if (error != nil) {
                        print(error)
                    }
                })
            }
            
        })
    }
    
    func saveEntryToCloud(_ imageToSave: UIImage, receiptToSave: UIImage, label: String, description: String, startDate: Date, endDate: Date, weeksBeforeReminder: Int, tags: String) {
        let newRecord:CKRecord = CKRecord(recordType: "Record")
        let newImagesRecord: CKRecord = CKRecord(recordType: "ImagesForRecord")
        let filename = ProcessInfo.processInfo().globallyUniqueString + ".png"
        let receiptFilename = ProcessInfo.processInfo().globallyUniqueString + ".png"
        let url = try! URL(fileURLWithPath: NSTemporaryDirectory().appending(filename))
        let receiptURL = try! URL(fileURLWithPath: NSTemporaryDirectory().appending(receiptFilename))
        
        do {
            let data = UIImagePNGRepresentation(imageToSave)!
            try data.write(to: url, options: NSData.WritingOptions.atomicWrite)
            let asset = CKAsset(fileURL: url)
            newImagesRecord["Item"] = asset
            
            let receiptData = UIImagePNGRepresentation(receiptToSave)!
            try receiptData.write(to: receiptURL, options: NSData.WritingOptions.atomicWrite)
            let receiptAsset = CKAsset(fileURL: receiptURL)
            newImagesRecord["Receipt"] = receiptAsset
            
            let recordReference: CKReference = CKReference(recordID: newRecord.recordID, action: CKReferenceAction.deleteSelf)
            newImagesRecord["AssociatedRecord"] = recordReference
        
            newRecord["Title"] = label
            newRecord["Description"] = description
            newRecord["StartDate"] = startDate
            newRecord["EndDate"] = endDate
            newRecord["WeeksBeforeReminder"] = weeksBeforeReminder
            newRecord["Tags"] = tags
        }
        catch {
            print("Error writing data", error)
        }
        
        saveRecordLocally(record: newRecord)
        
        privateDB.save(newRecord, completionHandler: { (_, error) -> Void in
            if error != nil {
                NSLog(error!.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    print("Finished Saving Info")
                }
            }
        })
        
        privateDB.save(newImagesRecord, completionHandler: { (_, error) -> Void in
            if error != nil {
                NSLog(error!.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    print("Finished Saving Images")
                }
            }
        })
        
        // save each tag to Tag table
        let tagArray = tags.components(separatedBy: ",")
        var tagRecordArray: [CKRecord] = []
        
        // trim whitespace from each entry in tagArray (only leading and trailing whitespace)
        for tag in tagArray {
            let trimmedTag = tag.trimmingCharacters(in: CharacterSet.whitespaces)
            
            let newTagRecord: CKRecord = CKRecord(recordType: "Tag")
            
            let recordReference: CKReference = CKReference(recordID: newRecord.recordID, action: CKReferenceAction.deleteSelf)
            
            newTagRecord["Name"] = trimmedTag
            newTagRecord["Record"] = recordReference
            
            tagRecordArray.append(newTagRecord)
            
            privateDB.save(newTagRecord, completionHandler: { (_, error) -> Void in
                if error != nil {
                    NSLog(error!.localizedDescription)
                } else {
                    DispatchQueue.main.async {
                        print("Finished Saving Tags")
                    }
                }
            })
        }
    
        saveTagRecordsLocally(records: tagRecordArray)
    }
    
    // MARK: - UserDefaults 'Set'  Method
    func saveRecordLocally(record: CKRecord) {
        // Get records form User Defaults
        let data = UserDefaults.standard().object(forKey: "EncodedRecords") as? [Data] ?? [Data]()
        var decryptedRecords: [CKRecord] = []
        for encodedRecord in data {
            let decryptedRecord = NSKeyedUnarchiver.unarchiveObject(with: encodedRecord) as! CKRecord
            decryptedRecords.append(decryptedRecord)
        }
        
        var encodedRecords: [Data] = []
        if decryptedRecords.count != 0 {
            decryptedRecords.append(record)
            
            for record in decryptedRecords {
                let encodedRecord = NSKeyedArchiver.archivedData(withRootObject: record)
                
                encodedRecords.append(encodedRecord)
            }
            
            UserDefaults.standard().set(encodedRecords, forKey: "EncodedRecords")
        } else {
            // this is the first record entered.  Save it.
            let encodedRecord = NSKeyedArchiver.archivedData(withRootObject: record)
            let encodedRecords = [encodedRecord]
            UserDefaults.standard().set(encodedRecords, forKey: "EncodedRecords")
        }
    }
    
    // MARK: - UserDefaults 'Set'  Method
    func saveTagRecordsLocally(records: [CKRecord]) {
        // Get records form User Defaults
        let data = UserDefaults.standard().object(forKey: "EncodedTagRecords") as? [Data] ?? [Data]()
        var decryptedRecords: [CKRecord] = []
        for encodedRecord in data {
            let decryptedRecord = NSKeyedUnarchiver.unarchiveObject(with: encodedRecord) as! CKRecord
            decryptedRecords.append(decryptedRecord)
        }
        
        var encodedRecords: [Data] = []
        if decryptedRecords.count != 0 {
            
            for record in records {
                decryptedRecords.append(record)
            }
            
            for record in decryptedRecords {
                let encodedRecord = NSKeyedArchiver.archivedData(withRootObject: record)
                
                encodedRecords.append(encodedRecord)
            }
            
            UserDefaults.standard().set(encodedRecords, forKey: "EncodedTagRecords")
        } else {
            // this is the first record entered.  Save it.
            var encodedRecords: [Data] = []
            for record in records {
                let encodedRecord = NSKeyedArchiver.archivedData(withRootObject: record)
                encodedRecords.append(encodedRecord)
            }
            UserDefaults.standard().set(encodedRecords, forKey: "EncodedTagRecords")
        }
    }
}
