//
//  AppDelegate.swift
//  Summon
//
//  Created by Benjamin Rohald on 5/4/20.
//  Copyright © 2020 Benjamin Rohald. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem?
    @IBOutlet weak var menu: NSMenu?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let itemImage = NSImage(named: "rank")
        itemImage?.isTemplate = true
        statusItem?.button?.image = itemImage

        if let menu = menu {
            statusItem?.menu = menu
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    

    @objc func summonChrome() {
        print("Summoning Chrome")
        let runningApps = NSWorkspace.shared.runningApplications
        let chrome = runningApps.first{$0.localizedName == "Google Chrome"}
        if let runningChrome = chrome {
            runningChrome.activate(options: [.activateIgnoringOtherApps, .activateAllWindows])
        } else {
            print("Chrome is not open")
        }
    }
}

