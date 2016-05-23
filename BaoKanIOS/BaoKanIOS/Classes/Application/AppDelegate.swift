//
//  AppDelegate.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var userInfo: [NSObject : AnyObject]?
    var haveNewMessage = false
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        setupGlobalStyle()        // 配置全局样式
        setupRootViewController() // 配置控制器
        setupJPush(launchOptions) // 配置极光推送
        setupKeyBoardManager()    // 配置键盘管理者
        
        // app是关闭状态接收到通知
        if haveNewMessage {
            NSNotificationCenter.defaultCenter().postNotificationName("didReceiveRemoteNotificationOfJPush", object: userInfo)
            haveNewMessage = false
        }
        
        return true
    }
    
    /**
     配置键盘管理者
     */
    private func setupKeyBoardManager() {
        IQKeyboardManager.sharedManager().enable = true
    }
    
    /**
     配置极光推送
     */
    private func setupJPush(launchOptions: [NSObject: AnyObject]?) {
        
        JPUSHService.registerForRemoteNotificationTypes(UIUserNotificationType.Badge.rawValue | UIUserNotificationType.Alert.rawValue, categories: nil)
        JPUSHService.setupWithOption(launchOptions, appKey: JPUSH_APP_KEY, channel: JPUSH_CHANNEL, apsForProduction: JPUSH_IS_PRODUCTION)
    }
    
    /**
     全局样式
     */
    private func setupGlobalStyle() {
        UIApplication.sharedApplication().statusBarHidden = false
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        JFProgressHUD.setupHUD() // 配置HUD
    }
    
    /**
     根控制器
     */
    private func setupRootViewController() {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = JFTabBarController()
        window?.makeKeyAndVisible()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
//        NSNotificationCenter.defaultCenter().postNotificationName("DidRegisterRemoteNotificationOfJPush", object: deviceToken)
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("did Fail To Register For Remote Notifications With Error: \(error)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        // app是激活状态收到通知
        NSNotificationCenter.defaultCenter().postNotificationName("didReceiveRemoteNotificationOfJPush", object: userInfo)
        
        self.userInfo = userInfo
        haveNewMessage = true
        
        application.applicationIconBadgeNumber = 0
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.NewData)
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        JPUSHService.showLocalNotificationAtFront(notification, identifierKey: nil)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
    }

    func applicationWillTerminate(application: UIApplication) {
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("BaoKanIOS", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

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
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
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

