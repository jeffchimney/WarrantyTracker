//
//  WarrantyTableViewCell.swift
//  WarrantyTracker
//
//  Created by Jeff Chimney on 2016-05-25.
//  Copyright © 2016 Jeff Chimney. All rights reserved.
//

import Foundation

class WarrantyTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var warrantyLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
}
