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

    public var hotKeys = [String:HotKeyMetaData]()
    
    override init() {
        super.init()
    }
    
    public func addHotKey(char: String, keyCode: UInt16, modifiers: NSEvent.ModifierFlags, applicationName: String) {
        
        let carbonKeyCode = UInt32(keyCode)
        
        let keyCombo = KeyCombo(carbonKeyCode: carbonKeyCode, carbonModifiers: modifiers.carbonFlags)

        let hotKey = HotKey(keyCombo: keyCombo)
        hotKey.keyDownHandler = self.getHandler(applicationName: applicationName)
        
        let summary = buildStringSummarOfHotKey(char: char, modifiers: modifiers)
        
        hotKeys[applicationName] = HotKeyMetaData(hotKey: hotKey, modifiers: modifiers, keyCode: carbonKeyCode, char: char, summary: summary)
        
        print("Adding hotkey: \(keyCombo) -> \(applicationName)")
    }
    
    public func removeHotKey(applicationName: String) {
        hotKeys.removeValue(forKey: applicationName)
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
    
    private func buildStringSummarOfHotKey(char: String, modifiers: NSEvent.ModifierFlags) -> String {
        var stringBuilder = ""
            
        if modifiers.contains(.control) {
           stringBuilder += "⌃"
        }
        if modifiers.contains(.option) {
           stringBuilder += "⌥"
        }
        if modifiers.contains(.command) {
           stringBuilder += "⌘"
        }
        if modifiers.contains(.shift) {
           stringBuilder += "⇧"
        }
        
        stringBuilder += char
        
        return stringBuilder
    }
    
    
    func enableHotKeys() {
        //need to add all hotkeys
    }
    
    func disableHotKeys() {
        //need to add all hotkeys
    }

}

struct HotKeyMetaData {
    var hotKey: HotKey
    var modifiers: NSEvent.ModifierFlags
    var keyCode: UInt32
    var char: String
    var summary: String
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
