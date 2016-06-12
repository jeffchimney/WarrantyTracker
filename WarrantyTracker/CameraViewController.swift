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
        activityIndicator.hidden = true
        
        staticTableView.delegate = self
        staticTableView.dataSource = self
        
        titleTextField.delegate = self
        detailsTextField.delegate = self
        tagsTextField.delegate = self
        
        saveEntryButton.userInteractionEnabled = false
        saveEntryButton.tintColor = UIColor.lightGrayColor()
        
        warrantyBeginsPicker.datePickerMode = UIDatePickerMode.Date
        warrantyEndsPicker.datePickerMode = UIDatePickerMode.Date
        
        numberOfWeeksSegmentControl.selectedSegmentIndex = 1
        
        cameraView.image = UIImage(named: "photoPlaceholder")
        cameraView.userInteractionEnabled = true
        
        receptView.image = UIImage(named: "receiptPlaceholder")
        receptView.userInteractionEnabled = true
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.imageTapped(_:)))
        let tapReceiptRecognizer = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.imageTapped(_:)))
        
        cameraView.addGestureRecognizer(tapRecognizer)
        receptView.addGestureRecognizer(tapReceiptRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        textFieldSelected = false
        
        // if using navbar, use 64 instead of 20 for inset.
        //staticTableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        staticTableView.allowsSelection = false
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // preserve aspect ratio when scaling for Tesseract
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
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
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func imageTapped(gestureRecognizer: UITapGestureRecognizer) {
        let tappedImageView = gestureRecognizer.view!
        print("tap")
        
        // prompt to take picture of item
        if tappedImageView == cameraView {
            print("Tapped Camera")
            tappedView = cameraView
            
            // Set up camera view and provide options for upload.
            let imagePickerActionSheet = UIAlertController(title: "Take or Upload a Photo of the Item",
                                                           message: nil, preferredStyle: .ActionSheet)
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                let cameraButton = UIAlertAction(title: "Take Photo of Item",
                                                 style: .Default) { (alert) -> Void in
                                                    let imagePicker = UIImagePickerController()
                                                    imagePicker.delegate = self
                                                    imagePicker.sourceType = .Camera
                                                    self.presentViewController(imagePicker,
                                                                               animated: true,
                                                                               completion: nil)
                }
                imagePickerActionSheet.addAction(cameraButton)
            }
            let libraryButton = UIAlertAction(title: "Choose Existing",
                                              style: .Default) { (alert) -> Void in
                                                let imagePicker = UIImagePickerController()
                                                imagePicker.delegate = self
                                                imagePicker.sourceType = .PhotoLibrary
                                                self.presentViewController(imagePicker,
                                                                           animated: true,
                                                                           completion: nil)
            }
            imagePickerActionSheet.addAction(libraryButton)
            let cancelButton = UIAlertAction(title: "Cancel",
                                             style: .Cancel) { (alert) -> Void in
            }
            imagePickerActionSheet.addAction(cancelButton)
            presentViewController(imagePickerActionSheet, animated: true,
                                  completion: nil)
        } else {
            // prompt to take picture of receipt
            print("Tapped Receipt")
            tappedView = receptView
            
            // Set up camera view and provide options for upload.
            let imagePickerActionSheet = UIAlertController(title: "Take or Upload a Photo of Your Receipt",
                                                           message: nil, preferredStyle: .ActionSheet)
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                let cameraButton = UIAlertAction(title: "Take Photo of Receipt",
                                                 style: .Default) { (alert) -> Void in
                                                    let imagePicker = UIImagePickerController()
                                                    imagePicker.delegate = self
                                                    imagePicker.sourceType = .Camera
                                                    self.presentViewController(imagePicker,
                                                                               animated: true,
                                                                               completion: nil)
                }
                imagePickerActionSheet.addAction(cameraButton)
            }
            let libraryButton = UIAlertAction(title: "Choose Existing",
                                              style: .Default) { (alert) -> Void in
                                                let imagePicker = UIImagePickerController()
                                                imagePicker.delegate = self
                                                imagePicker.sourceType = .PhotoLibrary
                                                self.presentViewController(imagePicker,
                                                                           animated: true,
                                                                           completion: nil)
            }
            imagePickerActionSheet.addAction(libraryButton)
            let cancelButton = UIAlertAction(title: "Cancel",
                                             style: .Cancel) { (alert) -> Void in
            }
            imagePickerActionSheet.addAction(cancelButton)
            presentViewController(imagePickerActionSheet, animated: true,
                                  completion: nil)
        }
    }
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
    
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if tappedView == cameraView {
            let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
            let scaledImage = scaleImage(selectedPhoto, maxDimension: 640)
        
            cameraView.contentMode = .ScaleAspectFit
            cameraView.image = scaledImage
        
            imageToSave = scaledImage
            
            itemPhotoWasChanged = true
            
            dismissViewControllerAnimated(true, completion: nil)
        // handle choosing receipt picture
        } else if tappedView == receptView {
            let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
            let scaledImage = scaleImage(selectedPhoto, maxDimension: 640)
            
            receptView.contentMode = .ScaleAspectFit
            receptView.image = scaledImage
            
            receiptToSave = scaledImage
            
            addActivityIndicator()
            
            receiptPhotoWasChanged = true
            
            dismissViewControllerAnimated(true, completion: {
                // if we end up doing image recognition, delete removeactivityindicator and uncomment the next line
                self.removeActivityIndicator()
                //self.performImageRecognition(scaledImage)
            })
        }
    }
    
    func performImageRecognition(image: UIImage) {
        let tesseract = G8Tesseract()
        // set language to english
        tesseract.language = "eng"
        // .TesseractOnly, is the fastest, least accurate method
        //.CubeOnly is slower more accurate since it employs more artificial intelligence
        //.TesseractCubeCombined, which runs both is slowest, most accurate
        tesseract.engineMode = .TesseractCubeCombined
        tesseract.pageSegmentationMode = .Auto
        tesseract.maximumRecognitionTime = 60.0
        // desaturates image, increases contrast
        tesseract.image = image.g8_blackAndWhite()
        tesseract.recognize()
        // print the recognized text
        print(tesseract.recognizedText)
        //textView.editable = true
        removeActivityIndicator()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if (imageToSave != nil && receiptToSave != nil && titleTextField.text != "" && detailsTextField.text != "") {
            saveEntryButton.userInteractionEnabled = true
            saveEntryButton.tintColor = UIColor.blueColor()
        }
    
        return true
    }
    
    // make sure that the start date is never later than the end date
    @IBAction func beginsDatePickerAction(sender: AnyObject) {
        print(warrantyBeginsPicker.date)
        
        switch warrantyBeginsPicker.date.compare(warrantyEndsPicker.date) {
            case .OrderedAscending:
                print("StartDate is earlier than EndDate")
            case .OrderedDescending:
                print("StartDate is later than EndDate")
                warrantyEndsPicker.date = warrantyBeginsPicker.date
            case .OrderedSame:
                print("The two dates are the same")
        }
    }
    
    @IBAction func endsDatePickerAction(sender: AnyObject) {
        print(warrantyEndsPicker.date)
        switch warrantyBeginsPicker.date.compare(warrantyEndsPicker.date) {
            case .OrderedAscending:
                print("StartDate is earlier than EndDate")
            case .OrderedDescending:
                print("StartDate is later than EndDate")
                warrantyEndsPicker.date = warrantyBeginsPicker.date
            case .OrderedSame:
                print("The two dates are the same")
        }
    }
    
    @IBAction func saveWarrantyButtonPressed(sender: AnyObject) {
        self.cloudKitHelper.saveEntryToCloud(imageToSave, receiptToSave: receiptToSave, label: titleTextField.text!, description: detailsTextField.text!, startDate: warrantyBeginsPicker.date, endDate: warrantyEndsPicker.date, weeksBeforeReminder: numberOfWeeksSegmentControl.selectedSegmentIndex+1, tags: tagsTextField.text!)
    }
}

