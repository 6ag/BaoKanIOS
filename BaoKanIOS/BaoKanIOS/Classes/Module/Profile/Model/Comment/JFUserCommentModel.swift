//
//  JFUserCommentModel.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/26.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFUserCommentModel: NSObject {
    
    var title: String?
    
    var saytext: String?
    
    var saytime: String?
    
    var id: String?
    
    var classid: String?
    
    var tbname: String?
    
    var plid: String?
    
    var plstep: String?
    
    var plusername: String?
    
    var zcnum: String?
    
    var userpic: String?
    
    init(dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
}
