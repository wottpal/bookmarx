//
//  AppDelegate.swift
//  Bookmark Randomizer
//
//  Created by Dennis Kerzig on 03.11.16.
//  Copyright © 2016 Dennis Kerzig. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var instructionsWindowController: NSWindowController!
    var mainWindowController: WindowController!
    
    
    /* Debug Methods */
    
    func resetMainUserDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
    
    func resetSuiteUserDefaults() {
        let groupDefaults = UserDefaults(suiteName: "3XP3Y7NE3Q.bookmarx")!
        for key in groupDefaults.dictionaryRepresentation().keys {
            groupDefaults.removeObject(forKey: key)
        }
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
    
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Clear both UserDefaults for debugging
        #if DEBUG
        resetMainUserDefaults()
        resetSuiteUserDefaults()
        #endif
        
        // Open Instructions-Window & Request Bookmarks-Access 
        // if it's either first-start or the app can not access bookmarks
        let canAccessBookmarks = BookmarksController.sharedInstance.canAccessBookmarksFile()
        if (!canAccessBookmarks) {
            requestFilePermission()
        } else {
            self.openMainWindow()
        }
    }
    
    func requestFilePermission() {
        BookmarksController.sharedInstance.getBookmarksFileAccess { (error) in
            if let error = error {
                var text = "For some reason access on 'Bookmarks.plist' was not granted to the App. You can retry."
                if error == .fileDialogDismissedOrWrongFileSelected {
                    text = "The file dialog was dismissed or the wrong file chosen. You can retry."
                }
                if self.launchRetryModal(question: "Retry Giving File-Access", text: text) {
                    self.requestFilePermission()
                } else {
                    NSApplication.shared().terminate(nil)
                }
                
                return
            }
            
            // File permission gathered successfully
            self.openMainWindow()
            if (self.isFirstStart()) { self.openInstructionsWindow(self) }
        }
    }
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func isFirstStart() -> Bool {
        // Check if thats not the first start of the app
        let defaults = UserDefaults.standard
        let subsequentAppStart = defaults.bool(forKey: "SubsequentAppStart")
        if subsequentAppStart == true {
            return false
        }
        
        // This is the first start, mark this for future
        defaults.set(true, forKey: "SubsequentAppStart")
        return true
    }
    
    @IBAction func openInstructionsWindow(_ sender: Any) {
        // Open the instructions window
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        self.instructionsWindowController = storyboard.instantiateController(withIdentifier: "Instructions Window Controller") as! NSWindowController
        
        if let instructionsWindow = instructionsWindowController.window {
            
            instructionsWindow.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
            instructionsWindow.makeKeyAndOrderFront(nil)
            instructionsWindow.orderFrontRegardless()
        }
    }
    
    @IBAction func openTwitterLink(_ sender: Any) {
        let url = URL(string: "https://twitter.com/wottpal")
        NSWorkspace.shared().open(url!)
    }

    
    
    func openMainWindow() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        self.mainWindowController = storyboard.instantiateController(withIdentifier: "Main Window Controller") as! WindowController
        
        if let mainWindow = mainWindowController.window {
            mainWindow.makeKeyAndOrderFront(nil)
        }
    }
    
    
}

