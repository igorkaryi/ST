//
//  EnterCodeVC.swift
//  Streams
//
//  Created by Igor Karyi on 15.02.2018.
//  Copyright © 2018 Igor Karyi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class EnterCodeVC: UIViewController {
    
    var ourID = String()
    
    var firstText = [String]()
    var firstLocation = [String]()
    var firstTheme = [String]()
    var firstDate = [String]()
    
    var enterSubjectID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ourID", ourID)
        
        checkForSameName()
        
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    deinit {
        print("deinit")
    }
    
    func enterCodeNews() {
        //add our field to request
        let newsGroup = ourID
        
        // Add URL parameters
        let urlParams = [
            "news_group": newsGroup,
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
                            if let text = item["news_text"].string {
                                print(text)
                                self.firstText.append(text)
                            }
                            if let date = item["news_date"].string {
                                print(date)
                                self.firstDate.append(date)
                            }
                        }
                    }
                    print("succsess!!!")
                    self.showAlertIFSuccsess()
                }
                    
                else {
                    self.showAlertNoSuchGroup()
                    debugPrint("error!!!")
                }
        }
    }
    
    //MARK: Alerts
    func showAlertNoSuchGroup() {
        let alertController = UIAlertController(title: Strings.noSuchGroup, message: "", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: Strings.buttonYes, style: .default, handler: { action in
            print("Click YES button")
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertIFSuccsess() {
        self.performSegue(withIdentifier: "DetailEnterCodeSegue", sender: nil)
    }
    
    func showAlertWhenGroupAlready() {
        let alertController = UIAlertController(title: Strings.attention, message: Strings.alreadyParticipatingSuchGroup, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: Strings.buttonYes, style: .default, handler: { action in
            
            print("Click YES button")
            self.backToListDiscussion()
        }))
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func checkForSameName() {
        let ourGroup = ourID
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Discussions")
        let predicate = NSPredicate(format: "groupID == %@", ourGroup)
        request.predicate = predicate
        request.fetchLimit = 1
        
        do{
            let count = try managedContext.count(for: request)
            if(count == 0){
                // no matching object
                
                print("нету")
                enterCodeNews()
            }
            else{
                print("используется")
                showAlertWhenGroupAlready()
            }
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "DetailEnterCodeSegue" {
            let detailVC: DetailEnterCodeVC? = segue.destination as? DetailEnterCodeVC
            
            detailVC?.modelText = firstText
            detailVC?.modelLocation = firstLocation
            detailVC?.modelTheme = firstTheme
            detailVC?.modelDate = firstDate
            detailVC?.modelSubjectID = ourID
            
        }
    }
    
    func backToListDiscussion() {
        
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is DiscussionVC {
                
                guard let navVC = self.navigationController?.viewControllers else {return}
                
                for i in navVC {
                    if ((i as? DiscussionVC) != nil) {
                        self.navigationController!.popToViewController(i, animated: false)
                    }
                }
                
                
            }
        }
    }
    
}
