//
//  PreferencesView.swift
//  WorldTime
//
//  Created by Benjamin Rohald on 5/4/20.
//  Copyright © 2020 Benjamin Rohald. All rights reserved.
//

import Cocoa

class PreferencesView: NSView, LoadableView {

    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var timezoneIDsPopup: NSPopUpButton!
    
    
    // MARK: - Init
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        if load(fromNIBNamed: "PreferencesView") {
            populateTimezoneIDs()
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - Custom Fileprivate Methods
    
    fileprivate func populateTimezoneIDs() {
        // Remove default items from the popup button.
        timezoneIDsPopup.removeAllItems()
        
        // Populate all available timezone identifiers to the popup.
        // Since this is a demo app there's no need to apply any formatting.
        for areaID in TimeZone.knownTimeZoneIdentifiers {
            timezoneIDsPopup.addItem(withTitle: areaID)
        }
        
        // If a timezone had been previously selected, then select it automatically.
        guard let preferredTimezoneID = UserDefaults.standard.string(forKey: "timezoneID") else { return }
        timezoneIDsPopup.selectItem(withTitle: preferredTimezoneID)
    }
    

    
    // MARK: - IBAction Methods
        
    @IBAction func applySelection(_ sender: Any) {
        UserDefaults.standard.set(timezoneIDsPopup.titleOfSelectedItem, forKey: "timezoneID")
        dismissPreferences(self)
    }
    
    
    @IBAction func dismissPreferences(_ sender: Any) {
        self.window?.performClose(self)
    }
    
}
