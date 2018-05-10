//
//  DetailDiscussionVC.swift
//  Streams
//
//  Created by Igor Karyi on 12.02.2018.
//  Copyright © 2018 Igor Karyi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class DetailDiscussionVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addDiscussionView: UIView!
    @IBOutlet weak var discussionTextView: UITextView!
    @IBOutlet weak var lastWordsLabel: UILabel!
    @IBOutlet weak var topConstraintAddDiscussionView: NSLayoutConstraint!
    @IBOutlet weak var addUsersView: UIView!
    @IBOutlet weak var subjectNameLabel: UILabel!
    @IBOutlet weak var heightAddUsersViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var addParticipant: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var addNewsButton: UIButton!
    
    var modelText = [String]()
    var modelLocation = [String]()
    var modelTheme = [String]()
    var modelDate = [String]()
    var modelId = [String]()
    
    var selectedCellTitle = String()
    var selectedCellID = String()
    let selectedCellCurrentDateTime = Date()
    var selectedIndexPath = Int()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var blockNews: [BlockNews] = []
    
    var countCharacters = 100
    
    var refreshControl: UIRefreshControl!
    
    var modelSubjectDiscussion: String!
    var modelSubjectID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        
        addNewsButton.setTitle(Strings.addNewsButton, for: .normal)
        addParticipant.setTitle(Strings.addParticipant, for: .normal)
        buttonCancel.setTitle(Strings.buttonCancel, for: .normal)
        lastWordsLabel.text = "\(Strings.left) 100 \(Strings.characters)"
        
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .white
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView?.addSubview(self.refreshControl)
        
        if UIDevice().userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height == Constants.ScreenDevice {
                heightAddUsersViewConstraint.constant = Constants.HeightBottomViewConstraintOnBigDevice
            }
        }
        
        addViewAddUsers()
        
        topConstraintAddDiscussionView.constant = -Constants.TopNewsViewConstraint
        
        self.tableView.estimatedRowHeight = Constants.SmallHeightTable
        
        tableView.tableFooterView = UIView(frame: .zero)
        
        subjectNameLabel.text = modelSubjectDiscussion
        
        checkingConnection()
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.swipeUp))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.addDiscussionView.addGestureRecognizer(swipeUp)
        self.view.addGestureRecognizer(swipeUp)
    }
    
    func getData() {
        do {
            blockNews = try context.fetch(BlockNews.fetchRequest())
        }
        catch {
            print("Fetching Failed")
        }
    }
    
    func checkingConnection() {
        if Connectivity.isConnectedToInternet {
            print("Connected")
            getData()
            loadNews()
        } else {
            print("No Internet")
            showErrorAlert()
        }
    }
    
    @objc func swipeUp() {
        print("swipeUp")
        moveCloseAddDiscussionView()
    }
    
    func addViewAddUsers() {
        addUsersView.clipsToBounds = true
        addUsersView.layer.cornerRadius = Constants.CornerRadiusForBottomView
        addUsersView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    //hide navigation bar on first screen
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (navigationController?.topViewController != self) {
            navigationController?.navigationBar.isHidden = false
        }
        super.viewWillDisappear(animated)
    }
    
    @objc func refresh(sender:AnyObject) {
        clearRequestReload()
    }
    
    // MARK: ACTIONS
    @IBAction func addMemberAction(_ sender: Any) {
        let titleString = modelSubjectID
        
        let firstActivityItem = "\(Strings.joinToGroup) mixoft://streams.fm/\(titleString!)"
        
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func homeAction(_ sender: UIButton) {
        backToHome()
    }
    
    @IBAction func addNewsAction(_ sender: UIButton) {
        moveAddDiscussionView()
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        moveCloseAddDiscussionView()
    }
    
    func backToHome() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is ViewController {
                guard let navVC = self.navigationController?.viewControllers else {return}
                
                for i in navVC {
                    if ((i as? ViewController) != nil) {
                        self.navigationController!.popToViewController(i, animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: TABLE VIEW
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelText.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("SmallCell", owner: self, options: nil)?.first as! SmallCell
        
        self.tableView.separatorStyle = .none
        
        cell.timeLabel.text = modelDate[indexPath.row]
        cell.titleLabel.text = modelText[indexPath.row]
        
        cell.titleLabel.numberOfLines = 0
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedCellID = modelId[indexPath.row]
        selectedIndexPath = indexPath.row
        print(selectedCellTitle)
        showActionAlert()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        self.tableView.separatorStyle = .none
    }
    
    func clearRequestReload() {
        clearTableView()
        DispatchQueue.main.async {
            self.checkingConnection()
        }
    }
    
    func clearTableView() {
        modelText.removeAll()
        modelDate.removeAll()
        modelTheme.removeAll()
        tableView.reloadData()
    }
    
    func moveAddDiscussionView() {
        discussionTextView!.delegate = self
        discussionTextView.becomeFirstResponder()
        UIView.animate(withDuration: 0.5) {
            self.topConstraintAddDiscussionView.constant = 0
            self.view.layoutIfNeeded()
        }
        tableView.isUserInteractionEnabled = false
    }
    
    func moveCloseAddDiscussionView() {
        discussionTextView.resignFirstResponder()
        UIView.animate(withDuration: 0.5) {
            self.topConstraintAddDiscussionView.constant = -Constants.TopNewsViewConstraint
            self.view.layoutIfNeeded()
        }
        tableView.isUserInteractionEnabled = true
    }
    
    //MARK: ==================ALERTS=====================
    func noNewsInGroupDelete() {
        let alertController = UIAlertController(title: Strings.noSuchGroup, message: Strings.willBeRemovedFromList, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: Strings.buttonYes, style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
            self.deleteGroupWhenNoNews()
        }))
        
        self.present(alertController, animated: true, completion: nil)
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
    
    func deleteGroupWhenNoNews() {
        let groupID = modelSubjectID
        let nameSubject = modelSubjectDiscussion
        
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Discussions")
        fetchRequest.predicate = NSPredicate(format: "groupID = %@", groupID!)
        fetchRequest.predicate = NSPredicate(format: "nameSubject = %@", nameSubject!)
        do {
            let fetchedResults =  try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            
            for entity in fetchedResults! {
                managedContext.delete(entity)
                do {
                    try managedContext.save()
                    print("group deleted!")
                    self.dismiss(animated: true, completion: nil)
                }
                catch let error as Error? {
                    print(error?.localizedDescription as Any)
                }
            }
        }
        catch _ {
            print("Could not delete")
        }
    }
    
    //save news
    func performAction() {
        if (discussionTextView.text?.isEmpty)! {
            showAlertWhenFieldsEmpty()
        } else {
            postNewsWithGroupID()
            saveNews()
            print("performAction")
        }
    }
    
    func saveNews() {
        print("saveNews")
        discussionTextView.text = ""
        countCharacters = 100
        lastWordsLabel.text = "\(Strings.left) \(countCharacters) \(Strings.characters)"
        
        moveCloseAddDiscussionView()
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
        let newText = (discussionTextView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 100
    }
    
    func checkRemainingChars() {
        let allowedChars = countCharacters
        let charsInTextView = -discussionTextView.text.count
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
        lastWordsLabel.text = "(\(Strings.left) \(remainingChars) \(Strings.characters))"
    }
    
    func textViewDidChange(_ textView: UITextView) {
        checkRemainingChars()
    }
    
    func loadNews() {
        //add our field to request
        let newsGroup = modelSubjectID
        
        // Add URL parameters
        let urlParams = [
            "news_group": newsGroup ?? String(),
            ]
        
        // Fetch Request
        Alamofire.request("http://streams.fm/api3.php", method: .get, parameters: urlParams)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if (response.result.error == nil) {
                    print("succsess")
                    let json = JSON(response.result.value as Any)
                    print(json)
                    if let news = json[].array {
                        for item in news {
                            if let id = item["news_id"].string {
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
                                self.modelId.append(id)
                            }
                            
                            if let text = item["news_text"].string {
                                print(text)
                                self.modelText.append(text)
                            }
                            if let date = item["news_date"].string {
                                print(date)
                                self.modelDate.append(date)
                            }
                        }
                    }
                    
                    if json["empty"].string == "empty" {
                        print("empty")
                        self.noNewsInGroupDelete()
                    } else {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing()
                        }
                    }
                    
                }
                else {
                    debugPrint("HTTP Request failed: \(String(describing: response.result.error))")
                }
        }
    }
    
    func showAlertWhenFieldsEmpty() {
        let alertController = UIAlertController(title: Strings.attention, message: Strings.fillAllFields, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: Strings.buttonYes, style: .default, handler: { action in
            
            print("Click YES button")
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showActionAlert() {
        // create the alert
        let uiAlert = UIAlertController(title: "", message: Strings.blockNews, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        uiAlert.modalPresentationStyle = .popover
        uiAlert.popoverPresentationController?.sourceView = self.tableView
        uiAlert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        
        // add an action (Block)
        uiAlert.addAction(UIAlertAction(title: Strings.block, style: .default, handler: { action in
            print("Click block button")
            self.blockNewsAndSave()
        }))
        
        // add an action (Cancel)
        uiAlert.addAction(UIAlertAction(title: Strings.buttonCancel, style: .destructive, handler: { action in
            print("Click of cancel button")
        }))
        self.present(uiAlert, animated: true, completion: nil)
    }
    
    func deleteCell(_ tag: Int) {
        let indexPath = IndexPath(row: tag, section: 0)
        modelDate.remove(at: tag)
        modelText.remove(at: tag)
        modelId.remove(at: tag)
        tableView.deleteRows(at: [indexPath], with: .fade)
        print("cell deleted")
    }
    
    func blockNewsAndSave() {
        print("selectedCellCurrentDateTime", selectedCellCurrentDateTime)
        print("selectedCellID", selectedCellID)
        saveToCoreData()
        deleteCell(selectedIndexPath)
    }
    
    func saveToCoreData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let blockNews = BlockNews(context: context)
        blockNews.idSelect = selectedCellID
        blockNews.dateSelect = selectedCellCurrentDateTime
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func postNewsWithGroupID() {
        //add our field to request
        let newsGroup = modelSubjectID
        let newsText = discussionTextView?.text
        let str = String((newsText?.utf8)!)
        
        // Add URL parameters
        let urlParams = [
            "news_group": newsGroup ?? String(),
            "news_text": str,
            ]
        
        // Fetch Request
        Alamofire.request("http://streams.fm/api4.php", method: .get, parameters: urlParams)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if (response.result.error == nil) {
                    let json = response.result.value as? [String: Any]
                    
                    print(json!)
                    self.clearTableView()
                    let deadlineTime = DispatchTime.now() + 0.2
                    DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                        self.checkingConnection()
                    }
                    
                }
                else {
                    debugPrint("HTTP Request failed: \(String(describing: response.result.error))")
                }
        }
    }
    
}
