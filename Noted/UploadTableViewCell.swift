//
//  UploadTableViewCell.swift
//  Noted
//
//  Created by Derek Marble on 4/25/22.
//

import UIKit

class UploadTableViewCell: UITableViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var dateUploadedLabel: UILabel!
    
    var upload: Upload! {
        didSet {
            descriptionLabel.text = upload.titleOrDescription
        }
    }



}
