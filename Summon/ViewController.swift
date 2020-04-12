//
//  ViewController.swift
//  Summon
//
//  Created by Benjamin Rohald on 10/4/20.
//  Copyright © 2020 Benjamin Rohald. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var modifiers: NSTextField!
    
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
        print("modifier flags: ", event.modifierFlags)
        print("chars w/o mods: ", (event.charactersIgnoringModifiers))
    }
    
    override func flagsChanged(with event: NSEvent) {
        // THIS METHOD SHOULD UPDATE THE VIEW ONLY.
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
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
}

