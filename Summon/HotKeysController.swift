//
//  HotKeysController.swift
//  Summon
//
//  Created by Benjamin Rohald on 12/4/20.
//  Copyright © 2020 Benjamin Rohald. All rights reserved.
//
import HotKey
import Foundation
import AppKit

class HotKeysController: NSObject {
    
    private var hotkeys = [HotKey]()
    
    override init() {
        super.init()
    }
    
    public func addHotkey(key: Key, modifiers: NSEvent.ModifierFlags, applicationName: String) {
        let hotkey = HotKey(key: key, modifiers: [.command, .control])
        hotkey.keyDownHandler = self.getHandler(key: key, applicationName: applicationName)
        self.hotkeys.append(hotkey)
    }
    
    private func getHandler(key: Key, applicationName: String) -> (() -> Void) {
        return { [weak self] in

            guard self != nil else { return }
            
            print("hotkey: \(key.description), command: \(applicationName)")

            let runningApps = NSWorkspace.shared.runningApplications
            let chrome = runningApps.first{$0.localizedName == applicationName}
            if let runningChrome = chrome {
                runningChrome.activate(options: [.activateIgnoringOtherApps, .activateAllWindows])
            } else {
                print(applicationName, " is not open")
            }
        }
    }
    
    func enableHotKeys() {
        //need to add all hotkeys
    }
    
    func disableHotKeys() {
        //need to add all hotkeys
    }

}

// work around https://github.com/soffes/HotKey/issues/17
extension HotKeysController: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        disableHotKeys()
    }

    func menuDidClose(_ menu: NSMenu) {
        enableHotKeys()
    }
}
