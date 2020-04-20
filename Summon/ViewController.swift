//
//  ViewController.swift
//  Summon
//
//  Created by Benjamin Rohald on 10/4/20.
//  Copyright © 2020 Benjamin Rohald. All rights reserved.
//


import Cocoa

var FakeApplicationBindings = [
    "Google Chrome": true,
    "iTerm2": false,
    "SourceTree": false,
]

class ViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var applicationNameTextField: NSTextFieldCell!
    
    @IBOutlet weak var hotKeysLabel: NSTextField!
    @IBOutlet weak var modifiersButton: NSButtonCell!
    var keyCombination = KeyCombination(modifiers: [], chars: "")
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    var hotKeyController: HotKeysController?
    var applicationSearcher: ApplicationSearcher!
    var listeningForHotKey = true
    var applicationMetaData = ApplicationSearcher().getAllApplications().sorted(by: {$0.name < $1.name})
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        hotKeyController = appDelegate.hotKeysController
        configureTableView()
        conifigureKeyEvents()
        
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.selectionHighlightStyle = .none
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
        
        keyCombination.chars = event.charactersIgnoringModifiers ?? ""

        setHotKeysLabel()
//        if modifierFlags.isEmpty {
//            print("modifier flags are empty, doing nothing")
//            return
//        } else {
//            hotKeysLabel.stringValue += event.charactersIgnoringModifiers!
////            hotKeyController?.addHotKey(event: event, applicationName: applicationNameTextField.stringValue)
//        }
//
//        listeningForHotKey = false
//        print("listening for keys \(listeningForHotKey)")
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        hotKeyController?.removeHotKey(applicationName: applicationNameTextField.stringValue)
    }
    
    override func flagsChanged(with event: NSEvent) {
        keyCombination.modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        setHotKeysLabel()
    }
    
    func setHotKeysLabel() {
        hotKeysLabel.stringValue = buildStringFromKeyCombination()
    }
    
    func buildStringFromKeyCombination() -> String {
        let modifiers = keyCombination.modifiers.intersection(.deviceIndependentFlagsMask)
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
        
        stringBuilder += keyCombination.chars
        
        return stringBuilder
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
            cellView.bindButton.tag = row
            cellView.bindButton.action =  #selector(self.bindApplicationToHotKey)
            cellView.deleteButton.tag = row
            cellView.deleteButton.action =  #selector(self.deleteBinding)
            
            cellView.deleteButton.isHidden = true
            
            if FakeApplicationBindings[item.name] == true {
                cellView.bindButton.title = "Bound!"
                cellView.deleteButton.isHidden = false
            } else {
                cellView.bindButton.isHidden = true
            }
                
            
            return cellView
        default:
            return nil
        }
    }
    
    @objc func bindApplicationToHotKey(button:NSButton){
        let row = button.tag
        print("bind button clicked in row \(row)");
    }
    
    @objc func deleteBinding(button:NSButton){
        let row = button.tag
        print("delete button clicked in row \(row)");
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50.0
    }

}

struct KeyCombination {
    var modifiers: NSEvent.ModifierFlags
    var chars: String
}
