//
//  AppDelegate.swift
//  Streams
//
//  Created by Igor Karyi on 01.02.2018.
//  Copyright © 2018 Igor Karyi. All rights reserved.
//

import UIKit
import CoreData
import Firebase

let selectedCellCurrentDateTime = Date()
var dateTimeDB = Date()

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
var blockNews: [BlockNews] = []

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.statusBarStyle = .lightContent
        UIApplication.shared.statusBarView?.backgroundColor = UIColor(red:0.20, green:0.53, blue:0.75, alpha:1.0)
        

        FirebaseApp.configure()
   
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL {
            let handleLink = DynamicLinks.dynamicLinks()?.handleUniversalLink(incomingURL, completion: { (dynamicLink, error) in
                if let dynamicLink = dynamicLink, let _ = dynamicLink.url
                {
                    print("Your Dynamic Link parameter: \(dynamicLink)")
                
                } else {
                    // Check for errors
                    
                }
            })
            return handleLink!
        }
        return false
    }
    
    func handleDynamicLink(_ dynamicLink: DynamicLink) {
        print("Your Dynamic Link parameter: \(dynamicLink)")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        deleteGroupWhenNoNews()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "DiscussionModels")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func deleteGroupWhenNoNews() {
        let myDate = Date().addingTimeInterval(0 - 24 * 60 * 60)
        print("myDate", myDate)
        
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"BlockNews")
        fetchRequest.predicate = NSPredicate(format: "dateSelect < %@", myDate as CVarArg)
        do {
            let fetchedResults =  try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            
            for entity in fetchedResults! {
                managedContext.delete(entity)
                do {
                    try managedContext.save()
                    print("group deleted!")
                    
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        print("url \(url)")
        print("url host :\(url.host!)")
        print("url path :\(url.path)")
        
        let urlPath : String = (url.path as String?)!
        let urlHost : String = (url.host as String?)!
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if(urlHost != "streams.fm")
        {
            print("Host is not correct")
            return false
        }
        
        if(urlPath != "/") {
            
            let ourStr = url.path
            var myID = ourStr
            myID.remove(at: myID.startIndex)
            print(myID)
            
            let innerPage: UINavigationController = mainStoryboard.instantiateViewController(withIdentifier: "StartApp") as! UINavigationController
            
            self.window?.rootViewController = innerPage
            
            let startVC = mainStoryboard.instantiateViewController(withIdentifier: "StartViewController") as! StartViewController
            innerPage.pushViewController(startVC, animated: false)

            let discVC = mainStoryboard.instantiateViewController(withIdentifier: "DiscussionVC") as! DiscussionVC
            innerPage.pushViewController(discVC, animated: false)

            let loginPageView = mainStoryboard.instantiateViewController(withIdentifier: "EnterCodeVC") as! EnterCodeVC
            loginPageView.ourID = myID
            innerPage.pushViewController(loginPageView, animated: false)
      
        }
        
        self.window?.makeKeyAndVisible()
        return true
    }
    
}

