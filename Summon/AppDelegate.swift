//
//  AppDelegate.swift
//  Summon
//
//  Created by Benjamin Rohald on 5/4/20.
//  Copyright © 2020 Benjamin Rohald. All rights reserved.
//

import Cocoa
import HotKey


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private var hotKey: HotKey? {
        didSet {
            guard let hotKey = hotKey else {
                print("unrecognised")
                return
            }

            hotKey.keyDownHandler = {
                print("Hotkey detected")
                self.summonChrome()
            }
        }
    }
    
    let statusBarItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

    
    @objc func launchSettings() {
        print(NSApp.mainWindow)
        print(NSApp.windows[2].isVisible)
        NSApp.windows[2].makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        addApplicationToStatusBar()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    

    
    func addApplicationToStatusBar() {
        statusBarItem.button?.title = "👮🏽‍♀️"
        
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(launchSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusBarItem.menu = menu
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

