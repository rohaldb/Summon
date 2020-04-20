//
//  ApplicationCellView.swift
//  Summon
//
//  Created by Benjamin Rohald on 19/4/20.
//  Copyright © 2020 Benjamin Rohald. All rights reserved.
//

import Foundation
import Cocoa

class ApplicationCellView: NSTableCellView {

    @IBOutlet weak var icon: NSImageView!
    @IBOutlet weak var nameField: NSTextField!
    
    @IBOutlet weak var bindButton: NSButton!
    @IBOutlet weak var deleteButton: NSButton!
    
}
