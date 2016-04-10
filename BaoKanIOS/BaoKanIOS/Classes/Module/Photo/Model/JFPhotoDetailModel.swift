//
//  JFPhotoDetailModel.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/4/8.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFPhotoDetailModel: NSObject {

    /// 图片标题
    var title: String?

    /// 图片描述
    var text: String?
    
    /// 图片url
    var picurl: String?

    /**
     字典转模型构造方法
     */
    init(dict: [String : String]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
}
