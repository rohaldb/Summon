//
//  ViewController.swift
//  Summon
//
//  Created by Benjamin Rohald on 10/4/20.
//  Copyright © 2020 Benjamin Rohald. All rights reserved.
//


import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var selectedApplicationIcon: NSImageView!
    @IBOutlet weak var hotKeysLabel: NSTextField!
    
    var keyCombination = KeyCombination(modifiers: [], char: "", keyCode: 0)
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    var hotKeyController: HotKeysController?
    var applicationSearcher: ApplicationSearcher!
    var applicationMetaData = ApplicationSearcher().getAllApplications().sorted(by: {$0.name < $1.name})
    var mode = Mode.AwaitingApplicationSelect
    var selectedApplication: Application!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        hotKeyController = appDelegate.hotKeysController
        configureTableView()
        conifigureKeyEvents()
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func conifigureKeyEvents() {
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
        
        if mode != Mode.ListeningForKeys {
            print("not listening for keys yet")
            return
        }
        
        if keyCombination.modifiers.isEmpty {
            print("modifier flags are empty, doing nothing")
            return
        }
        
        keyCombination.char = event.charactersIgnoringModifiers ?? ""
        keyCombination.keyCode = event.keyCode
        setHotKeysLabel()
        
        hotKeyController?.addHotKey(
            keyCode: keyCombination.keyCode,
            modifierFlags: keyCombination.modifiers,
            applicationName: selectedApplication.name
        )
        
        transitionToAwaitingApplicationSelect()
    }
    
    override func flagsChanged(with event: NSEvent) {
        if mode != Mode.ListeningForKeys {
            print("not listening for keys yet")
            return
        }
         
        keyCombination.modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        setHotKeysLabel()
    }
    
    func assignColorToPartOfString(stringBuilder: NSMutableAttributedString, startIndex: Int, length: Int) {
        stringBuilder.addAttribute(NSAttributedString.Key.foregroundColor, value: NSColor.purple, range: NSRange(location:startIndex, length: length))
    }
    
    func setHotKeysLabel() {
        
        let modifiers = keyCombination.modifiers.intersection(.deviceIndependentFlagsMask)
        let string = "^⌥⌘⇧" + keyCombination.char
        let stringBuilder = NSMutableAttributedString(string: string)
        stringBuilder.addAttribute(NSAttributedString.Key.foregroundColor, value: NSColor.gray, range: NSRange(location: 0, length: 4))
        
        if modifiers.contains(.control) {
            assignColorToPartOfString(stringBuilder: stringBuilder, startIndex: 0, length: 1)
        }
        if modifiers.contains(.option) {
            assignColorToPartOfString(stringBuilder: stringBuilder, startIndex: 1, length: 1)
        }
        if modifiers.contains(.command) {
            assignColorToPartOfString(stringBuilder: stringBuilder, startIndex: 2, length: 1)
        }
        if modifiers.contains(.shift) {
            assignColorToPartOfString(stringBuilder: stringBuilder, startIndex: 3, length: 1)
        }
        
        if string.count == 5 {
            assignColorToPartOfString(stringBuilder: stringBuilder, startIndex: 4, length: 1)
        }

        hotKeysLabel.attributedStringValue = stringBuilder
    }
    
    func transitionToListeningForKeysMode() {
        mode = Mode.ListeningForKeys
        tableView.reloadData()
    }
    
    func transitionToAwaitingApplicationSelect() {
        keyCombination = KeyCombination(modifiers: [], char: "", keyCode: 0)
        setHotKeysLabel()
        mode = Mode.AwaitingApplicationSelect
        tableView.reloadData()
    }
    
    override func viewDidAppear() {
        super.viewWillAppear()

        setHotKeysLabel()
        view.window?.styleMask.remove(.resizable)
        view.window?.styleMask.remove(.miniaturizable)
        view.window?.center()
    }
    
}



extension ViewController: NSTableViewDataSource {
  
    func numberOfRows(in tableView: NSTableView) -> Int {
        return applicationMetaData.count
    }
}

extension ViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
        
        let item = applicationMetaData[row]
        
        switch tableColumn?.identifier {
        case NSUserInterfaceItemIdentifier(rawValue: "applicationColID"):
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "applicationRowID")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? ApplicationCellView else { return nil }
            
            cellView.nameField.stringValue = item.name
            cellView.icon.image = item.icon
            
            cellView.deleteButton.tag = row
            cellView.deleteButton.action =  #selector(self.deleteBinding)
        
            cellView.hotKeyLabel.isHidden = true
            cellView.deleteButton.isHidden = true
            
            if let _ = hotKeyController?.hotKeys[item.name] {
                cellView.deleteButton.isHidden = false
                cellView.hotKeyLabel.isHidden = false
            }
            
            return cellView
            
        default:
            return nil
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        selectedApplication = applicationMetaData[tableView.selectedRow]
        selectedApplicationIcon.image = selectedApplication.icon
        mode = Mode.ListeningForKeys
    }
    
    @objc func deleteBinding(button:NSButton){
        let row = button.tag
        let applicationName = applicationMetaData[row].name
        hotKeyController?.removeHotKey(applicationName: applicationName)
        tableView.reloadData()
        print("delete button clicked in row \(row)");
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50.0
    }

}

struct KeyCombination {
    var modifiers: NSEvent.ModifierFlags
    var char: String
    var keyCode: UInt16
}

enum Mode {
    case ListeningForKeys
    case AwaitingApplicationSelect
}
