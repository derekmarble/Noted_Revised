//
//  UploadTableViewCell.swift
//  Noted
//
//  Created by Derek Marble on 4/25/22.
//

import UIKit

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
} ()

class UploadTableViewCell: UITableViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var dateUploadedLabel: UILabel!
    
    var upload: Upload! {
        didSet {
            descriptionLabel.text = upload.titleOrDescription
            dateUploadedLabel.text = "\(dateFormatter.string(from: upload.date))"
        }
    }



}
