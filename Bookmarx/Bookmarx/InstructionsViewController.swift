//
//  InstructionsViewController.swift
//  Bookmarx
//
//  Created by Dennis Kerzig on 20.07.17.
//  Copyright © 2017 @wottpal. All rights reserved.
//

import Cocoa
import WebKit
class InstructionsViewController: NSViewController, WKNavigationDelegate, WKUIDelegate {
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Open local html-resources
        let path = Bundle.main.path(forResource: "bookmarx", ofType: ".html", inDirectory: "Web-Tutorial")
        let url = URL(fileURLWithPath: path!)
        let req = URLRequest(url: url)
        self.webView.load(req)
        
        // Set Delegate
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
    }
    
    // Open links in Safari
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url, let scheme = url.scheme {
            if ["http", "https", "mailto"].contains(where: { $0.caseInsensitiveCompare(scheme) == .orderedSame }) {
                NSWorkspace.shared().open(url)
            }
        }
        return nil
    }
}
