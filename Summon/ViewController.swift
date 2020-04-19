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
    var applicationMetaData = ApplicationSearcher().getAllApplications()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        conifigureKeyEvents()
        
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
        
        hotKeyController = appDelegate.hotKeysController
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

  fileprivate enum CellIdentifiers {
    static let NameCell = "applicationNameCellID"
  }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

    var image: NSImage?
    var text: String = ""
    var cellIdentifier: String = ""
    
    // 1
    let item = applicationMetaData[row]

    // 2
    if tableColumn == tableView.tableColumns[0] {
        let pathToIcon = item.value(forAttribute: NSMetadataItemPathKey as String)
        image = NSWorkspace.shared.icon(forFile: pathToIcon as! String)
        text = item.value(forAttribute: kMDItemDisplayName as String) as! String
        cellIdentifier = CellIdentifiers.NameCell
    }

    // 3
    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
        cell.textField?.stringValue = text
        cell.imageView?.image = image ?? nil
        return cell
    }
    
    
    return nil
  }

}
