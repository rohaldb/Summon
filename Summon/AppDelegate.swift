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
    
    var settingsWindow: NSWindow?
    var statusBarItem: NSStatusItem?
    @IBOutlet weak var menu: NSMenu?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setUpStatusBar()
    }
    
    func setUpStatusBar() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let itemImage = NSImage(named: "rank")
        itemImage?.isTemplate = true
        statusBarItem?.button?.image = itemImage

        if let menu = menu {
            statusBarItem?.menu = menu
        }
    }
    
    @IBAction func showPreferences(_ sender: Any) {
        if settingsWindow == nil {
            instantiateSettingsWindow()
        }
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow!.makeKeyAndOrderFront(nil)
    }
    
    func instantiateSettingsWindow() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: .init(stringLiteral: "preferencesID")) as? ViewController else { return }
        settingsWindow = NSWindow(contentViewController: vc)
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

