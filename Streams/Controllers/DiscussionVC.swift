//
//  DiscussionVC.swift
//  Streams
//
//  Created by Igor Karyi on 07.02.2018.
//  Copyright © 2018 Igor Karyi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class DiscussionVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addDiscussionView: UIView!
    @IBOutlet weak var topConstraintAddDiscussion: NSLayoutConstraint!
    @IBOutlet weak var nameDiscussionField: UITextField!
    @IBOutlet weak var textViewDiscussionField: UITextView!
    @IBOutlet weak var lastWordsLabel: UILabel!
    @IBOutlet weak var addAndCancelButton: UIBarButtonItem!
    @IBOutlet weak var notPrivateDiscussionsLabel: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var discussions: [Discussions] = []
    
    var stringDiscussions = String()
    
    var countCharacters = 100
    
    var stringID = String()
    
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Strings.myDiscussion
        lastWordsLabel.text = "\(Strings.left) 100 \(Strings.characters)"
        nameDiscussionField.placeholder = Strings.name
        notPrivateDiscussionsLabel.text = Strings.noClosedDiscussion
        addDiscussionViewMenu()

        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .white
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
        nameDiscussionField!.delegate = self
        textViewDiscussionField!.delegate = self
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.swipeUp))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.addDiscussionView.addGestureRecognizer(swipeUp)
        self.view.addGestureRecognizer(swipeUp)
    }
    
    @objc func swipeUp() {
        print("swipeUp")
        defaultValues()
        moveCloseAddDiscussionView()
    }
    
    //hide navigation ore show
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        checkingConnection()
        tableView.reloadData()
        self.tabBarController?.navigationItem.hidesBackButton = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (navigationController?.topViewController != self) {
            navigationController?.navigationBar.isHidden = true
        }
        super.viewWillDisappear(animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        performAction()
        return true
    }
    
    func addDiscussionViewMenu() {
        topConstraintAddDiscussion.constant = -Constants.TopConstraintAddDiscussion
        addDiscussionView.clipsToBounds = true
        addDiscussionView.layer.cornerRadius = Constants.CornerRadiusForView
        addDiscussionView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    func moveAddDiscussionView() {
        nameDiscussionField.becomeFirstResponder()
        UIView.animate(withDuration: 0.5) {
            self.topConstraintAddDiscussion.constant = 0
            self.view.layoutIfNeeded()
        }
        tableView.isUserInteractionEnabled = false
    }
    
    func moveCloseAddDiscussionView() {
        nameDiscussionField.resignFirstResponder()
        textViewDiscussionField.resignFirstResponder()
        UIView.animate(withDuration: 0.5) {
            self.topConstraintAddDiscussion.constant = -Constants.TopConstraintAddDiscussion
            self.view.layoutIfNeeded()
        }
        
        let deadlineTime = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.checkingConnection()
            self.tableView.reloadData()
            self.addAndCancelButton.image = UIImage(named: "plus")
        }
        tableView.isUserInteractionEnabled = true
    }
    
    @objc func refresh(sender:AnyObject) {
        tableView.reloadData()
    }
    
    //save news
    func performAction() {
        if (textViewDiscussionField.text?.isEmpty)! || (nameDiscussionField.text?.isEmpty)! {
            showAlertWhenFieldsEmpty()
        } else {
            saveNews()
            print("performAction")
        }
    }
    
    func saveNews() {
        print("saveNews")
        checkForSameName()
        moveCloseAddDiscussionView()
    }
    
    //character limit on textView
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            performAction()
            return false
        }
        let newText = (textViewDiscussionField.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 100
    }
    
    func checkRemainingChars() {
        let allowedChars = countCharacters
        let charsInTextView = -textViewDiscussionField.text.count
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
    
    //MARK: ACTIONS
    @IBAction func closeAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: false)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploadNews"), object: nil)
    }

    @IBAction func addDiscussionAction(_ sender: UIBarButtonItem) {
        addDiscussion()
    }
    
    func addDiscussion() {
        if topConstraintAddDiscussion.constant == -Constants.TopConstraintAddDiscussion {
            moveAddDiscussionView()
            addAndCancelButton.image = UIImage(named: "delete")
        } else if topConstraintAddDiscussion.constant == 0 {
            moveCloseAddDiscussionView()
            addAndCancelButton.image = UIImage(named: "plus")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if self.discussions.isEmpty {
                self.notPrivateDiscussionsLabel.isHidden = false
                self.tableView.separatorStyle = .none
            } else {
                self.notPrivateDiscussionsLabel.isHidden = true
                self.tableView.separatorStyle = .singleLine
            }
        
        return discussions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DiscussionCell
        
        let diskusion = discussions[indexPath.row]
        
        stringDiscussions = diskusion.nameSubject!
        stringID = diskusion.groupID!
        
        if let nameSubject = diskusion.nameSubject {
            
            cell.subjectLabel?.text? = nameSubject.uppercased()
        }
        
        if let nameSubject = diskusion.nameSubject {
            cell.lowerSubjectLabel?.text? = nameSubject
        }
        
        if let groupID = diskusion.groupID {
            cell.idSubjectLabel?.text = groupID
        }
        
        self.refreshControl.endRefreshing()

        return cell
    }
    
    func checkingConnection() {
        if Connectivity.isConnectedToInternet {
            print("Connected")
            getData()
        } else {
            print("No Internet")
            showErrorAlert()
        }
    }
    
    func getData() {
        do {
            discussions = try context.fetch(Discussions.fetchRequest())
        }
        catch {
            print("Fetching Failed")
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let discussion = discussions[indexPath.row]
            context.delete(discussion)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            do {
                discussions = try context.fetch(Discussions.fetchRequest())
            }
            catch {
                print("Fetching Failed")
            }
        }
        tableView.reloadData()
    }
    
    //MARK: ==================ALERTS=====================
    func showAlertWhenFieldsEmpty() {
        let alertController = UIAlertController(title: Strings.attention, message: Strings.fillAllFields, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: Strings.buttonYes, style: .default, handler: { action in
            
            print("Click YES button")
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }

    func showAlertWhenSameName() {
        let alertController = UIAlertController(title: Strings.attention, message: Strings.groupWhenSameName, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: Strings.buttonYes, style: .default, handler: { action in
            
            print("Click YES button")
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
        
        // add an action (Retry)
        uiAlert.addAction(UIAlertAction(title: Strings.retryLater, style: .default, handler: { action in
            
            print("Click retry Later button")
        }))
    }
    
    func defaultValues() {
        textViewDiscussionField.text = ""
        nameDiscussionField.text = ""
        countCharacters = 100
        lastWordsLabel.text = "\(Strings.left) \(countCharacters) \(Strings.characters)"
    }
    
    //MARK: ==================DataBase=====================
    func postNews() {
        //add our field to request
        let newsText = textViewDiscussionField?.text
        let str = String((newsText?.utf8)!)
        
        // Add URL parameters
        let urlParams = [
            "news_text": str,
            ]
        
        // Fetch Request
        Alamofire.request("http://streams.fm/api4.php", method: .get, parameters: urlParams)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if (response.result.error == nil) {
                    let json = JSON(response.result.value as Any)
                    print(json)
                    let newsGroup = json["news_group"].string
                    print(newsGroup!)
                    self.stringID = (newsGroup)!
                    print("ID будет", self.stringID)
                    self.saveToCoreData()
                    self.defaultValues()
                }
                else {
                    debugPrint("HTTP Request failed: \(String(describing: response.result.error))")
                }
        }
    }
    
    func saveToCoreData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let discussion = Discussions(context: context)
        discussion.nameSubject = nameDiscussionField.text!
        print("stringID", self.stringID)
        discussion.groupID = self.stringID
        // Save the data to coredata
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        DispatchQueue.main.async {
            self.checkingConnection()
            self.tableView.reloadData()
        }
    }
    
    func checkForSameName() {
        let nameField = nameDiscussionField.text
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Discussions")
        let predicate = NSPredicate(format: "nameSubject == %@", nameField!)
        request.predicate = predicate
        request.fetchLimit = 1
        
        do{
            let count = try managedContext.count(for: request)
            if(count == 0){
                // no matching object
                
                print("no")
                postNews()
            }
            else{
                print("already")
                showAlertWhenSameName()
            }
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailDiscussionSegue" {
            let detailVC: DetailDiscussionVC? = segue.destination as? DetailDiscussionVC
            let cell: DiscussionCell? = sender as? DiscussionCell
            
            if cell != nil && detailVC != nil {
                detailVC?.modelSubjectDiscussion = cell?.lowerSubjectLabel?.text
                detailVC?.modelSubjectID = cell?.idSubjectLabel?.text
            }
        }
        
    }
    
}
