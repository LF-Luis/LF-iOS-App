//
//  WebViewController.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    private var navTitle = ""
    private var pageURL = ""
    private var webView: WKWebView!
    private var overlay = LFOverlay()

    func setUp(navTitle nv: String, ViewURL link: String) {
        self.navTitle = nv
        self.pageURL = link
    }

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
        self.setUpNavBar(navTitle)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        // Start overlay
        self.overlay.showOverlay(forView: self.webView, withTitle: nil)

        // Web request
        let myURL = URL(string: pageURL)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }

    private func setUpNavBar(_ title: String) {
        navigationItem.title = title
    }

    // MARK: - WKNavigationDelegate methods
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.overlay.endOverlay()
    }

}
