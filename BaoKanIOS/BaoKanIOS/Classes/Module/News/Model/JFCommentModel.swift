//
//  JFCommentModel.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/18.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFCommentModel: NSObject {
    
    /// 楼层
    var plstep: Int = 0
    
    /// 评论id
    var plid: Int = 0
    
    /// 评论用户名
    var plusername: String?
    
    /// 文章id
    var id: Int = 0
    
    /// 栏目id
    var classid: Int = 0
    
    /// 赞数量
    var zcnum: Int = 0
    
    /// 评论信息
    var saytext: String?
    
    /// 评论时间
    var saytime: String?
    
    /// 用户头像url 需要拼接
    var userpic: String?
    
    /// 是否赞过
    var isStar = false
    
    /// 缓存行高
    var rowHeight: CGFloat = 0
    
    init (dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
}