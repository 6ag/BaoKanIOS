//
//  JFPostModel.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/14.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import Foundation

class JFPostModel: NSObject {
    
    /// 作者昵称
    var nickname: String?
    
    /// 浏览量
    var views: String?
    
    /// 发布时间
    var date: String?
    
    /// 列表缩略图url
    var thumbnailUrl: String?
    
    /// 文章id
    var id: String?
    
    /// 文章标题
    var title: String?
    
    /// 评论数
    var comment_count: String?
    
    /// 文章内容
    var content: String?
    
    /**
     字典转模型构造方法
     */
    init(dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
}