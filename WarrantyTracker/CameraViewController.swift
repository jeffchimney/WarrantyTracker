//
//  SecondViewController.swift
//  WarrantyTracker
//
//  Created by Jeff Chimney on 2016-05-20.
//  Copyright © 2016 Jeff Chimney. All rights reserved.
//

import UIKit

class CameraViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var staticTableView: UITableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var cameraView: UIImageView!
    @IBOutlet weak var receptView: UIImageView!
    @IBOutlet weak var captureButton: UITabBarItem!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailsTextField: UITextField!
    @IBOutlet weak var warrantyBeginsPicker: UIDatePicker!
    @IBOutlet weak var warrantyEndsPicker: UIDatePicker!
    @IBOutlet var numberOfWeeksSegmentControl: UISegmentedControl!
    @IBOutlet var tagsTextField: UITextField!
    
    @IBOutlet weak var saveEntryButton: UIButton!
    
    var textFieldSelected: Bool!
    var kbHeight: CGFloat!
    var imageToSave: UIImage!
    var receiptToSave: UIImage!
    
    var tappedView: UIView?
    
    var itemPhotoWasChanged = false
    var receiptPhotoWasChanged = false
    
    let cloudKitHelper = CloudKitHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        
        staticTableView.delegate = self
        staticTableView.dataSource = self
        
        titleTextField.delegate = self
        detailsTextField.delegate = self
        tagsTextField.delegate = self
        
        saveEntryButton.isUserInteractionEnabled = false
        saveEntryButton.tintColor = UIColor.lightGray()
        
        warrantyBeginsPicker.datePickerMode = UIDatePickerMode.date
        warrantyEndsPicker.datePickerMode = UIDatePickerMode.date
        
        numberOfWeeksSegmentControl.selectedSegmentIndex = 1
        
        cameraView.image = UIImage(named: "photoPlaceholder")
        cameraView.isUserInteractionEnabled = true
        
        receptView.image = UIImage(named: "receiptPlaceholder")
        receptView.isUserInteractionEnabled = true
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.imageTapped(_:)))
        let tapReceiptRecognizer = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.imageTapped(_:)))
        
        cameraView.addGestureRecognizer(tapRecognizer)
        receptView.addGestureRecognizer(tapReceiptRecognizer)
        
        self.navigationController?.navigationBar.isTranslucent = false;
        self.tabBarController?.tabBar.isTranslucent = false;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textFieldSelected = false
        
        // if using navbar, use 64 instead of 20 for inset.
        //staticTableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        staticTableView.allowsSelection = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default().removeObserver(self)
    }
    
    // preserve aspect ratio when scaling for Tesseract
    func scaleImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor: CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    func imageTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        let tappedImageView = gestureRecognizer.view!
        print("tap")
        
        // prompt to take picture of item
        if tappedImageView == cameraView {
            print("Tapped Camera")
            tappedView = cameraView
            
            // Set up camera view and provide options for upload.
            let imagePickerActionSheet = UIAlertController(title: "Take or Upload a Photo of the Item",
                                                           message: nil, preferredStyle: .actionSheet)
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let cameraButton = UIAlertAction(title: "Take Photo of Item",
                                                 style: .default) { (alert) -> Void in
                                                    let imagePicker = UIImagePickerController()
                                                    imagePicker.delegate = self
                                                    imagePicker.sourceType = .camera
                                                    self.present(imagePicker,
                                                                               animated: true,
                                                                               completion: nil)
                }
                imagePickerActionSheet.addAction(cameraButton)
            }
            let libraryButton = UIAlertAction(title: "Choose Existing",
                                              style: .default) { (alert) -> Void in
                                                let imagePicker = UIImagePickerController()
                                                imagePicker.delegate = self
                                                imagePicker.sourceType = .photoLibrary
                                                self.present(imagePicker,
                                                                           animated: true,
                                                                           completion: nil)
            }
            imagePickerActionSheet.addAction(libraryButton)
            let cancelButton = UIAlertAction(title: "Cancel",
                                             style: .cancel) { (alert) -> Void in
            }
            imagePickerActionSheet.addAction(cancelButton)
            present(imagePickerActionSheet, animated: true,
                                  completion: nil)
        } else {
            // prompt to take picture of receipt
            print("Tapped Receipt")
            tappedView = receptView
            
            // Set up camera view and provide options for upload.
            let imagePickerActionSheet = UIAlertController(title: "Take or Upload a Photo of Your Receipt",
                                                           message: nil, preferredStyle: .actionSheet)
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let cameraButton = UIAlertAction(title: "Take Photo of Receipt",
                                                 style: .default) { (alert) -> Void in
                                                    let imagePicker = UIImagePickerController()
                                                    imagePicker.delegate = self
                                                    imagePicker.sourceType = .camera
                                                    self.present(imagePicker,
                                                                               animated: true,
                                                                               completion: nil)
                }
                imagePickerActionSheet.addAction(cameraButton)
            }
            let libraryButton = UIAlertAction(title: "Choose Existing",
                                              style: .default) { (alert) -> Void in
                                                let imagePicker = UIImagePickerController()
                                                imagePicker.delegate = self
                                                imagePicker.sourceType = .photoLibrary
                                                self.present(imagePicker,
                                                                           animated: true,
                                                                           completion: nil)
            }
            imagePickerActionSheet.addAction(libraryButton)
            let cancelButton = UIAlertAction(title: "Cancel",
                                             style: .cancel) { (alert) -> Void in
            }
            imagePickerActionSheet.addAction(cancelButton)
            present(imagePickerActionSheet, animated: true,
                                  completion: nil)
        }
    }
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if tappedView == cameraView {
            let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
            let scaledImage = scaleImage(selectedPhoto, maxDimension: 640)
        
            cameraView.contentMode = .scaleAspectFit
            cameraView.image = scaledImage
        
            imageToSave = scaledImage
            
            itemPhotoWasChanged = true
            
            dismiss(animated: true, completion: nil)
        // handle choosing receipt picture
        } else if tappedView == receptView {
            let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
            let scaledImage = scaleImage(selectedPhoto, maxDimension: 640)
            
            receptView.contentMode = .scaleAspectFit
            receptView.image = scaledImage
            
            receiptToSave = scaledImage
            
            addActivityIndicator()
            
            receiptPhotoWasChanged = true
            
            dismiss(animated: true, completion: {
                // if we end up doing image recognition, delete removeactivityindicator and uncomment the next line
                self.removeActivityIndicator()
                //self.performImageRecognition(scaledImage)
            })
        }
    }
    
    func performImageRecognition(_ image: UIImage) {
        removeActivityIndicator()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if (imageToSave != nil && receiptToSave != nil && titleTextField.text != "" && detailsTextField.text != "") {
            saveEntryButton.isUserInteractionEnabled = true
            saveEntryButton.tintColor = UIColor.blue()
        }
    
        return true
    }
    
    // make sure that the start date is never later than the end date
    @IBAction func beginsDatePickerAction(_ sender: AnyObject) {
        print(warrantyBeginsPicker.date)
        
        switch warrantyBeginsPicker.date.compare(warrantyEndsPicker.date) {
            case .orderedAscending:
                print("StartDate is earlier than EndDate")
            case .orderedDescending:
                print("StartDate is later than EndDate")
                warrantyEndsPicker.date = warrantyBeginsPicker.date
            case .orderedSame:
                print("The two dates are the same")
        }
    }
    
    @IBAction func endsDatePickerAction(_ sender: AnyObject) {
        print(warrantyEndsPicker.date)
        switch warrantyBeginsPicker.date.compare(warrantyEndsPicker.date) {
            case .orderedAscending:
                print("StartDate is earlier than EndDate")
            case .orderedDescending:
                print("StartDate is later than EndDate")
                warrantyEndsPicker.date = warrantyBeginsPicker.date
            case .orderedSame:
                print("The two dates are the same")
        }
    }
    
    @IBAction func saveWarrantyButtonPressed(_ sender: AnyObject) {
        self.cloudKitHelper.saveEntryToCloud(imageToSave, receiptToSave: receiptToSave, label: titleTextField.text!, description: detailsTextField.text!, startDate: warrantyBeginsPicker.date, endDate: warrantyEndsPicker.date, weeksBeforeReminder: numberOfWeeksSegmentControl.selectedSegmentIndex+1, tags: tagsTextField.text!)
        
        let weeksBeforeReminder = (numberOfWeeksSegmentControl.selectedSegmentIndex+1)*7
        let dateToBeReminded =  Calendar.current().date(byAdding: .day, value: -weeksBeforeReminder, to: warrantyEndsPicker.date, options: [])
        
        print("Date to be reminded: \(dateToBeReminded)")
        print("Date Warranty ends \(warrantyEndsPicker.date)")
        
        let notification = UILocalNotification()
        notification.fireDate = dateToBeReminded
        notification.alertTitle = titleTextField.text!
        notification.alertBody = "This Warranty is about to Expire"
        notification.alertAction = "OK"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared().scheduleLocalNotification(notification)
    }
}

