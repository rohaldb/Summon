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


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
//        hotKey = HotKey(keyCombo: KeyCombo(key: .c, modifiers: [.command, .option]))
        addApplicationToStatusBar()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    let statusBarItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

    
    func addApplicationToStatusBar() {
        statusBarItem.button?.title = "👮🏽‍♀️"
        
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(launchSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusBarItem.menu = menu

//
//        let statusBarMenu = NSMenu()
//        statusBarItem.menu = statusBarMenu
//
//        statusBarMenu.addItem(
//            withTitle: "Summon Chrome",
//            action: #selector(AppDelegate.summonChrome),
//            keyEquivalent: "")
    }
    
    var myWindow: NSWindow? = nil

    @objc func launchSettings() {
        let storyboard = NSStoryboard(name: "Main",bundle: nil)
        let controller: ViewController = storyboard.instantiateController(withIdentifier: "ViewControllerID") as! ViewController
        myWindow = NSWindow(contentViewController: controller)
        myWindow?.makeKeyAndOrderFront(self)
        let vc = NSWindowController(window: myWindow)
        vc.showWindow(self)
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

