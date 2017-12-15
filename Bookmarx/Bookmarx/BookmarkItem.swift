//
//  BookmarkItem.swift
//  Bookmark Randomizer
//
//  Created by Dennis Kerzig on 03.11.16.
//  Copyright © 2016 Dennis Kerzig. All rights reserved.
//

import Cocoa

class BookmarkItem: NSObject {
    let title: String
    let data: NSDictionary
    var url: String? = nil
    var uuid: String? = nil
    
    var children = [BookmarkItem]()

    
    init(dictionary: NSDictionary) {
        self.data = dictionary
        
        // Find out Title
        if let title = dictionary["Title"] as? String {
            self.title = title
        } else if let uriDictionary = dictionary["URIDictionary"] as? NSDictionary,
            let title = uriDictionary["title"] as? String {
            self.title = title
        } else {
            self.title = "No Title"
        }

        // Set URL
        if let urlString = dictionary["URLString"] as? String {
            self.url = urlString
        }
        
        // Set UUID
        if let uuidString = dictionary["WebBookmarkUUID"] as? String {
            self.uuid = uuidString
        }
    }
    
    
    func loadChildren() {
        if let children = data["Children"] as? [NSDictionary] {
            for child in children {
                
                // Check if child should be added and if yes propably with changed values
                if let child = BookmarksController.shouldBeAddedAs(dict: child.mutableCopy() as! NSMutableDictionary) {
                    let childItem = BookmarkItem(dictionary: child)
                    childItem.loadChildren()
                    self.children.append(childItem)
                }
                
            }
        }
    
    }
    
    

    func allChildCount() -> Int {
        if children.count == 0 {
            return 1
        } else {
            return children.map{$0.allChildCount()}.reduce(0, +)
        }

    }
    
    
    func allChildURLs() -> [String] {
        if let url = url {
            return [url]
        } else {
            return children.map{$0.allChildURLs()}.flatMap{$0}
        }
    }
    
}
