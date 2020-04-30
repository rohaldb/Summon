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
    var hotKeysController: HotKeysController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setUpHotKeys()
        setUpStatusBar()
    }
    
    func setUpHotKeys() {
        hotKeysController = HotKeysController()
        menu?.delegate = hotKeysController
    }
    
    func setUpStatusBar() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let itemImage = NSImage(named: "menubaricon")
        itemImage?.isTemplate = true
        statusBarItem?.button?.image = itemImage

        if let menu = menu {
            statusBarItem?.menu = menu
        }
        
        showPreferences(self)
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
    
}

