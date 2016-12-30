//
//  JFShareItemModel.swift
//  WindSpeedVPN
//
//  Created by zhoujianfeng on 2016/11/30.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

enum JFShareType: Int {
    case qqFriend = 0     // qq好友
    case qqQzone = 1         // qq空间
    case weixinFriend = 2     // 微信好友
    case friendCircle = 3    // 朋友圈
}

class JFShareItemModel: NSObject {

    /// 名称
    var title: String?
    
    /// 图标
    var icon: String?
    
    /// 类型
    var type: JFShareType = .qqFriend
    
    init(dict: [String : Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    
    /// 加载分享item
    class func loadShareItems() -> [JFShareItemModel] {
        
        var shareItems = [JFShareItemModel]()
        
        // QQ
        if QQApiInterface.isQQInstalled() && QQApiInterface.isQQSupportApi() {
            let shareItemQQFriend = JFShareItemModel(dict: [
                "title" : "QQ",
                "icon"  : "share_qq"
                ])
            shareItemQQFriend.type = JFShareType.qqFriend
            shareItems.append(shareItemQQFriend)
            
            let shareItemQQQzone = JFShareItemModel(dict: [
                "title" : "QQ空间",
                "icon"  : "share_qqkj"
                ])
            shareItemQQFriend.type = JFShareType.qqQzone
            shareItems.append(shareItemQQQzone)
        }
        
        // 微信
        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupport() {
            let shareItemWeixinFriend = JFShareItemModel(dict: [
                "title" : "微信好友",
                "icon"  : "share_wechat"
                ])
            shareItemWeixinFriend.type = JFShareType.weixinFriend
            shareItems.append(shareItemWeixinFriend)
            
            let shareItemFriendCircle = JFShareItemModel(dict: [
                "title" : "朋友圈",
                "icon"  : "share_friend"
                ])
            shareItemFriendCircle.type = JFShareType.friendCircle
            shareItems.append(shareItemFriendCircle)
        }
        
        return shareItems
    }
    
}
