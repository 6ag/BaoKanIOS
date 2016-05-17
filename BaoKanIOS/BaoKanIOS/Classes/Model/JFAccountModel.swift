//
//  JFAccountModel.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/17.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFAccountModel: NSObject {
    
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
    
    /// 签到时间
    var checkingTime: String?
    
    /// 签到日期
    var checkingDate: String?
    
    /// 签到月份
    var checkingMoth: String?
    
    /// 签到天数
    var CheckingToday: String?
    
    /// 是否登录 只读计算型属性可以省略get和大括号
    var isLogin: Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(IS_LOGIN)
    }
    
    /**
     初始化账户模型
     */
    init(dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    /**
     防止kvc崩溃
     */
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    /**
     注销
     */
    func logout() -> Void {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: IS_LOGIN)
    }
    
    /**
     登录
     */
    func login() -> Void {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: IS_LOGIN)
    }
    
    /**
     单例
     */
    static func shareAccount() -> JFAccountModel {
        struct Singleton {
            static var onceToken : dispatch_once_t = 0
            static var single: JFAccountModel?
        }
        dispatch_once(&Singleton.onceToken, {
            Singleton.single = JFAccountModel()
            }
        )
        return Singleton.single!
    }
    
    private override init() {}
}
