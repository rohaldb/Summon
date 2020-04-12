//
//  HotKeysController.swift
//  Summon
//
//  Created by Benjamin Rohald on 12/4/20.
//  Copyright © 2020 Benjamin Rohald. All rights reserved.
//
import HotKey
import Foundation

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
    
    func setUp() {
        print("Hotkeys enabled")
        self.configuration.forEach { command, key in
            let hotkey = HotKey(key: key, modifiers: [.command, .control])
            hotkey.keyDownHandler = self.getHandler(key: key, command: command)
            self.hotkeys.append(hotkey)
        }
    }

}
