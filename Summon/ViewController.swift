//
//  ViewController.swift
//  Summon
//
//  Created by Benjamin Rohald on 10/4/20.
//  Copyright © 2020 Benjamin Rohald. All rights reserved.
//


import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var applicationNameTextField: NSTextFieldCell!
    @IBOutlet weak var modifiersButton: NSButtonCell!
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    var applicationSearcher: ApplicationSearcher!
    var listeningForHotkey = false
    
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

    @IBAction func modifiersButtonClicked(_ sender: Any) {
        if !listeningForHotkey { modifiersButton.title = "" }
        listeningForHotkey = true
    }
    
    override func keyDown(with event: NSEvent) {
        //THIS METHOD SHOULD MARK THE CONCLUSION OF THE KEYBINDING UPDATE
        if !listeningForHotkey { return }
        
        let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        
        if modifierFlags.isEmpty {
            print("modifier flags are empty, doing nothing")
        } else {
            appDelegate.hotKeysController?.addHotKey(event: event, applicationName: applicationNameTextField.stringValue)
            modifiersButton.title = modifiersButton.title + event.charactersIgnoringModifiers!
        }
        
        listeningForHotkey = false
        print("listening for keys \(listeningForHotkey)")
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        appDelegate.hotKeysController?.removeHotKey(applicationName: applicationNameTextField.stringValue)
    }
    
    override func flagsChanged(with event: NSEvent) {
        if !listeningForHotkey { return }
        
        setButtonTitle(event: event)
    }
    
    func setButtonTitle(event: NSEvent) {
        
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
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
        
        if stringBuilder == "" {
            modifiersButton.title = modifiersButton.alternateTitle
        } else {
            modifiersButton.title = stringBuilder
        }
    }
    
    override func viewDidAppear() {
        super.viewWillAppear()

        view.window?.styleMask.remove(.resizable)
        view.window?.styleMask.remove(.miniaturizable)
        view.window?.center()
    }
    
}

