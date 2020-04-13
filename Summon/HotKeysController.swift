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
    
    public func addHotkey(keyCombo: KeyCombo, applicationName: String) {
        print("Adding hotkey: \(keyCombo) -> \(applicationName)")
        let hotkey = HotKey(keyCombo: keyCombo)
        hotkey.keyDownHandler = self.getHandler(applicationName: applicationName)
        self.hotkeys.append(hotkey)
    }
    
    private func getHandler(applicationName: String) -> (() -> Void) {
        return { [weak self] in

            guard self != nil else { return }
            
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
