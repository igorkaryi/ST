//
//  MenuLocationTableVС.swift
//  Streams
//
//  Created by Igor Karyi on 12.02.2018.
//  Copyright © 2018 Igor Karyi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol LocationTableVСDelegate {
    func getLocationString(info: String)
}

protocol LocationForButtonDelegate {
    func getLocationForButton(location: String)
}

class LocationTableVС: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    var modelLocation = [String]()
    
    var filteredArray = [String]()
    
    var stringVar = String()
    
    var searchController = UISearchController()
    var resultController = UITableViewController()
    
    var delegate: LocationTableVСDelegate?
    var delegateForButton: LocationForButtonDelegate?
    
    //hide navigation bar on first screen
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (navigationController?.topViewController != self) {
            navigationController?.navigationBar.isHidden = true
        }
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Strings.locationVC
        
        self.searchController = UISearchController(searchResultsController: resultController)
        tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.hidesNavigationBarDuringPresentation = false
        
        self.searchController.searchBar.tintColor = .white
        self.searchController.searchBar.placeholder = Strings.search
        self.searchController.searchBar.barTintColor = UIColor(red:0.20, green:0.53, blue:0.75, alpha:1.0)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        self.resultController.tableView.delegate = self
        self.resultController.tableView.dataSource = self
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.filteredArray = modelLocation.filter({ (array: String) -> Bool in
            
            if array.contains(searchController.searchBar.text!)
            {
                return true
            }
            else
            {
                return false
            }
            
        })
        
        self.resultController.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == resultController.tableView
        {
            return self.filteredArray.count
        }
        else
        {
            return self.modelLocation.count
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        stringVar = (cell.textLabel?.text)!
        
        let info = stringVar
        delegate?.getLocationString(info: info)
        delegateForButton?.getLocationForButton(location: info)

        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        if tableView == resultController.tableView
        {
            
            cell.textLabel?.text = self.filteredArray[indexPath.row]
        }
        else
        {
            cell.textLabel?.text = self.modelLocation[indexPath.row]
        }
        
        return cell
    }
    
}

