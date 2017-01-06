//
//  JFAccountModel.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/17.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFAccountModel: NSObject, NSCoding {
    
    /// 令牌
    var token: String?
    
    /// 用户id
    var id: Int = 0
    
    /// 用户名
    var username: String?
    
    /// 昵称
    var nickname: String?
    
    /// 注册时间
    var registerTime: String?
    
    /// 邮箱
    var email: String?
    
    /// 头像路径
    var avatarUrl: String?
    
    /// 用户组
    var groupName: String?
    
    /// 积分
    var points: String?
    
    /// 个性签名
    var saytext: String?
    
    /// 电话号码
    var phone: String?
    
    /// qq号码
    var qq: String?
    
    // KVC 字典转模型
    init(dict: [String: AnyObject]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    
    /**
     每次打开app就检查一次用户是否有效
     */
    class func checkUserInfo(_ finished: @escaping () -> ()) {
        if isLogin() {
            // 已经登录并保存过信息，验证信息是否有效
            let parameters: [String : AnyObject] = [
                "username" : JFAccountModel.shareAccount()!.username! as AnyObject,
                "userid" : JFAccountModel.shareAccount()!.id as AnyObject,
                "token" : JFAccountModel.shareAccount()!.token! as AnyObject
            ]
            
            JFNetworkTool.shareNetworkTool.post(GET_USERINFO, parameters: parameters, finished: { (status, result, tipString) in
                
                // 更新失败则注销登录
                if status != .success {
                    JFAccountModel.logout()
                    return
                }
                
                guard let successResult = result else {
                    JFAccountModel.logout()
                    print("登录信息无效")
                    return
                }
                
                print("登录信息有效")
                print(successResult)
                let account = JFAccountModel(dict: successResult["data"].dictionaryObject! as [String : AnyObject])
                // 更新用户信息
                account.updateUserInfo()
                
                // 回调
                finished()
            })
        }
    }
    
    /**
     是否已经登录
     */
    class func isLogin() -> Bool {
        return JFAccountModel.shareAccount() != nil
    }
    
    /**
     注销清理
     */
    class func logout() {
        ShareSDK.cancelAuthorize(SSDKPlatformType.typeQQ)
        ShareSDK.cancelAuthorize(SSDKPlatformType.typeSinaWeibo)
        
        // 清除内存中的账号对象和归档
        JFAccountModel.userAccount = nil
        do {
            try FileManager.default.removeItem(atPath: JFAccountModel.accountPath)
        } catch {
            print("退出异常")
        }
    }
    
    /**
     登录保存
     */
    func updateUserInfo() {
        // 保存到内存中
        JFAccountModel.userAccount = self
        // 归档用户信息
        saveAccount()
    }
    
    // MARK: - 保存对象
    func saveAccount() {
        NSKeyedArchiver.archiveRootObject(self, toFile: JFAccountModel.accountPath)
    }
    
    // 持久保存到内存中
    fileprivate static var userAccount: JFAccountModel?
    
    /// 归档账号的路径
    static let accountPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! + "/Account.plist"
    
    /**
     获取用户对象 （这可不是单例哦，只是对象静态化了，保证在内存中不释放）
     */
    static func shareAccount() -> JFAccountModel? {
        if userAccount == nil {
            userAccount = NSKeyedUnarchiver.unarchiveObject(withFile: accountPath) as? JFAccountModel
            return userAccount
        } else {
            return userAccount
        }
    }
    
    // MARK: - 归档和解档
    func encode(with aCoder: NSCoder) {
        aCoder.encode(token, forKey: "token")
        aCoder.encodeCInt(Int32(id), forKey: "id")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(registerTime, forKey: "registerTime")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(avatarUrl, forKey: "avatarUrl")
        aCoder.encode(groupName, forKey: "groupName")
        aCoder.encode(points, forKey: "points")
        aCoder.encode(saytext, forKey: "saytext")
        aCoder.encode(phone, forKey: "phone")
        aCoder.encode(qq, forKey: "qq")
        aCoder.encode(nickname, forKey: "nickname")
    }
    
    required init?(coder aDecoder: NSCoder) {
        token = aDecoder.decodeObject(forKey: "token") as? String
        id = Int(aDecoder.decodeCInt(forKey: "id"))
        username = aDecoder.decodeObject(forKey: "username") as? String
        registerTime = aDecoder.decodeObject(forKey: "registerTime") as? String
        email = aDecoder.decodeObject(forKey: "email") as? String
        avatarUrl = aDecoder.decodeObject(forKey: "avatarUrl") as? String
        groupName = aDecoder.decodeObject(forKey: "groupName") as? String
        points = aDecoder.decodeObject(forKey: "points") as? String
        saytext = aDecoder.decodeObject(forKey: "saytext") as? String
        phone = aDecoder.decodeObject(forKey: "phone") as? String
        qq = aDecoder.decodeObject(forKey: "qq") as? String
        nickname = aDecoder.decodeObject(forKey: "nickname") as? String
    }
}
