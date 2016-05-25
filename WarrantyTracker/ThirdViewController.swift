//
//  ThirdViewController.swift
//  WarrantyTracker
//
//  Created by Jeff Chimney on 2016-05-24.
//  Copyright © 2016 Jeff Chimney. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {
    
    @IBOutlet weak var cameraView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up camera view
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .Camera
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

