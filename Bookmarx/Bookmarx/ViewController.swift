//
//  ViewController.swift
//  Bookmark Randomizer
//
//  Created by Dennis Kerzig on 03.11.16.
//  Copyright © 2016 Dennis Kerzig. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    let bookmarksController = BookmarksController.sharedInstance
    
    var selectedItem: BookmarkItem? {
        get {
            let idx = self.outlineView.selectedRow
            return self.outlineView.item(atRow: idx) as? BookmarkItem
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
    func setBookmarksSource() {
        if let selectedItem = selectedItem {
            // Save Title & URLs
            let defaults = UserDefaults(suiteName: "3XP3Y7NE3Q.bookmarx")!
            defaults.set(selectedItem.title, forKey: "bookmarksTitleKey")
            defaults.set(selectedItem.uuid, forKey: "bookmarksUUIDKey")
            defaults.set(selectedItem.allChildURLs(), forKey: "bookmarkURLsKey")
            let currentDate = NSDate()
            defaults.set(currentDate, forKey: "bookmarkDateKey")
            //        let date = NSDate()
            //        let calendar = NSCalendar.current
            //        let hour = calendar.component(.hour, from: date as Date)
            //        let minutes = calendar.component(.minute, from: date as Date)
            //        let seconds = calendar.component(.second, from: date as Date)
            //        let year = calendar.component(.year, from: date as Date)
            //        let month = calendar.component(.month, from: date as Date)
            //        let day = calendar.component(.day, from: date as Date)
            //
            
            // Update UI
            if let windowController = view.window?.windowController as? WindowController,
                let label = windowController.currentSelectionLabel {
                
                // Fill Label
                label.stringValue = "Updated Selection: \(selectedItem.title)"
                label.alphaValue = 1.0
                label.textColor = NSColor.black
            }
            
        }
    }
    
    
}


extension ViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let bookmarkItem = item as? BookmarkItem {
            return bookmarkItem.children.count
        } else if let _ = bookmarksController.rootItem {
            return 1
        } else {
            return 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let bookmarkItem = item as? BookmarkItem {
            return bookmarkItem.children[index]
        }
        
        return self.bookmarksController.rootItem!
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let bookmarkItem = item as? BookmarkItem {
            return bookmarkItem.children.count > 0;
        }
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        if let bookmarkItem = item as? BookmarkItem {
            return bookmarkItem.url == nil && bookmarkItem.children.count > 0
        }
        return true
    }
    
}


extension ViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: NSTableCellView?
        
        if let bookmarkItem = item as? BookmarkItem {
            
            let cellIdentifierForColumn = ["URLColumn":"URLCell", "IdentifierColumn":"IdentifierCell", "CountColumn":"CountCell"]
            if let identifier = tableColumn?.identifier,
                let viewIdentifier = cellIdentifierForColumn[identifier] {
                view = outlineView.make(withIdentifier: viewIdentifier, owner: self) as? NSTableCellView
            }
            
            if let textField = view?.textField {
                
                let isSelectable = (bookmarkItem.url == nil && bookmarkItem.children.count > 0)
                textField.alphaValue = isSelectable ? 1.0 : 0.4
                
                if let id = tableColumn?.identifier {
                    switch id {
                    case "URLColumn":
                        textField.stringValue = bookmarkItem.url ?? ""
                    case "IdentifierColumn":
                        textField.stringValue = bookmarkItem.title
                    case "CountColumn":
                        if let _ = bookmarkItem.url {
                            textField.stringValue = ""
                        } else {
                            let count = bookmarkItem.allChildCount()
                            textField.stringValue = "\(count == 0 ? "" : String(count))"
                        }
                    default: break
                    }
                }
                
                textField.sizeToFit()
            }
            
            
        }
        
        return view
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        if let windowController = view.window?.windowController as? WindowController,
            let button = windowController.useSelectionButton {
            
            if (outlineView.selectedRow == -1) {
                // No Row is selected
                button.title = "Select a List"
                button.isEnabled = false
                
            } else {
                button.title = "Use Selected List"
                button.isEnabled = true
            }
            
        }
    }
    
    
}













