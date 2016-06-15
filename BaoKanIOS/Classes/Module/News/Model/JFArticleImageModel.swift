//
//  JFArticleImageModel.swift
//  LiuAGeIOS
//
//  Created by zhoujianfeng on 16/6/7.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFArticleImageModel: NSObject {
    
    /// 图片描述
    var caption: String?
    
    /// 图片尺寸 [width : height]
    var pixel: [String : AnyObject]?
    
    /// 图片占位符
    var ref: String?
    
    /// 图片url
    var url: String?
    
    init(dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
}
