//
//  StartViewController.swift
//  Streams
//
//  Created by Igor Karyi on 08.02.2018.
//  Copyright © 2018 Igor Karyi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftVideoBackground
import CoreData

class StartViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var videoView: UIView!
    
    var firstObjectsArray = [Objects]()
    
    let preferredLanguage = NSLocale.preferredLanguages[0]
    
    var language = String()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var blockNews: [BlockNews] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        
        for block in self.blockNews {
            print("Blocked news", block.idSelect!, block.dateSelect!)
        }
        
        if preferredLanguage.starts(with: "en") {
            language = "en"
            print("this is English")
        } else if preferredLanguage.starts(with: "ru") {
            language = "ru"
            print("this is Russian")
        } else if preferredLanguage.starts(with: "uk") {
            language = "ru"
            print("this is Russian")
        } else if preferredLanguage.starts(with: "be") {
            language = "ru"
            print("this is Russian")
        } else {
            language = "en"
            print("this is English")
        }
        
        try? VideoBackground.shared.play(
            view: videoView,
            videoName: "streams",
            videoType: "mp4",
            isMuted: false,
            willLoopVideo: false,
            setAudioSessionAmbient: false
        )
        
        if Connectivity.isConnectedToInternet {
            print("Connected")
            screenSelection()
        } else {
            print("No Internet")
            showErrorAlert()
        }
    }
    
    func screenSelection() {
        let deadlineTime = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            
            let userDefaults = UserDefaults.standard
            let wasIntroWatched = userDefaults.bool(forKey: "wasIntroWatched")
            
            if wasIntroWatched == true {
                self.newsRequest()
                print("true")
                
            } else {
                print("false")
                
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewVC") as? WebViewVC {
                    self.present(viewController, animated: false, completion: nil)
                }
            }
        }
    }
    
    //hide navigation bar on first screen
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.tabBarController?.navigationItem.hidesBackButton = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (navigationController?.topViewController != self) {
            navigationController?.navigationBar.isHidden = true
        }
        super.viewWillDisappear(animated)
    }
    
    func getData() {
        do {
            blockNews = try context.fetch(BlockNews.fetchRequest())
        }
        catch {
            print("Fetching Failed")
        }
    }
    
    //download news
    func newsRequest() {
        
        // Add URL parameters
        let urlParams = [
            "language": language
        ]
        
        Alamofire.request("http://streams.fm/test.php", method: .get, parameters: urlParams)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if (response.result.error == nil) {
                    let json = JSON(response.result.value as Any)
                    if let allNews = json["all_news"].array {
                        var resultDataSource = [Objects]()
                        for item in allNews {
                            
                            var newsArray = [String]()
                            var locationArray : String?
                            var dateArray = [String]()
                            var sectionTitle : String?
                            var idNews = [String]()
                            
                            if let attributesArray = item["attributes"].array {
                                for newsItem in attributesArray {
                                    if let id = newsItem["news_id"].string {
                                        
                                        var cheked = false
                                        for block in self.blockNews {
                                            if id == block.idSelect {
                                                print("есть такой id")
                                                print("skipped news", id)
                                                cheked = true
                                                continue
                                            } else {
                                                print("нет такого id")
                                            }
                                        }
                                        if cheked == true {
                                            continue
                                        }
                                        idNews.append(id)
                                    }
                                    
                                    if let date = newsItem["news_date"].string {
                                        dateArray.append(date)
                                    }
                                    
                                    if let text = newsItem["news_text"].string {
                                        newsArray.append(text)
                                    }
                                    
                                }
                            }
                            
                            if let themes = item["news_theme"].string {
                                sectionTitle = themes
                            }
                            
                            if let location = item["attributes"][0]["news_location"].string {
                                locationArray = location
                            }
                            
                            resultDataSource.append(Objects(newsSubjects: sectionTitle, newsTitle: newsArray, newsDate: dateArray, newsLocation: locationArray, newsID: idNews))
                        }
                        print("resultDataSource", resultDataSource)
                        self.firstObjectsArray = resultDataSource
                        
                    }
                    
                    self.performSegue(withIdentifier: "ShowViewController", sender: nil)
                    
                }
                else {
                    debugPrint("HTTP Request failed: \(String(describing: response.result.error))")
                    self.showErrorAlert()
                }
        }
    }
    
    func showErrorAlert() {
        // create the alert
        let uiAlert = UIAlertController(title: Strings.noConnectionServer, message: Strings.checkInternetConnection, preferredStyle: UIAlertControllerStyle.alert)
        self.present(uiAlert, animated: true, completion: nil)
        
        // add an action (Retry)
        uiAlert.addAction(UIAlertAction(title: Strings.retry, style: .default, handler: { action in
            self.newsRequest()
            print("Click retry button")
        }))
        
        // add an action (Retry Later)
        uiAlert.addAction(UIAlertAction(title: Strings.retryLater, style: .default, handler: { action in
            self.performSegue(withIdentifier: "ShowViewController", sender: nil)
            print("Click retry Later button")
        }))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowViewController" {
            let destVC = segue.destination as! ViewController
            
            destVC.objectsArray = firstObjectsArray
        }
    }
}

