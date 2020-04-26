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
        
        searchForPersistedData()
    }
    
    public func addHotKey(char: String, keyCode: UInt16, modifiers: NSEvent.ModifierFlags, applicationName: String) {
        
        let carbonKeyCode = UInt32(keyCode)
    
        let hotKeyMetaData = HotKeyMetaData(
            control: modifiers.contains(.control),
            command: modifiers.contains(.command),
            shift: modifiers.contains(.shift),
            option: modifiers.contains(.option),
            keyCode: carbonKeyCode,
            char: char
        )
        
        hotKeysMetaData[applicationName] = hotKeyMetaData
        hotKeys[applicationName] = createHotKeyFromMetaData(applicationName: applicationName, hotKeyMetaData: hotKeyMetaData)
        
        persistState()
        
        print("Adding hotkey for \(applicationName)")
    }
    
    public func removeHotKey(applicationName: String) {
        hotKeys.removeValue(forKey: applicationName)
        hotKeysMetaData.removeValue(forKey: applicationName)
        persistState()
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
    
    private func persistState() {
        let defaults = UserDefaults.standard
        defaults.dictionaryRepresentation().keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        defaults.set(try? PropertyListEncoder().encode(hotKeysMetaData), forKey:"HotKeysMetaData")
    }
    
    private func searchForPersistedData() {
        if let data = UserDefaults.standard.value(forKey:"HotKeysMetaData") as? Data {
            hotKeysMetaData = try! PropertyListDecoder().decode(Dictionary<String, HotKeyMetaData>.self, from: data)
            buildHotKeysFromMetaData()
        }

        print("got \(hotKeysMetaData.capacity) from disk")
    }
    
    private func buildHotKeysFromMetaData() {
        for (applicationName, hotKeyMetaData) in hotKeysMetaData {
            hotKeys[applicationName] = createHotKeyFromMetaData(applicationName: applicationName, hotKeyMetaData: hotKeyMetaData)
        }
    }
    
    private func createHotKeyFromMetaData(applicationName: String, hotKeyMetaData: HotKeyMetaData) -> HotKey{
        var modifiers = NSEvent.ModifierFlags()
        if hotKeyMetaData.control {
            modifiers = modifiers.union(.control)
        }
        if hotKeyMetaData.command {
           modifiers = modifiers.union(.command)
        }
        if hotKeyMetaData.shift {
           modifiers = modifiers.union(.shift)
        }
        if hotKeyMetaData.option {
           modifiers = modifiers.union(.option)
        }
        
        let keyCombo = KeyCombo(carbonKeyCode: hotKeyMetaData.keyCode, carbonModifiers: modifiers.carbonFlags)

        let hotKey = HotKey(keyCombo: keyCombo)
        hotKey.keyDownHandler = self.getHandler(applicationName: applicationName)
        return hotKey
    }
    
    private func removeAllHotKeys() {
        hotKeys = [String:HotKey]()
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
        if self.command {
           stringBuilder += "⌘"
        }
        if self.shift {
           stringBuilder += "⇧"
        }
        if self.option {
           stringBuilder += "⌥"
        }
        
        stringBuilder += char
        
        return stringBuilder
    }
}

// work around https://github.com/soffes/HotKey/issues/17
extension HotKeysController: NSMenuDelegate {
//    func menuWillOpen(_ menu: NSMenu) {
//        disableHotKeys()
//    }
//
//    func menuDidClose(_ menu: NSMenu) {
//        enableHotKeys()
//    }
}
