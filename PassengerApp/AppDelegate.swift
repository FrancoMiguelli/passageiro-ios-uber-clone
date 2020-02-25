//
//  AppDelegate.swift
//  Homo Driver
//
//  Created by Marlon da Rocha on 06/01/2019.
//  Copyright © 2019 Marlon da Rocha. All rights reserved.
//

import UIKit
import GoogleMaps
import AVFoundation
import GoogleSignIn
import Firebase
import Fabric
import Crashlytics
import FBSDKCoreKit
import TwitterCore
import TwitterKit
import IQKeyboardManagerSwift
import Braintree

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GeneralFunctions.saveValue(key: "SERVERURL", value: CommonUtils.webServer as AnyObject)
        
        Configurations.setAppLocal()
        Fabric.with([Crashlytics.self])
        
        Configurations.clearSDMemory()
        
        GeneralFunctions.saveValue(key: Utils.IS_WALLET_AMOUNT_UPDATE_KEY, value: "false" as AnyObject)
        
        if launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] != nil {
            //            (GeneralFunctions()).setError(uv: Application.window!.rootViewController!, title: "", content: "From Push")
            let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as! [AnyHashable : Any]
            
            let notification = userInfo["aps"] as? NSDictionary
            
            if(notification?.get("body") != "" && (notification!.get("body")).getJsonDataDict().get("MsgType") == "CHAT"){
                
                //            if(Application.window != nil && Application.window?.rootViewController != nil && application.applicationState == UIApplicationState.active && Utils.isMyAppInBackground() == false && notification?.get("gcm.message_id") != ""){
                //                (GeneralFunctions()).setError(uv: Application.window!.rootViewController!, title: "", content: notification!.get("alert"))
                //            }else
                
                if(Application.window != nil && Application.window?.rootViewController != nil){
                    
                    if(GeneralFunctions.getVisibleViewController(Application.window!.rootViewController) != nil && String(describing: GeneralFunctions.getVisibleViewController(Application.window!.rootViewController)!) != "ChatUV"){
                        GeneralFunctions.saveValue(key: "OPEN_MSG_SCREEN", value: notification!.get("body") as AnyObject)
                    }
                }
                
            }else if(notification?.get("body") != "" && ((notification!.get("body")).getJsonDataDict().get("MsgType") == "TripCancelledByDriver" || (notification!.get("body")).getJsonDataDict().get("Message") == "TripCancelledByDriver" || (notification!.get("body")).getJsonDataDict().get("Message") == "TripEnd" || (notification!.get("body")).getJsonDataDict().get("MsgType") == "TripEnd")){
                
                if(Application.window != nil && Application.window?.rootViewController != nil){
                    
                    if(GeneralFunctions.getVisibleViewController(Application.window!.rootViewController) != nil && String(describing: GeneralFunctions.getVisibleViewController(Application.window!.rootViewController)!) != "RatingUV"){
                        GeneralFunctions.saveValue(key: "OPEN_RATING_SCREEN", value: "\((notification!.get("body")).getJsonDataDict().get("iTripId"))" as AnyObject)
                    }
                }
                
            }
            
        }
        
        Configurations.setAppThemeNavBar()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = (GeneralFunctions()).getLanguageLabel(origValue: "Done", key: "LBL_DONE")
        IQKeyboardManager.shared.disabledToolbarClasses.append(ChatUV.self)
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(ChatUV.self)
        
        //        Fabric.with([Twitter.self])
        //        Fabric.with([STPAPIClient.self, Twitter.self])
        
        //        FIRInstanceID.instanceID().delete { (err:Error?) in
        //            if err != nil{
        //                print(err.debugDescription);
        //            } else {
        //                print("Token Deleted");
        //            }
        //        }
        
        //AnalyticsConfiguration.shared().setAnalyticsCollectionEnabled(true)
        
        FirebaseApp.configure()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        LocalNotification.registerForLocalNotification(on: UIApplication.shared)
        GeneralFunctions.registerRemoteNotification()
        
        Crashlytics.sharedInstance().setUserIdentifier("\(Utils.appUserType.uppercased())_\(GeneralFunctions.getMemberd())")
        
        BTAppSwitch.setReturnURLScheme("\(Bundle.main.bundleIdentifier!).payments")
        
        registerBackgroundTask()
        return true
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Homo_Driver")
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
    
    // iOS 9 and below
    lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Homo_Driver", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()//end session iOS 9.0 Core Data

    // MARK: - Core Data Saving support
    func saveContext () {
        if #available(iOS 10.0, *) {
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
        } else {
            // iOS 9.0 and below - however you were previously handling it
            if managedObjectContext.hasChanges {
                do {
                    try managedObjectContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                    abort()
                }
            }
            
        }
    }
    //Comentada rotina (substituída pela rotina acima) para permitir salvar dados também em iOS 9 ou abaixo
    /*func saveContext () {
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
    }*/
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskIdentifier.invalid
    }

}

