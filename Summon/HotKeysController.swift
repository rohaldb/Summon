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

    private enum Command : String {
        case First,
             Second
    }
    
    private var configuration = [
        Command.First:  Key.f,
        Command.Second:  Key.s,
    ]
    
    private var hotkeys = [HotKey]()
    
    private func getHandler(key: Key, command: Command) -> (() -> Void) {
        return { [weak self] in

            guard self != nil else { return }
            
            print("hotkey: \(key.description), command: \(command)")

            switch command {
                case Command.First:
                    print("first triggered")
                    break
                case Command.Second:
                    print("second triggered")
                    break
            }
        }
    }
    
    override init() {
        super.init()
        configureHotKeysFromConfig()
    }
    
    func configureHotKeysFromConfig() {
        print("Hotkeys enabled")
        self.configuration.forEach { command, key in
            let hotkey = HotKey(key: key, modifiers: [.command, .control])
            hotkey.keyDownHandler = self.getHandler(key: key, command: command)
            self.hotkeys.append(hotkey)
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
