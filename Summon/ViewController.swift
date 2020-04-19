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
    @IBOutlet weak var applicationNameTextField: NSTextFieldCell!
    @IBOutlet weak var modifiersButton: NSButtonCell!
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    var hotKeyController: HotKeysController?
    var applicationSearcher: ApplicationSearcher!
    var listeningForHotKey = false
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

    @IBAction func modifiersButtonClicked(_ sender: Any) {
        if !listeningForHotKey { modifiersButton.title = "" }
        listeningForHotKey = true
    }
    
    override func keyDown(with event: NSEvent) {
        //THIS METHOD SHOULD MARK THE CONCLUSION OF THE KEYBINDING UPDATE
        if !listeningForHotKey { return }
        
        let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        
        if modifierFlags.isEmpty {
            print("modifier flags are empty, doing nothing")
        } else {
            hotKeyController?.addHotKey(event: event, applicationName: applicationNameTextField.stringValue)
            modifiersButton.title = modifiersButton.title + event.charactersIgnoringModifiers!
        }
        
        listeningForHotKey = false
        print("listening for keys \(listeningForHotKey)")
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        hotKeyController?.removeHotKey(applicationName: applicationNameTextField.stringValue)
    }
    
    override func flagsChanged(with event: NSEvent) {
        if !listeningForHotKey { return }
        
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
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = item.name
            cellView.imageView?.image = item.icon
            return cellView
        
        case NSUserInterfaceItemIdentifier(rawValue: "hotKeyColID"):
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "hotKeyRowID")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            
            return cellView
        case NSUserInterfaceItemIdentifier(rawValue: "deleteColID"):
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "deleteRowID")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
    
            return cellView
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50.0
    }

}
