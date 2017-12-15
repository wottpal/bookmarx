//
//  BookmarksController.swift
//  Bookmark Randomizer
//
//  Created by Dennis Kerzig on 03.11.16.
//  Copyright © 2016 Dennis Kerzig. All rights reserved.
//

import Cocoa


enum BookmarksLoadingError: Error {
    case fileDialogDismissedOrWrongFileSelected
    case cantSaveAccessRights
    case cantLoadAccessRights
    case other
}



class BookmarksController: NSObject {
    
    // Singleton Initialization
    static let sharedInstance = BookmarksController()
    
    
    
    
    // Constants
    let bookmarksPath = "\(NSHomeDirectory())/Library/Safari/Bookmarks.plist"
    let defaults = UserDefaults(suiteName: "3XP3Y7NE3Q.bookmarx")!
    
    // Variables
    var rootItem: BookmarkItem?
    
    
    
    func canAccessBookmarksFile() -> Bool {
        // Check if there is already access to the Bookmarks-File
        if let bookmarkData = defaults.data(forKey: "bookmarkDataKey") {
            
            do {
                // Get URL to the file with access priveleges
                var bookmarkDataIsStale: Bool = true
                let bookmarkedURL = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &bookmarkDataIsStale)
                
                // Check if access is granted
                guard let accessGranted = bookmarkedURL?.startAccessingSecurityScopedResource(),
                    accessGranted ==  true else {
                        
                        // Access not granted (clean bookmarkdata)
                        self.defaults.removeObject(forKey: "bookmarkDataKey")
                        return false
                }
                
                // Access granted
                return true

            } catch {
                // Error = Access not granted (clean bookmarkdata)
                self.defaults.removeObject(forKey: "bookmarkDataKey")
                return false
            }
        }
        
        return false
    }
    
    
    func getBookmarksFileAccess(finish: @escaping (BookmarksLoadingError?)->()) {
        // Create & Configure OpenFileDialog to get permission
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.worksWhenModal = true
        openPanel.canChooseFiles = true
        openPanel.prompt = "Grant Read-Only Access"
        openPanel.message = "⚠️ Select 'Bookmarks.plist' to make it readable for the app. It's inside '~/Library/Safari/'."
        openPanel.allowedFileTypes = ["plist"]
        openPanel.directoryURL = URL(string: "\(NSHomeDirectory())/Library/Safari/")
        
        // Launch OpenFileDialog as Sheet of Main-Window
        openPanel.begin { (result) in
            
            // Ensure the file-dialog ended with OK and the valid file was selected
            guard result == NSFileHandlingPanelOKButton,
                let url = openPanel.url,
                url.absoluteString.hasSuffix("Bookmarks.plist") else {
                    openPanel.close()
                    finish(BookmarksLoadingError.fileDialogDismissedOrWrongFileSelected)
                    return
            }
            
            do {
                // Create Bookmark from URL so the file-dialog is only necessary once
                let bookmarkData = try url.bookmarkData(options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess], includingResourceValuesForKeys: nil, relativeTo: nil)
                self.defaults.set(bookmarkData, forKey: "bookmarkDataKey")
                
            } catch {
                openPanel.close()
                finish(BookmarksLoadingError.cantSaveAccessRights)
            }
            
            
            // File & Access Rights successfully gathered
            finish(nil)
        }
        
        openPanel.makeKey()
        NSApp.activate(ignoringOtherApps: true) 

    }
    
    
    
    func loadBookmarks(finish: ((BookmarksLoadingError?)->())?) {
        
        // Check if there is already access to the Bookmarks-File
        if let bookmarkData = defaults.data(forKey: "bookmarkDataKey") {
            
            do {
                
                // Get URL to the file with access priveleges
                var bookmarkDataIsStale: Bool = true
                let bookmarkedURL = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &bookmarkDataIsStale)
                
                // Check if access is granted
                guard let accessGranted = bookmarkedURL?.startAccessingSecurityScopedResource(),
                    accessGranted ==  true else {
                        
                        // Access not granted (clean bookmarkdata)
                        self.defaults.removeObject(forKey: "bookmarkDataKey")
                        finish?(BookmarksLoadingError.cantLoadAccessRights)
                        return
                }
                
                // Get File from URL & Create Dictionary
                if let dict = NSDictionary(contentsOf: bookmarkedURL!) as? [String: AnyObject],
                    let childs = dict["Children"] as? [NSDictionary] {
                    
                    // Move the bookmark-list reading to a background queue
                    DispatchQueue.global(qos: .userInitiated).async {
                        
                        // Initialize root item and start loading from top to bottom
                        self.rootItem = BookmarkItem(dictionary: [
                            "Title" : "All Bookmarks",
                            "Children" : childs
                            ])
                        self.rootItem?.loadChildren()
                        
                        
                        // Bounce back to the main thread to update the UI
                        DispatchQueue.main.async {
                            finish?(nil)
                        }
                    }
                }
                
            } catch {
                // Can't resolve bookmarkurl from saved data (clean bookmarkdata)
                self.defaults.removeObject(forKey: "bookmarkDataKey")
                finish?(BookmarksLoadingError.cantLoadAccessRights)
                return
            }
            
        } else {
            
            // No Bookmark-Data gathered yet (First start, or error before)
            getBookmarksFileAccess { (error) in
                if let error = error {
                    finish?(error)
                } else {
                    self.loadBookmarks(finish: finish)
                }
            }
        }
        
    }
    
    
    
    /**
     If the given item should be added this function returns the dictionary
     with adjusted values (esp. title). Otherwise .None
     */
    static func shouldBeAddedAs(dict: NSMutableDictionary) -> NSDictionary? {
        
        // Check for key-value pairs to be changed
        if let title = dict["Title"] as? String {
            
            switch title {
            case "BookmarksBar":
                dict["Title"] = " ⭐ Favorites"
                
            case "com.apple.ReadingList":
                dict["Title"] = " 🗞 Reading List"
                
            default: break
            }
            
        }
        
        // Check for items to be removed fully
        let propertyValuesToExclude = [
            "WebBookmarkIdentifier" : ["History"],
            "Title" : ["BookmarksMenu"]
        ]
        
        for (key, valuesToExclude) in propertyValuesToExclude {
            
            if let value = dict[key] as? String,
                valuesToExclude.contains(value) {
                return .none
            }
            
        }
        
        return dict
    }
    
    
}
