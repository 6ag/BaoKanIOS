//
//  JFArticleListModel.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/14.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFArticleListModel: NSObject {
    
    /// 作者昵称
    var username: String?
    
    /// 点击量
    var onclick: String?
    
    /// 发布时间
    var newstime: String?
    
    /// 创建文章时间戳
    var created_at: String?
    
    /// 文章id
    var id: String?
    
    /// 文章标题
    var title: String?
    
    /// 文章url
    var titleurl: String?
    
    /// 标题图片url
    var titlepic: String?
    
    /// 文章简介
    var smalltext: String?
    
    /// 数据表名
    var table: String?
    
    /// 父栏目id
    var bclassid: String?
    
    /// 当前栏目id
    var classid: String?
    
    /// 当前栏目名称
    var classname: String?
    
    /// 存储形变改变的偏移量
    var offsetY: CGFloat = 0
    
    /**
     字典转模型构造方法
     */
    init(dict: [String : String]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
}