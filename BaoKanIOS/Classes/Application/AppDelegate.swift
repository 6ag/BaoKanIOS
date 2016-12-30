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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupRootViewController() // 配置控制器
        setupGlobalStyle()        // 配置全局样式
        setupGlobalData()         // 配置全局数据
        setupKeyBoardManager()    // 配置键盘管理
        setupShareSDK()           // 配置shareSDK
        setupJPush(launchOptions) // 配置JPUSH
        
        return true
    }
    
    /**
     配置全局数据
     */
    fileprivate func setupGlobalData() {
        
        // 设置初始正文字体大小
        if UserDefaults.standard.string(forKey: CONTENT_FONT_TYPE_KEY) == nil || UserDefaults.standard.integer(forKey: CONTENT_FONT_SIZE_KEY) == 0 {
            // 字体  16小   18中   20大   22超大  24巨大   26极大  共6个等级，可以用枚举列举使用
            UserDefaults.standard.set(18, forKey: CONTENT_FONT_SIZE_KEY)
            UserDefaults.standard.set("", forKey: CONTENT_FONT_TYPE_KEY)
            UserDefaults.standard.set(nil, forKey: "selectedArray")
            UserDefaults.standard.set(nil, forKey: "optionalArray")
        }
        
        // 验证缓存的账号是否有效
        JFAccountModel.checkUserInfo({})
        
        // 是否需要更新本地搜索关键词列表
        JFNetworkTool.shareNetworkTool.shouldUpdateKeyboardList({ (update) in
            if update {
                JFNewsDALManager.shareManager.updateSearchKeyListData()
            }
        })
    }
    
    /**
     配置shareSDK
     */
    fileprivate func setupShareSDK() -> Void {
        
//        ShareSDK.registerApp(SHARESDK_APP_KEY,
//                             activePlatforms: [
//                                SSDKPlatformType.typeSinaWeibo.rawValue,
//                                SSDKPlatformType.typeQQ.rawValue,
//                                SSDKPlatformType.typeWechat.rawValue],
//                             onImport: {(platform : SSDKPlatformType) -> Void in
//                                switch platform {
//                                case SSDKPlatformType.typeWechat:
//                                    ShareSDKConnector.connectWeChat(WXApi.classForCoder())
//                                case SSDKPlatformType.typeQQ:
//                                    ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
//                                default:
//                                    break
//                                }},
//                             onConfiguration: {(platform : SSDKPlatformType,appInfo : NSMutableDictionary!) -> Void in
//                                switch platform {
//                                case SSDKPlatformType.typeSinaWeibo:
//                                    appInfo.ssdkSetupSinaWeibo(byAppKey: WB_APP_KEY, appSecret : WB_APP_SECRET, redirectUri : WB_REDIRECT_URL, authType : SSDKAuthTypeBoth)
//                                case SSDKPlatformType.typeWechat:
//                                    appInfo.ssdkSetupWeChat(byAppId: WX_APP_ID, appSecret: WX_APP_SECRET)
//                                case SSDKPlatformType.typeQQ:
//                                    appInfo.ssdkSetupQQ(byAppId: QQ_APP_ID, appKey: QQ_APP_KEY, authType: SSDKAuthTypeBoth)
//                                default:
//                                    break
//                                }})
    }
    
    /**
     配置键盘管理者
     */
    fileprivate func setupKeyBoardManager() {
        IQKeyboardManager.sharedManager().enable = true
    }
    
    /**
     全局样式
     */
    fileprivate func setupGlobalStyle() {
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        JFProgressHUD.setupHUD() // 配置HUD
    }
    
    /**
     根控制器
     */
    fileprivate func setupRootViewController() {
        window = UIWindow(frame: UIScreen.main.bounds)
        if isNewVersion() {
            window?.rootViewController =  JFNewFeatureViewController()
            JFAccountModel.logout()
        } else {
            window?.rootViewController = JFTabBarController()
        }
        window?.makeKeyAndVisible()
    }
    
    /**
     判断是否是新版本
     */
    fileprivate func isNewVersion() -> Bool {
        // 获取当前的版本号
        let versionString = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        print(versionString)
        
        let currentVersion = Double(versionString)!
        
        // 获取到之前的版本号
        let sandboxVersionKey = "sandboxVersionKey"
        let sandboxVersion = UserDefaults.standard.double(forKey: sandboxVersionKey)
        
        // 保存当前版本号
        UserDefaults.standard.set(currentVersion, forKey: sandboxVersionKey)
        UserDefaults.standard.synchronize()
        
        // 对比
        return currentVersion > sandboxVersion
    }
    
    /**
     配置极光推送
     */
    fileprivate func setupJPush(_ launchOptions: [AnyHashable: Any]?) {
        JPUSHService.register(forRemoteNotificationTypes: UIUserNotificationType.badge.rawValue | UIUserNotificationType.alert.rawValue | UIUserNotificationType.sound.rawValue, categories: nil)
        JPUSHService.setup(withOption: launchOptions, appKey: JPUSH_APP_KEY, channel: JPUSH_CHANNEL, apsForProduction: JPUSH_IS_PRODUCTION)
        JPUSHService.crashLogON()
        
        // 延迟发送通知（app被杀死进程后收到通知，然后通过点击通知打开app在这个方法中发送通知）
        perform(#selector(sendNotification(_:)), with: launchOptions, afterDelay: 1.5)
    }
    
    /**
     发送通知
     */
    @objc fileprivate func sendNotification(_ launchOptions: [AnyHashable: Any]?) {
        if let options = launchOptions {
            let userInfo = options[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]
            if let info = userInfo {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "didReceiveRemoteNotificationOfJPush"), object: nil, userInfo: info)
            }
        }
    }
    
    /**
     传递deviceToken注册远程通知
     */
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    /**
     注册远程通知失败
     */
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("did Fail To Register For Remote Notifications With Error: \(error)")
    }
    
    /**
     iOS7后接收到远程通知
     */
    private func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: AnyObject], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
        
        if application.applicationState == .background || application.applicationState == .inactive {
            application.applicationIconBadgeNumber = 0
            NotificationCenter.default.post(name: Notification.Name(rawValue: "didReceiveRemoteNotificationOfJPush"), object: nil, userInfo: userInfo)
        } else if application.applicationState == .active {
            application.applicationIconBadgeNumber = 0
            
            let message = userInfo["aps"]!["alert"] as! String
            let alertC = UIAlertController(title: "收到新的消息", message: message, preferredStyle: UIAlertControllerStyle.alert)
            let confrimAction = UIAlertAction(title: "查看", style: UIAlertActionStyle.destructive, handler: { (action) in
                NotificationCenter.default.post(name: Notification.Name(rawValue: "didReceiveRemoteNotificationOfJPush"), object: nil, userInfo: userInfo)
            })
            let cancelAction = UIAlertAction(title: "忽略", style: UIAlertActionStyle.default, handler: { (action) in
                
            })
            alertC.addAction(confrimAction)
            alertC.addAction(cancelAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertC, animated: true, completion: nil)
        }
    }
    
    /**
     接收到本地通知
     */
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        JPUSHService.showLocalNotification(atFront: notification, identifierKey: nil)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "BaoKanIOS", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}

