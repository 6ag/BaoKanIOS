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
    
    /// 注册时间
    var registerTime: String?
    
    /// 邮箱
    var email: String?
    
    /// 头像路径
    var avatarUrl: String?
    
    /// 用户组id
    var groupId: String?
    
    /// 用户组
    var groupName: String?
    
    /// 积分
    var points: String?
    
    /// 签到时间
    var checkingTime: String?
    
    /// 签到日期
    var checkingDate: String?
    
    /// 签到月份
    var checkingMoth: String?
    
    /// 签到天数
    var CheckingToday: String?
    
    // KVC 字典转模型
    init(dict: [String: AnyObject]) {
        super.init()
        // 将字典里面的每一个key的值赋值给对应的模型属性
        setValuesForKeysWithDictionary(dict)
    }
    
    /**
     是否已经登录
     */
    class func isLogin() -> Bool {
        return JFAccountModel.shareAccount() != nil
    }
    
    /**
     每次打开app就检查一次用户是否有效
     */
    class func checkUserInfo() {
        if isLogin() {
            // 已经登录并保存过信息，验证信息是否有效
            let parameters: [String : AnyObject] = [
                "username" : JFAccountModel.shareAccount()!.username!,
                "userid" : JFAccountModel.shareAccount()!.id,
                "token" : JFAccountModel.shareAccount()!.token!
            ]
            
            JFNetworkTool.shareNetworkTool.post(GET_USERINFO, parameters: parameters, finished: { (success, result, error) in
                if success {
                    print("登录信息有效")
                    if let successResult = result {
                        let account = JFAccountModel(dict: successResult["data"]["user"].dictionaryObject!)
                        // 更新用户信息
                        account.updateUserInfo()
                    }
                } else {
                    print("登录信息无效")
                    JFAccountModel.logout()
                }
            })
        }
    }
    
    /**
     防止kvc崩溃
     */
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    /**
     注销
     */
    class func logout() -> Void {
        // 清除内存中的账号对象和归档
        JFAccountModel.userAccount = nil
        do {
            try NSFileManager.defaultManager().removeItemAtPath(JFAccountModel.accountPath)
        } catch {
            print("退出异常")
        }
    }
    
    /**
     登录
     */
    func updateUserInfo() -> Void {
        // 保存到内存中
        JFAccountModel.userAccount = self
        // 归档用户信息
        saveAccount()
    }
    
    /// 归档账号的路径
    static let accountPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last! + "/Account.plist"
    
    // MARK: - 保存对象
    func saveAccount() {
        NSKeyedArchiver.archiveRootObject(self, toFile: JFAccountModel.accountPath)
    }
    
    // 保存到内存中
    private static var userAccount: JFAccountModel?
    
    static func shareAccount() -> JFAccountModel? {
        if userAccount == nil {
            userAccount = NSKeyedUnarchiver.unarchiveObjectWithFile(accountPath) as? JFAccountModel
        }
        if userAccount == nil {
            // 说明没有登录
            return nil
        } else {
            // 这里还需要验证账号是否有效
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
        aCoder.encodeObject(groupId, forKey: "groupId")
        aCoder.encodeObject(groupName, forKey: "groupName")
        aCoder.encodeObject(points, forKey: "points")
        aCoder.encodeObject(checkingTime, forKey: "checkingTime")
        aCoder.encodeObject(checkingDate, forKey: "checkingDate")
        aCoder.encodeObject(checkingMoth, forKey: "checkingMoth")
        aCoder.encodeObject(CheckingToday, forKey: "CheckingToday")
    }
    
    required init?(coder aDecoder: NSCoder) {
        token = aDecoder.decodeObjectForKey("token") as? String
        id = Int(aDecoder.decodeIntForKey("id"))
        username = aDecoder.decodeObjectForKey("username") as? String
        registerTime = aDecoder.decodeObjectForKey("registerTime") as? String
        email = aDecoder.decodeObjectForKey("email") as? String
        avatarUrl = aDecoder.decodeObjectForKey("avatarUrl") as? String
        groupId = aDecoder.decodeObjectForKey("groupId") as? String
        groupName = aDecoder.decodeObjectForKey("groupName") as? String
        points = aDecoder.decodeObjectForKey("points") as? String
        checkingTime = aDecoder.decodeObjectForKey("checkingTime") as? String
        checkingDate = aDecoder.decodeObjectForKey("checkingDate") as? String
        checkingMoth = aDecoder.decodeObjectForKey("checkingMoth") as? String
        CheckingToday = aDecoder.decodeObjectForKey("CheckingToday") as? String
    }
}
