//
//  UIBarButtonItem+hide.swift
//  Snacktacular
//
//  Created by Derek Marble on 4/20/22.
//

import UIKit

extension UIBarButtonItem {
    func hide() {
        self.isEnabled = false
        self.tintColor = .clear
    }
}
