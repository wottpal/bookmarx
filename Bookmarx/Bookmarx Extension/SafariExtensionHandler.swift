/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The principal object for the Animalify Extension. This object receives messages from the content script injected by this extension into web pages, and responds with the words to replace and what to replace them with.
 */

import SafariServices
import Foundation




class SafariExtensionHandler: SFSafariExtensionHandler {
    
    var logTimer: Timer?
    var defaults: UserDefaults!
    
    /**
     This function is called when the user clicks on the Safari toolbar
     button. It opens a random bookmark from the previously selected list.
     */
    override func toolbarItemClicked(in window: SFSafariWindow) {
        
        // Start Log-Timer
        //        if let _ = logTimer {
        //            logToFile(text: "Timer Re-Initiation")
        //
        //        } else {
        //            logToFile(text: "Timer Initiation")
        //
        //            logTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.logStep), userInfo: nil, repeats: true);
        //        }
        
        defaults = UserDefaults(suiteName: "3XP3Y7NE3Q.bookmarx")!

        if let urls = defaults.array(forKey: "bookmarkURLsKey") as? [String] {
            let randomIdx = Int(arc4random_uniform(UInt32(urls.count)))
            let url = URL(string: urls[randomIdx])
            window.openTab(with: url!, makeActiveIfPossible: true)
        }
        
    }
    
    //    func logStep() {
    //        logToFile(text: "Interval-Step")
    //    }
    //
    //    func logToFile(text logString: String) {
    //        // A path inside the document-directory
    //        let file = "Bookmark-Randomizer.txt"
    //
    //        // Determine current time string
    //        let date = NSDate()
    //        let calendar = NSCalendar.current
    //        let hour = calendar.component(.hour, from: date as Date)
    //        let minutes = calendar.component(.minute, from: date as Date)
    //        let seconds = calendar.component(.second, from: date as Date)
    //        let year = calendar.component(.year, from: date as Date)
    //        let month = calendar.component(.month, from: date as Date)
    //        let day = calendar.component(.day, from: date as Date)
    //
    //        let timePrefix = "[\(day).\(month).\(year) \(hour):\(minutes):\(seconds)]"
    //
    //        // Build Simple Log-Text
    //        let text = "\n\(timePrefix) \(logString)"
    //
    //        // Open up Documents-directory
    //        if let dir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
    //
    //            let path = dir.appendingPathComponent(file)
    //
    //
    //            //reading existing text
    //            var writtenText = ""
    //            do {
    //                writtenText = try String(contentsOf: path, encoding: String.Encoding.utf8)
    //            }
    //            catch {
    //                print("error while reading")
    //            }
    //
    //
    //            //writing
    //            do {
    //                try (writtenText + text).write(to: path, atomically: false, encoding: String.Encoding.utf8)
    //            }
    //            catch {
    //                print("error while writing")
    //            }
    //            
    //        }
    //    }
    
    
}
