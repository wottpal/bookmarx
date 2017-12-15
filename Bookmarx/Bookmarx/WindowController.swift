//
//  WindowController.swift
//  Bookmark Randomizer
//
//  Created by Dennis Kerzig on 03.11.16.
//  Copyright © 2016 Dennis Kerzig. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    
    @IBOutlet weak var toolbar: NSToolbar!
    
    @IBOutlet weak var currentSelectionLabel: NSTextField!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var progressIndicatorToolbarItem: NSToolbarItem!

    @IBOutlet weak var reloadButton: NSButton!

    @IBOutlet weak var useSelectionButton: NSButton!
    @IBOutlet weak var useSelectionButtonToolbarItem: NSToolbarItem!
    
    
    
    @IBAction func setSourceButtonPressed(_ sender: NSButton) {
        if let viewController = self.contentViewController as? ViewController {
            viewController.setBookmarksSource()
        }
    }
    
    
    @IBAction func reloadButtonPressed(_ sender: NSButton) {
        initiateLoadingBookmarks()
    }
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        
        
        initiateLoadingBookmarks()
    }
    
    
    func launchRetryModal(question: String, text: String) -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.warning
        myPopup.addButton(withTitle: "Retry")
        myPopup.addButton(withTitle: "Close App")
        return myPopup.runModal() == NSAlertFirstButtonReturn
    }

    
    /**
        This function updates the UI to a loading state, starts loading the
        bookmarks and updates the UI back to normal when loading has finished.
    */
    func initiateLoadingBookmarks() {
        // Append progress-indicator to toolbar
        toolbar.insertItem(withItemIdentifier: "ProgressIndicatorItem", at: toolbar.items.count)
        progressIndicator.startAnimation(nil)
        currentSelectionLabel.stringValue = "Loading Bookmarks"
        currentSelectionLabel.alphaValue = 1.0
        contentViewController?.view.alphaValue = 0.4
        useSelectionButton.title = "Select a List"
        useSelectionButton.isEnabled = false
        if let viewController = self.contentViewController as? ViewController {
            viewController.outlineView.deselectAll(nil)
        }
        
        // Load Bookmarks
        BookmarksController.sharedInstance.loadBookmarks { (error) in
            
            if let error = error {
                var text = "For some reason access on 'Bookmarks.plist' was not granted to the App. You can retry."
                if error == .fileDialogDismissedOrWrongFileSelected {
                    text = "The file dialog was dismissed or the wrong file chosen. Please make sure to select the file 'Bookmarks.plist' located unter '~/Library/Safari/'."
                }
                if self.launchRetryModal(question: "Retry Giving File-Access", text: text) {
                   self.initiateLoadingBookmarks()
                } else {
                    NSApplication.shared().terminate(nil)
                }
                
                return
            }
            
            // When there are no bookmarks to randomize set yet (first start)
            // set it to "All Bookmarks"
            let defaults = UserDefaults(suiteName: "3XP3Y7NE3Q.bookmarx")!
            
            if let title = defaults.string(forKey: "bookmarksTitleKey"),
                let date = defaults.object(forKey: "bookmarkDateKey") as? NSDate,
                let _ = defaults.array(forKey: "bookmarkURLsKey") {
                // Format Date
                let calendar = NSCalendar.current
                let day = calendar.component(.day, from: date as Date)
                let month = calendar.component(.month, from: date as Date)
                let year = calendar.component(.year, from: date as Date)

                // Update label with selected title
                self.currentSelectionLabel.stringValue = "Selection: \(title) (\(month)/\(day)/\(year))"
                self.currentSelectionLabel.alphaValue = 0.5

                
            } else if let rootItem = BookmarksController.sharedInstance.rootItem {
                // Set rootItem as selected and update label
                defaults.set(rootItem.title, forKey: "bookmarksTitleKey")
                defaults.set(rootItem.allChildURLs(), forKey: "bookmarkURLsKey")
                self.currentSelectionLabel.stringValue = "Initial Selection: \(rootItem.title)"
                self.currentSelectionLabel.alphaValue = 0.5


            } else {
                self.currentSelectionLabel.stringValue = "No Bookmarks Found"
                self.currentSelectionLabel.alphaValue = 1
            }
            
            
            // When Bookmarks have finished Loading update UI
            self.progressIndicator.stopAnimation(nil)
            
            if let progressIndicatorIndex = self.toolbar.items.index(of: self.progressIndicatorToolbarItem) {
                self.toolbar.removeItem(at: progressIndicatorIndex)
            }
            
            self.reloadButton.isEnabled = true
            NSAnimationContext.runAnimationGroup({ (context) -> Void in
                self.contentViewController?.view.animator().alphaValue = 1.0
            }, completionHandler: nil)
            
            // Reload NSOutlineView and expand first item
            if let viewController = self.contentViewController as? ViewController {
                viewController.outlineView.reloadData()
                
                if let firstItem = viewController.outlineView.item(atRow: 0) {
                    viewController.outlineView.expandItem(firstItem)
                }
            }
            
        }

    }
    

}
