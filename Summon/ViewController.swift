//
//  ViewController.swift
//  Summon
//
//  Created by Benjamin Rohald on 10/4/20.
//  Copyright © 2020 Benjamin Rohald. All rights reserved.
//

import Cocoa
import HotKey

class ViewController: NSViewController {

    @IBOutlet weak var modifiers: NSTextField!
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {
            self.flagsChanged(with: $0)
            return $0
        }
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
    }

    override func keyDown(with event: NSEvent) {
        //THIS METHOD SHOULD MARK THE CONCLUSION OF THE KEYBINDING UPDATE

        let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        
        if modifierFlags.isEmpty {
            print("modifier flags are empty, doing nothing")
        } else {
            let keyCombo = KeyCombo(carbonKeyCode: UInt32(event.keyCode), carbonModifiers: modifierFlags.carbonFlags)
            appDelegate.hotKeysController?.addHotkey(keyCombo: keyCombo, applicationName: "Google Chrome")
        }
        
    }
    
    override func flagsChanged(with event: NSEvent) {
        // THIS METHOD SHOULD UPDATE THE VIEW ONLY.
        let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        modifiers.stringValue = buildStringFromModifierKeys(modifiers: modifierFlags)
    }
    
    func buildStringFromModifierKeys(modifiers: NSEvent.ModifierFlags) -> String {
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
        
        return stringBuilder
    }
    
    override func viewDidAppear() {
        super.viewWillAppear()

        view.window?.styleMask.remove(.resizable)
        view.window?.styleMask.remove(.miniaturizable)
        view.window?.center()
    }
    
}

