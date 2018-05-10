//
//  DetailEnterCodeVC.swift
//  Streams
//
//  Created by Igor Karyi on 16.02.2018.
//  Copyright © 2018 Igor Karyi. All rights reserved.
//

import UIKit
import CoreData

class DetailEnterCodeVC: UIViewController {
    
    var modelText = [String]()
    var modelLocation = [String]()
    var modelTheme = [String]()
    var modelDate = [String]()

    var modelSubjectID: String!
    var titleSubField: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(modelSubjectID)
    }
    
    //hide navigation bar on first screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showAlertNameGroup()
    }
    
    func showAlertWhenSameName() {
        let alertController = UIAlertController(title: Strings.attention, message: Strings.groupWhenSameName, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: Strings.buttonYes, style: .default, handler: { action in
            
            print("Click YES button")
            self.showAlertNameGroup()
        }))      
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertNameGroup() {
        
        let alertController = UIAlertController(title: Strings.groupName, message: Strings.enterGroupName, preferredStyle: .alert)
        
        alertController.addTextField { (nameGroup) in

            if (nameGroup.text?.isEmpty)! {
                nameGroup.text = Strings.groupName
            }
        }
        
        alertController.addAction(UIAlertAction(title: Strings.buttonYes, style: .default, handler: { action in
            let nameSubField = alertController.textFields!.first!.text!
            self.titleSubField = nameSubField
            print("self.titleSubField", self.titleSubField)
            print("Click YES button")
            
            self.checkForSameName()
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func checkForSameName() {
        let currentDateTime = Date()
        
        if self.titleSubField == "" {
            self.titleSubField = "\(Strings.newGroup)-\(currentDateTime)"
        }
        
        let nameField = titleSubField
        
        print(nameField!)
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Discussions")
        let predicate = NSPredicate(format: "nameSubject == %@", nameField!)
        request.predicate = predicate
        request.fetchLimit = 1
        
        do{
            let count = try managedContext.count(for: request)
            if(count == 0){
                print("no matching object")
                
                // Save the data to coredata
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let discussion = Discussions(context: context)
                discussion.nameSubject = titleSubField
                discussion.groupID = modelSubjectID
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                self.backToListDiscussion()
            
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
