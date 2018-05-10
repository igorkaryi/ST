//
//  NewsTableViewController.swift
//  Streams
//
//  Created by imac on 20.03.2018.
//  Copyright © 2018 Igor Karyi. All rights reserved.
//

import UIKit
import CoreData

class NewsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var newsArray = [String]()
    var dateArray = [String]()
    var idNewsArray = [String]()
    
    var myTableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    private let cellId = "MyCell"
    
    //for block news
    var selectedCellTitle = String()
    var selectedCellID = String()
    let selectedCellCurrentDateTime = Date()
    var selectedIndexPath = Int()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("SmallCell", owner: self, options: nil)?.first as! SmallCell
        
        self.myTableView.separatorStyle = .none
        
        cell.timeLabel?.text = dateArray[indexPath.row]
        cell.titleLabel?.text = newsArray[indexPath.row]
  
        cell.titleLabel.numberOfLines = 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myTableView.deselectRow(at: indexPath, animated: true)
        let cell = myTableView.cellForRow(at: indexPath) as! SmallCell
        selectedCellTitle = cell.titleLabel.text!
        selectedCellID = idNewsArray[indexPath.row]
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
        self.myTableView.separatorStyle = .none
    }
    
    func showActionAlert() {
        // create the alert
        let uiAlert = UIAlertController(title: "", message: Strings.youCanSharedNewsOrBlock, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        uiAlert.modalPresentationStyle = .popover
        uiAlert.popoverPresentationController?.sourceView = self.myTableView
        uiAlert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        
        // add an action (Send)
        uiAlert.addAction(UIAlertAction(title: Strings.send, style: .default, handler: { action in
            print("Click sent button")
            self.cellTapped()
        }))
        
        // add an action (Block)
        uiAlert.addAction(UIAlertAction(title: Strings.block, style: .default, handler: { action in
            print("Click block button")
            self.blockNews()
        }))
        
        // add an action (Cancel)
        uiAlert.addAction(UIAlertAction(title: Strings.buttonCancel, style: .destructive, handler: { action in
            print("Click of cancel button")
        }))
        self.present(uiAlert, animated: true, completion: nil)
    }
    
    func deleteCell(_ tag: Int) {
        let indexPath = IndexPath(row: tag, section: 0)
        newsArray.remove(at: tag)
        dateArray.remove(at: tag)
        idNewsArray.remove(at: tag)
        myTableView.deleteRows(at: [indexPath], with: .fade)
        print("cell deleted")
    }
    
    func blockNews() {
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
    
    func cellTapped() {
        let firstActivityItem = selectedCellTitle
        
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func refresh(sender:AnyObject) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploadNews"), object: nil)
        OperationQueue.main.addOperation({
            self.myTableView.reloadData()
        })
        let deadlineTime = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc func reloadNewsAfterAdded(notification: NSNotification) {
        self.myTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadNewsAfterAdded), name: NSNotification.Name(rawValue: "reload"), object: nil)
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight - barHeight - 110))
        
        myTableView.backgroundColor = .clear
        
        myTableView.register(SmallCell.self, forCellReuseIdentifier: cellId)
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
        
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .white
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        myTableView?.addSubview(self.refreshControl)
        
    }
    
    init(news: [String], date: [String], id: [String]) {
        super.init(nibName: nil, bundle: nil)
        self.newsArray = news
        self.dateArray = date
        self.idNewsArray = id
       
        print("newsArray-NewsTableViewController", newsArray)
        print("dateArray-NewsTableViewController", dateArray)
        print("idNewsArray-NewsTableViewController", idNewsArray)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

