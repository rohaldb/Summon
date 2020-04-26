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

    public var hotKeysMetaData = [String:HotKeyMetaData]()
    public var hotKeys = [String:HotKey]()
    
    override init() {
        super.init()
    }
    
    public func addHotKey(char: String, keyCode: UInt16, modifiers: NSEvent.ModifierFlags, applicationName: String) {
        
        let carbonKeyCode = UInt32(keyCode)
        
        let keyCombo = KeyCombo(carbonKeyCode: carbonKeyCode, carbonModifiers: modifiers.carbonFlags)

        let hotKey = HotKey(keyCombo: keyCombo)
        hotKey.keyDownHandler = self.getHandler(applicationName: applicationName)
                
        let hotKeyMetaData = HotKeyMetaData.init(
            control: modifiers.contains(.control),
            command: modifiers.contains(.command),
            shift: modifiers.contains(.shift),
            option: modifiers.contains(.option),
            keyCode: carbonKeyCode,
            char: char
        )
        
        hotKeysMetaData[applicationName] = hotKeyMetaData
        hotKeys[applicationName] = hotKey
        
        print("Adding hotkey: \(keyCombo) -> \(applicationName)")
    }
    
    public func removeHotKey(applicationName: String) {
        hotKeys.removeValue(forKey: applicationName)
        hotKeysMetaData.removeValue(forKey: applicationName)
    }
    
    private func getHandler(applicationName: String) -> (() -> Void) {
        return { [weak self] in

            guard self != nil else { return }
            
            let runningApps = NSWorkspace.shared.runningApplications
            let app = runningApps.first{$0.localizedName == applicationName}
            if let app = app {
                app.activate(options: [.activateIgnoringOtherApps, .activateAllWindows])
            } else {
                print(applicationName, " is not open, opening")
                NSWorkspace.shared.launchApplication(applicationName)
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

struct HotKeyMetaData: Codable {
    let control: Bool
    let command: Bool
    let shift: Bool
    let option: Bool
    var keyCode: UInt32
    var char: String
    var summary: String {
        var stringBuilder = ""
            
        if self.control {
           stringBuilder += "⌃"
        }
        if self.option {
           stringBuilder += "⌥"
        }
        if self.command {
           stringBuilder += "⌘"
        }
        if self.shift {
           stringBuilder += "⇧"
        }
        
        stringBuilder += char
        
        return stringBuilder
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
