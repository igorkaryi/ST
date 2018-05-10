//
//  ViewController.swift
//  Streams
//
//  Created by Igor Karyi on 01.02.2018.
//  Copyright © 2018 Igor Karyi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Parchment
import Foundation
import CoreData

class ViewController: UIViewController, LocationTableVСDelegate, LocationForButtonDelegate, ThemesTableVСDelegate, UITextViewDelegate {
    
    //MARK: ==================PROPERTIES=====================
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locButton: UIButton!
    @IBOutlet weak var createNewsTextView: UITextView!
    @IBOutlet weak var lastWordsLabel: UILabel!
    @IBOutlet weak var addNewsView: UIView!
    @IBOutlet weak var topAddNewsViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationButtonKey: UIButton!
    @IBOutlet weak var themeButtonKey: UIButton!
    @IBOutlet weak var heightLocationViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var keyboardViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var addNewsButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var objectsArray = [Objects]()
    var modelArrayLocation = [String]()
    var modelArrayTheme = [String]()
    
    var pagingViewController = PagingViewController<PagingIndexItem>()
    
    var keyHeight = Int()
    var boardHeight = Int()
    
    var countCharacters = 100
    
    let preferredLanguage = NSLocale.preferredLanguages[0]
    
    var language = String()
    
    var utfStr = String()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var blockNews: [BlockNews] = []
    
    var saveLoc = String()
    var saveThem = String()
    
    var buttonSaveLoc = Strings.buttonLocation
    var buttonSaveThem = Strings.buttonSubject
    var buttonAllItems = Strings.buttonAll
    
    //MARK: ==================DELEGATS=====================
    func getLocationString(info: String) {
        if info == buttonAllItems {
            locationButtonKey.setTitle(buttonSaveLoc, for: .normal)
            saveLoc = ""
        } else {
            saveLoc = info
            locationButtonKey.setTitle(info, for: .normal)
        }
    }
    
    func getThemeString(info: String) {
        if info == buttonAllItems {
            themeButtonKey.setTitle(buttonSaveThem, for: .normal)
            saveThem = ""
        } else {
            saveThem = info
            themeButtonKey.setTitle(info, for: .normal)
        }
    }
    
    func getLocationForButton(location: String) {
        if location == buttonAllItems {
            locButton.setTitle(buttonSaveLoc, for: .normal)
            saveLoc = ""
        } else {
            saveLoc = location
            locButton.setTitle(location, for: .normal)
        }
        
        checkingConnection()
    }
    
    //MARK: ==================NOTIFICATIONS=====================
    @objc func refreshNews(notification: NSNotification) {
        print("refreshNews")
        checkingConnection()
    }
    
    func checkingConnection() {
        if Connectivity.isConnectedToInternet {
            print("Connected")
            getData()
            newsRequestWithParametrs()
        } else {
            print("No Internet")
            showErrorAlert()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        
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
        
        locButton.setTitle(Strings.buttonLocation, for: .normal)
        addNewsButton.setTitle(Strings.addNewsButton, for: .normal)
        lastWordsLabel.text = "\(Strings.left) 100 \(Strings.characters)"
        cancelButton.setTitle(Strings.buttonCancel, for: .normal)
        locationButtonKey.setTitle(Strings.buttonLocation, for: .normal)
        themeButtonKey.setTitle(Strings.buttonSubject, for: .normal)
        
        if UIDevice().userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height == Constants.ScreenDevice {
                heightLocationViewConstraint.constant = Constants.HeightBottomViewConstraintOnBigDevice
            }
        }
        
        keyboardViewConstraint.constant = -Constants.KeyboardHeight
        
        addPagingViewController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNews), name: NSNotification.Name(rawValue: "uploadNews"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        addViewLocation()
        
        addViewMenu()
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.swipeUp))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.addNewsView.addGestureRecognizer(swipeUp)
        self.view.addGestureRecognizer(swipeUp)
        
        loadThemsAndLocation()
    }
    
    func loadThemsAndLocation() {
        let queue = DispatchQueue.global(qos: .utility)
        queue.async {
            self.locationRequest()
            self.themeRequest()
        }
    }
    
    @objc func swipeUp() {
        print("swipeUp")
        closeAll()
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let rect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print(rect.height)
            var keyboardHeight = rect.height
            
            if #available(iOS 11.0, *) {
                let bottomInset = view.safeAreaInsets.bottom
                keyboardHeight -= bottomInset
            }
            
            boardHeight = Int(keyboardHeight)
        }
    }
    
    func addViewMenu() {
        topAddNewsViewConstraint.constant = -Constants.TopNewsViewConstraint
        addNewsView.clipsToBounds = true
        addNewsView.layer.cornerRadius = Constants.CornerRadiusForView
        addNewsView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    func addViewLocation() {
        locationView.clipsToBounds = true
        locationView.layer.cornerRadius = Constants.CornerRadiusForBottomView
        locationView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    func addPagingViewController() {
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
        
        pagingViewController.selectedTextColor = UIColor(red:0.44, green:0.44, blue:0.44, alpha:1.0)
        pagingViewController.textColor = UIColor(red:0.44, green:0.44, blue:0.44, alpha:1.0)
        pagingViewController.indicatorColor = #colorLiteral(red: 0.2003779113, green: 0.5293136239, blue: 0.7496610284, alpha: 1)
        
        addChildViewController(pagingViewController)
        pageView.addSubview(pagingViewController.view)
        pageView.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParentViewController: self)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    //save news
    func performAction() {
        print("performAction")
        
        if locationButtonKey.titleLabel?.text == buttonSaveLoc || themeButtonKey.titleLabel?.text == buttonSaveThem || createNewsTextView.text.count < 1 {
            showAlertWhenFieldsEmpty()
        } else {
            postNews()
            saveNews()
        }
    }
    
    func saveNews() {
        print("saveNews")
        
        createNewsTextView.resignFirstResponder()
        createNewsTextView.text = ""
        countCharacters = 100
        lastWordsLabel.text = "\(Strings.left) \(countCharacters) \(Strings.characters)"
        closeAll()
        locButton.setTitle(saveLoc, for: .normal)
        themeButtonKey.setTitle(saveThem, for: .normal)
        checkingConnection()
    }
    
    
    func disabledScrollPageWhenEmpty() {
        if self.objectsArray.count < 1 {
            self.pagingViewController.view.isUserInteractionEnabled = false
        } else {
            self.pagingViewController.view.isUserInteractionEnabled = true
        }
    }
    
    //character limit on textView
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            if Connectivity.isConnectedToInternet {
                print("Connected")
                performAction()
            } else {
                print("No Internet")
                showErrorAlert()
            }
            return false
        }
        let newText = (createNewsTextView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 100
    }
    
    func checkRemainingChars() {
        let allowedChars = countCharacters
        let charsInTextView = -createNewsTextView.text.count
        let remainingChars = allowedChars + charsInTextView
        if remainingChars <= allowedChars {
            lastWordsLabel.textColor = UIColor.darkGray
        }
        if remainingChars <= 20 {
            lastWordsLabel.textColor = UIColor.orange
        }
        if remainingChars <= 10 {
            lastWordsLabel.textColor = UIColor.red
        }
        lastWordsLabel.text = String(remainingChars)
        lastWordsLabel.text = "\(Strings.left) \(remainingChars) \(Strings.characters)"
    }
    
    func textViewDidChange(_ textView: UITextView) {
        checkRemainingChars()
    }
    
    //MARK: ==================ACTIONS=====================
    @IBAction func locationButtonKeyAction(_ sender: UIButton) {
        performSegue(withIdentifier: "SegueLocation", sender: nil)
    }
    
    @IBAction func themeButtonKeyAction(_ sender: UIButton) {
        performSegue(withIdentifier: "SegueThemes", sender: nil)
    }
    
    @IBAction func cancelAddNewsAction(_ sender: UIButton) {
        closeAll()
    }
    
    @IBAction func addNewsAction(_ sender: Any) {
        createNewsTextView.becomeFirstResponder()
        moveAddNewsView()
        createNewsTextView!.delegate = self
    }
    
    @IBAction func locationButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "SegueLocation", sender: self)
    }
    
    func closeAll() {
        createNewsTextView.resignFirstResponder()
        moveCloseAddNewsView()
    }
    
    func moveAddNewsView() {
        UIView.animate(withDuration: 0.5) {
            self.topAddNewsViewConstraint.constant = +Constants.TopNewsViewConstraint
            self.keyboardViewConstraint.constant = CGFloat(self.boardHeight)
            self.view.layoutIfNeeded()
        }
        pageView.isUserInteractionEnabled = false
    }
    
    func moveCloseAddNewsView() {
        UIView.animate(withDuration: 0.5) {
            self.topAddNewsViewConstraint.constant = -CGFloat(Constants.TopNewsViewConstraint)
            self.keyboardViewConstraint.constant = -CGFloat(self.boardHeight)
            self.view.layoutIfNeeded()
        }
        pageView.isUserInteractionEnabled = true
    }
    
    func getData() {
        do {
            blockNews = try context.fetch(BlockNews.fetchRequest())
        }
        catch {
            print("Fetching Failed")
        }
    }
    
    //MARK: ==================REQUEST NEWS=====================
    func postNews() {
        //add our field to request
        let newsText = createNewsTextView?.text
        let str = String((newsText?.utf8)!)
        let newsLocation = saveLoc
        let newsThemes = saveThem
        
        // Add URL parameters
        let urlParams = [
            "news_text": str,
            "news_location": newsLocation,
            "news_theme": newsThemes,
            "news_group": "0",
            ]
        
        // Fetch Request
        Alamofire.request("http://streams.fm/api2.php", method: .get, parameters: urlParams)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if (response.result.error == nil) {
                    debugPrint("HTTP Response Body: \(String(describing: response.data))")
                }
                else {
                    debugPrint("HTTP Request failed: \(String(describing: response.result.error))")
                }
        }
    }
    
    func newsRequestWithParametrs() {
        // Add URL parameters
        let urlParams = [
            "news_location": saveLoc,
            "news_theme": "",
            "language": language
        ]
        
        // Fetch Request
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
                            var sectionTitle : String?
                            var dateArray = [String]()
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
                                        print("date", date)
                                    }
                                    
                                    if let text = newsItem["news_text"].string {
                                        newsArray.append(text)
                                        print("text", text)
                                    }
                                    
                                }
                            }
                            
                            if let themes = item["news_theme"].string {
                                sectionTitle = themes
                                print("themes", themes)
                            }
                            
                            if let location = item["attributes"][0]["news_location"].string {
                                locationArray = location
                                print("location", location)
                            }
                            
                            resultDataSource.append(Objects(newsSubjects: sectionTitle, newsTitle: newsArray, newsDate: dateArray, newsLocation: locationArray, newsID: idNews))
                            
                        }
                        
                        if resultDataSource.isEmpty {
                            self.objectsArray = []
                        }
                        
                        self.objectsArray = resultDataSource
                        
                        print("newsRequestWithParametrs", self.objectsArray)
                        
                        self.pagingViewController.reloadData()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
                    }
                }
                else {
                    debugPrint("HTTP Request failed: \(String(describing: response.result.error))")
                }
        }
    }
    
    func locationRequest() {
        modelArrayLocation = []
        // Add URL parameters
        let urlParams = [
            "language": language
        ]
        
        Alamofire.request("http://streams.fm/country.php", method: .get, parameters: urlParams)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if (response.result.error == nil) {
                    let json = JSON(response.result.value as Any)
                    
                    if let news = json[].array {
                        for item in news {
                            
                            if let location = item["name"].string {
                                self.modelArrayLocation.append(location)
                            }
                        }
                    }
                    //If succes
                    
                }
                else {
                    debugPrint("HTTP Request failed: \(String(describing: response.result.error))")
                    //if error
                    
                }
        }
    }
    
    func themeRequest() {
        modelArrayTheme = []
        // Add URL parameters
        let urlParams = [
            "language": language
        ]
        
        Alamofire.request("http://streams.fm/api6.php", method: .get, parameters: urlParams)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if (response.result.error == nil) {
                    let json = JSON(response.result.value as Any)
                    
                    if let news = json[].array {
                        for item in news {
                            
                            if let location = item["selection"].string {
                                self.modelArrayTheme.append(location)
                            }
                        }
                    }
                    //If succes
                    
                }
                else {
                    debugPrint("HTTP Request failed: \(String(describing: response.result.error))")
                    //if error
                    
                }
        }
    }
    
    //MARK: ==================ALERTS=====================
    func showAlert() {
        // create the alert
        let uiAlert = UIAlertController(title: Strings.noHasSharedNews, message: Strings.createNews, preferredStyle: UIAlertControllerStyle.alert)
        self.present(uiAlert, animated: true, completion: nil)
        
        // add an action (YES)
        uiAlert.addAction(UIAlertAction(title: Strings.buttonYes, style: .default, handler: { action in
            self.performSegue(withIdentifier: "AddNewsSegue", sender: nil)
            print("Click YES button")
        }))
        
        // add an action (NO)
        uiAlert.addAction(UIAlertAction(title: Strings.buttonNo, style: .cancel, handler: { action in
            print("Click NO button")
        }))
    }
    
    func showErrorAlert() {
        // create the alert
        let uiAlert = UIAlertController(title: Strings.noConnectionServer, message: Strings.checkInternetConnection, preferredStyle: UIAlertControllerStyle.alert)
        self.present(uiAlert, animated: true, completion: nil)
        
        // add an action (Retry)
        uiAlert.addAction(UIAlertAction(title: Strings.retry, style: .default, handler: { action in
            self.checkingConnection()
            print("Click retry button")
        }))
        
        // add an action (cancel)
        uiAlert.addAction(UIAlertAction(title: Strings.retryLater, style: .cancel, handler: { action in
            print("Click of cancel button")
        }))
    }
    
    func showAlertWhenFieldsEmpty() {
        let alertController = UIAlertController(title: Strings.attention, message: Strings.fillAllFields, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: Strings.buttonYes, style: .default, handler: { action in
            
            print("Click YES button")
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueLocation" {
            let locVC = segue.destination as! LocationTableVС
            locVC.delegate = self
            locVC.modelLocation = modelArrayLocation
        }
        
        if segue.identifier == "SegueLocation" {
            if let modalVC1 = segue.destination as? LocationTableVС {
                modalVC1.delegateForButton = self
                modalVC1.modelLocation = modelArrayLocation
            }
        }
        
        if segue.identifier == "SegueThemes" {
            let thmVC = segue.destination as! ThemesTableVС
            thmVC.delegate = self
            thmVC.modelTheme = modelArrayTheme
        }
    }
    
}

extension ViewController: PagingViewControllerDataSource {
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
        return PagingIndexItem(index: index, title: objectsArray[index].newsSubjects!) as! T
    }
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
        
        return NewsTableViewController(news: objectsArray[index].newsTitle, date: objectsArray[index].newsDate, id: objectsArray[index].newsID)
    }
    
    func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int {
        return objectsArray.count
    }
}

extension ViewController: PagingViewControllerDelegate {
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, widthForPagingItem pagingItem: T, isSelected: Bool) -> CGFloat? {
        guard let item = pagingItem as? PagingIndexItem else { return 0 }
        let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        pagingViewController.selectedTextColor = UIColor(red:0.44, green:0.44, blue:0.44, alpha:1.0)
        pagingViewController.textColor = UIColor(red:0.44, green:0.44, blue:0.44, alpha:1.0)
        pagingViewController.indicatorColor = #colorLiteral(red: 0.2003779113, green: 0.5293136239, blue: 0.7496610284, alpha: 1)
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: pagingViewController.menuItemSize.height)
        let attributes = [NSAttributedStringKey.font: pagingViewController.font]
        let rect = item.title.boundingRect(with: size,
                                           options: .usesLineFragmentOrigin,
                                           attributes: attributes,
                                           context: nil)
        
        let width = ceil(rect.width) + insets.left + insets.right
        
        if isSelected {
            return width * 1.5
        } else {
            return width
        }
    }
    
}
