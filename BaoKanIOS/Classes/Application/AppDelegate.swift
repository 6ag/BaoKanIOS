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
class AppDelegate: UIResponder, UIApplicationDelegate, JPUSHRegisterDelegate {
    
    var window: UIWindow?
    var hostReach: Reachability?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupRootViewController() // 配置控制器
        setupGlobalStyle()        // 配置全局样式
        setupGlobalData()         // 配置全局数据
        setupKeyBoardManager()    // 配置键盘管理
        setupShareSDK()           // 配置shareSDK
        setupJPush(launchOptions) // 配置JPUSH
        setupReachability()       // 配置网络检测
        
        return true
    }
    
    /**
     配置网络检测
     */
    fileprivate func setupReachability() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: NSNotification.Name.reachabilityChanged, object: nil)
        hostReach = Reachability.forInternetConnection()
        hostReach?.startNotifier()
    }
    
    /**
     监听网络状态改变
     */
    @objc func reachabilityChanged(_ notification: Notification) {
        
        guard let curReach = notification.object as? Reachability else {
            return
        }
        
        var networkState = 0
        
        switch curReach.currentReachabilityStatus() {
        case NetworkStatus.init(0):
            print("无网络")
            networkState = 0
        case NetworkStatus.init(1):
            networkState = 1
            print("WiFi")
        case NetworkStatus.init(2):
            networkState = 2
            print("WAN")
        default:
            networkState = 3
        }
        
        // 发出网络改变通知
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "networkStatusChanged"), object: nil, userInfo: ["networkState" : networkState])
        
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
    fileprivate func setupShareSDK() {
        
        ShareSDK.registerApp(SHARESDK_APP_KEY, activePlatforms:[
            SSDKPlatformType.typeSinaWeibo.rawValue,
            SSDKPlatformType.typeQQ.rawValue,
            SSDKPlatformType.typeWechat.rawValue],
                             onImport: { (platform : SSDKPlatformType) in
                                switch platform {
                                case SSDKPlatformType.typeWechat:
                                    ShareSDKConnector.connectWeChat(WXApi.classForCoder())
                                case SSDKPlatformType.typeQQ:
                                    ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
                                case SSDKPlatformType.typeSinaWeibo:
                                    ShareSDKConnector.connectWeibo(WeiboSDK.classForCoder())
                                default:
                                    break
                                }
                                
        }) { (platform : SSDKPlatformType, appInfo : NSMutableDictionary?) in
            
            switch platform {
            case SSDKPlatformType.typeWechat:
                // 微信
                appInfo?.ssdkSetupWeChat(byAppId: WX_APP_ID, appSecret: WX_APP_SECRET)
                
            case SSDKPlatformType.typeQQ:
                // QQ
                appInfo?.ssdkSetupQQ(byAppId: QQ_APP_ID,
                                     appKey : QQ_APP_KEY,
                                     authType : SSDKAuthTypeBoth)
            case SSDKPlatformType.typeSinaWeibo:
                appInfo?.ssdkSetupSinaWeibo(byAppKey: WB_APP_KEY,
                                            appSecret: WB_APP_SECRET,
                                            redirectUri: WB_REDIRECT_URL,
                                            authType: SSDKAuthTypeBoth)
            default:
                break
            }
            
        }
        
        
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
        // 是否是新版本，新版本就进新特性里
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
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        
        // 获取到之前的版本号
        let sandboxVersionKey = "sandboxVersionKey"
        let sandboxVersion = UserDefaults.standard.string(forKey: sandboxVersionKey)
        
        // 保存当前版本号
        UserDefaults.standard.set(currentVersion, forKey: sandboxVersionKey)
        UserDefaults.standard.synchronize()
        
        // 当前版本和沙盒版本不一致就是新版本
        return currentVersion != sandboxVersion
    }
    
    /**
     配置极光推送
     */
    fileprivate func setupJPush(_ launchOptions: [AnyHashable: Any]?) {
        
        if #available(iOS 10.0, *){
            let entiity = JPUSHRegisterEntity()
            entiity.types = Int(UNAuthorizationOptions.alert.rawValue |
                UNAuthorizationOptions.badge.rawValue |
                UNAuthorizationOptions.sound.rawValue)
            JPUSHService.register(forRemoteNotificationConfig: entiity, delegate: self)
        } else if #available(iOS 8.0, *) {
            let types = UIUserNotificationType.badge.rawValue |
                UIUserNotificationType.sound.rawValue |
                UIUserNotificationType.alert.rawValue
            JPUSHService.register(forRemoteNotificationTypes: types, categories: nil)
        } else {
            let type = UIRemoteNotificationType.badge.rawValue |
                UIRemoteNotificationType.sound.rawValue |
                UIRemoteNotificationType.alert.rawValue
            JPUSHService.register(forRemoteNotificationTypes: type, categories: nil)
        }
        JPUSHService.setup(withOption: launchOptions, appKey: JPUSH_APP_KEY, channel: JPUSH_CHANNEL, apsForProduction: JPUSH_IS_PRODUCTION)
        JPUSHService.crashLogON()
        
        // 延迟发送通知（app被杀死进程后收到通知，然后通过点击通知打开app在这个方法中发送通知）
        perform(#selector(sendNotification(_:)), with: launchOptions, afterDelay: 1.5)
    }
    
    /**
     如果app是未启动状态，点击了通知。在launchOptions会携带通知数据
     */
    @objc fileprivate func sendNotification(_ launchOptions: [AnyHashable: Any]?) {
        if let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "didReceiveRemoteNotificationOfJPush"), object: nil, userInfo: userInfo)
        }
    }
    
    /**
     注册 DeviceToken
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
     将要显示
    */
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        let userInfo = notification.request.content.userInfo
        if let trigger = notification.request.trigger {
            if trigger.isKind(of: UNPushNotificationTrigger.classForCoder()) {
                JPUSHService.handleRemoteNotification(userInfo)
            }
        }
        completionHandler(Int(UNAuthorizationOptions.alert.rawValue))
    }
    
    /**
     已经收到消息
    */
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        let userInfo = response.notification.request.content.userInfo
        if let trigger = response.notification.request.trigger {
            if trigger.isKind(of: UNPushNotificationTrigger.classForCoder()) {
                JPUSHService.handleRemoteNotification(userInfo)
                // 处理远程通知
                remoteNotificationHandler(userInfo: userInfo)
            }
        }
        completionHandler()
    }
    
    /**
     iOS7后接收到远程通知
     */
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
        
        // 处理远程通知
        remoteNotificationHandler(userInfo: userInfo)
    }
    
    /// 处理远程通知
    ///
    /// - Parameter userInfo: 通知数据
    private func remoteNotificationHandler(userInfo: [AnyHashable : Any]) {
        
        if UIApplication.shared.applicationState == .background || UIApplication.shared.applicationState == .inactive {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "didReceiveRemoteNotificationOfJPush"), object: nil, userInfo: userInfo)
        } else if UIApplication.shared.applicationState == .active {
            let message = (userInfo as [AnyHashable : AnyObject])["aps"]!["alert"] as! String
            let alertC = UIAlertController(title: "收到新的消息", message: message, preferredStyle: UIAlertControllerStyle.alert)
            let confrimAction = UIAlertAction(title: "查看", style: UIAlertActionStyle.destructive, handler: { (action) in
                NotificationCenter.default.post(name: Notification.Name(rawValue: "didReceiveRemoteNotificationOfJPush"), object: nil, userInfo: userInfo)
            })
            let cancelAction = UIAlertAction(title: "忽略", style: UIAlertActionStyle.default, handler: nil)
            alertC.addAction(confrimAction)
            alertC.addAction(cancelAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertC, animated: true, completion: nil)
        }
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

