//
//  ViewController.swift
//  Summon
//
//  Created by Benjamin Rohald on 10/4/20.
//  Copyright © 2020 Benjamin Rohald. All rights reserved.
//

import Cocoa

let ESCAPE_KEYCODE: UInt16 = 0x35

class ViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var selectedApplicationIcon: NSImageView!
    @IBOutlet weak var hotKeysLabel: NSTextField!
    @IBOutlet weak var descriptionLabel: NSTextField!
    
    var keyCombination = KeyCombination(modifiers: [], char: "", keyCode: 0)
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    var hotKeysController: HotKeysController!
    var applicationSearcher: ApplicationSearcher!
    var applicationMetaData = ApplicationSearcher().getAllApplications().sorted(by: {$0.name < $1.name})
    var filteredApplicationMetaData: [Application]!
    var mode = Mode.AwaitingApplicationSelect
    var selectedApplication: Application!
    var applicationNameTableFilter = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        transitionToAwaitingApplicationSelect()
        filteredApplicationMetaData = applicationMetaData
        hotKeysController = appDelegate.hotKeysController
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
        
        if event.keyCode == ESCAPE_KEYCODE {
            transitionToAwaitingApplicationSelect()
        }
        
        if keyCombination.modifiers.isEmpty {
            print("modifier flags are empty, doing nothing")
            return
        }
        
        
        completeHotKeyBinding(event: event)
    }
    
    override func flagsChanged(with event: NSEvent) {
        if mode != Mode.ListeningForKeys {
            print("not listening for keys yet")
            return
        }
         
        keyCombination.modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask).intersection(hotKeysController.getPermittedModifiers())
        setHotKeysLabel()
    }
    
    func completeHotKeyBinding(event: NSEvent) {
        keyCombination.keyCode = event.keyCode
        keyCombination.char = hotKeysController.getKeyCodeDescription(keyCode: event.keyCode)
        setHotKeysLabel()
        
        hotKeysController.addHotKey(
            char: keyCombination.char,
            keyCode: keyCombination.keyCode,
            modifiers: keyCombination.modifiers,
            applicationName: selectedApplication.name
        )
        
        transitionToNotifyingSuccess()
    }
    
    func setHotKeysLabel() {
        
        let modifiers = keyCombination.modifiers.intersection(.deviceIndependentFlagsMask)
        let string = "^⌥⌘⇧" + (keyCombination.char == "" ? "_" : keyCombination.char)
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let stringBuilder = NSMutableAttributedString(
            string: string,
            attributes: [.paragraphStyle: paragraph]
        )
        
        stringBuilder.addAttribute(NSAttributedString.Key.foregroundColor, value: NSColor.gray, range: NSRange(location: 0, length: 5))
        
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
        
        if keyCombination.char != "" {
            assignColorToPartOfString(stringBuilder: stringBuilder, startIndex: 4, length: 1)
        }

        hotKeysLabel.attributedStringValue = stringBuilder
    }
    
    func assignColorToPartOfString(stringBuilder: NSMutableAttributedString, startIndex: Int, length: Int) {
        let color = NSColor.init(red: 0.72, green: 0, blue: 1, alpha: 1)
        stringBuilder.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location:startIndex, length: length))
    }

    
    @IBAction func searchFieldChanged(_ sender: NSSearchField) {
        applicationNameTableFilter = sender.stringValue
        
        if applicationNameTableFilter == "" {
            filteredApplicationMetaData = applicationMetaData
        } else {
            filteredApplicationMetaData = applicationMetaData.filter {$0.name.lowercased().contains(applicationNameTableFilter.lowercased())}
        }
        
        tableView.reloadData()
    }
    
    func transitionToListeningForKeysMode() {
        mode = Mode.ListeningForKeys
        tableView.reloadData()
        let selectedApplicationName = selectedApplication.name
        descriptionLabel.setStringValue("Enter a Hot Key to bind to \(selectedApplicationName)", animated: true)
    }
    
    func transitionToAwaitingApplicationSelect() {
        mode = Mode.AwaitingApplicationSelect
        resetHotKeysLabel()
        descriptionLabel.setStringValue("Select an Application from the table below", animated: true)
    }
    
    func transitionToNotifyingSuccess() {
        mode = Mode.NotifyingSuccess
        descriptionLabel.setStringValue("Success", animated: true)
        tableView.reloadData()
        selectedApplicationIcon.image = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            self.transitionToAwaitingApplicationSelect()
        })
    }
    
    func resetHotKeysLabel() {
        keyCombination = KeyCombination(modifiers: [], char: "", keyCode: 0)
        setHotKeysLabel()
    }
    
    override func viewDidAppear() {
        super.viewWillAppear()

        view.window?.styleMask.remove(.resizable)
        view.window?.styleMask.remove(.miniaturizable)
        view.window?.center()
    }
    
}


extension ViewController: NSTableViewDataSource {
  
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filteredApplicationMetaData.count
    }
}

extension ViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
        
        let application = filteredApplicationMetaData[row]
        
        switch tableColumn?.identifier {
        case NSUserInterfaceItemIdentifier(rawValue: "applicationColID"):
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "applicationRowID")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? ApplicationCellView else { return nil }
            
            cellView.nameField.stringValue = application.name
            cellView.icon.image = application.icon
            
            cellView.deleteButton.tag = row
            cellView.deleteButton.action =  #selector(self.deleteBinding)
        
            cellView.hotKeyLabel.isHidden = true
            cellView.deleteButton.isHidden = true
            
            if hotKeysController.hotKeyExistsForApplication(applicationName: application.name) {
                cellView.deleteButton.isHidden = false
                cellView.hotKeyLabel.isHidden = false
                if let summary = hotKeysController.getHotKeySummary(applicationName: application.name) {
                    cellView.hotKeyLabel.stringValue = summary
                } else {
                    cellView.hotKeyLabel.stringValue = "�"
                }
                
            }
            
            return cellView
            
        default:
            return nil
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        selectedApplication = filteredApplicationMetaData[tableView.selectedRow]
        selectedApplicationIcon.image = selectedApplication.icon
        transitionToListeningForKeysMode()
    }
    
    @objc func deleteBinding(button:NSButton){
        let row = button.tag
        let applicationName = filteredApplicationMetaData[row].name
        hotKeysController.removeHotKey(applicationName: applicationName)
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
    case NotifyingSuccess
}
