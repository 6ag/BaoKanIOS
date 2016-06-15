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
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    /**
     每次打开app就检查一次用户是否有效
     */
    class func checkUserInfo(finished: () -> ()) {
        if isLogin() {
            // 已经登录并保存过信息，验证信息是否有效
            let parameters: [String : AnyObject] = [
                "username" : JFAccountModel.shareAccount()!.username!,
                "userid" : JFAccountModel.shareAccount()!.id,
                "token" : JFAccountModel.shareAccount()!.token!
            ]
            
            JFNetworkTool.shareNetworkTool.post(GET_USERINFO, parameters: parameters, finished: { (success, result, error) in
                
                guard let successResult = result where success == true else {
                    JFAccountModel.logout()
                    print("登录信息无效")
                    return
                }
                
                print("登录信息有效")
                print(successResult)
                let account = JFAccountModel(dict: successResult["data"].dictionaryObject!)
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
        ShareSDK.cancelAuthorize(SSDKPlatformType.TypeQQ)
        ShareSDK.cancelAuthorize(SSDKPlatformType.TypeSinaWeibo)
        
        // 清除内存中的账号对象和归档
        JFAccountModel.userAccount = nil
        do {
            try NSFileManager.defaultManager().removeItemAtPath(JFAccountModel.accountPath)
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
    private static var userAccount: JFAccountModel?
    
    /// 归档账号的路径
    static let accountPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last! + "/Account.plist"
    
    /**
     获取用户对象 （这可不是单例哦，只是对象静态化了，保证在内存中不释放）
     */
    static func shareAccount() -> JFAccountModel? {
        if userAccount == nil {
            userAccount = NSKeyedUnarchiver.unarchiveObjectWithFile(accountPath) as? JFAccountModel
            return userAccount
        } else {
            return userAccount
        }
    }
    
    // MARK: - 归档和解档
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(token, forKey: "token")
        aCoder.encodeInt(Int32(id), forKey: "id")
        aCoder.encodeObject(username, forKey: "username")
        aCoder.encodeObject(registerTime, forKey: "registerTime")
        aCoder.encodeObject(email, forKey: "email")
        aCoder.encodeObject(avatarUrl, forKey: "avatarUrl")
        aCoder.encodeObject(groupName, forKey: "groupName")
        aCoder.encodeObject(points, forKey: "points")
        aCoder.encodeObject(saytext, forKey: "saytext")
        aCoder.encodeObject(phone, forKey: "phone")
        aCoder.encodeObject(qq, forKey: "qq")
        aCoder.encodeObject(nickname, forKey: "nickname")
    }
    
    required init?(coder aDecoder: NSCoder) {
        token = aDecoder.decodeObjectForKey("token") as? String
        id = Int(aDecoder.decodeIntForKey("id"))
        username = aDecoder.decodeObjectForKey("username") as? String
        registerTime = aDecoder.decodeObjectForKey("registerTime") as? String
        email = aDecoder.decodeObjectForKey("email") as? String
        avatarUrl = aDecoder.decodeObjectForKey("avatarUrl") as? String
        groupName = aDecoder.decodeObjectForKey("groupName") as? String
        points = aDecoder.decodeObjectForKey("points") as? String
        saytext = aDecoder.decodeObjectForKey("saytext") as? String
        phone = aDecoder.decodeObjectForKey("phone") as? String
        qq = aDecoder.decodeObjectForKey("qq") as? String
        nickname = aDecoder.decodeObjectForKey("nickname") as? String
    }
}