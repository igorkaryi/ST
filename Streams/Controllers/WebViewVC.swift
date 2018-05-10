//
//  WebViewVC.swift
//  Streams
//
//  Created by Igor Karyi on 25.04.2018.
//  Copyright © 2018 Igor Karyi. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SwiftyJSON

class WebViewVC: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var applyView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let enURL = "http://streams.fm/en/confidentially.html"
    let ruURL = "http://streams.fm/ru/confidentially.html"
    var stringURL = String()
    
    var allNewsArray = [Objects]()
    
    var language = String()
    let preferredLanguage = NSLocale.preferredLanguages[0]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyButton.setTitle(Strings.accept, for: .normal)
        
        if preferredLanguage.starts(with: "en") {
            language = "en"
            stringURL = enURL
            print("this is English")
        } else if preferredLanguage.starts(with: "ru") {
            language = "ru"
            stringURL = ruURL
            print("this is Russian")
        } else if preferredLanguage.starts(with: "uk") {
            language = "ru"
            stringURL = ruURL
            print("this is Russian")
        } else if preferredLanguage.starts(with: "be") {
            language = "ru"
            stringURL = ruURL
            print("this is Russian")
        } else {
            language = "en"
            stringURL = enURL
            print("this is English")
        }
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "wasIntroWatched")
        userDefaults.synchronize()
        
        webView.navigationDelegate = self
        webView.uiDelegate = self

        let myURL = URL(string: stringURL)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)

        activityIndicator.startAnimating()
        applyView.isHidden = true

        activityIndicator.hidesWhenStopped = true
    }
    
    func showActivityIndicator(show: Bool) {
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            applyView.isHidden = false
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        showActivityIndicator(show: false)
        activityIndicator.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showActivityIndicator(show: true)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showActivityIndicator(show: false)
        activityIndicator.isHidden = true
    }
    
    @IBAction func applyAction(_ sender: UIButton) {
        //newsRequest()
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StartApp") as? UINavigationController {
            self.present(viewController, animated: false, completion: nil)
        }
    }

}
