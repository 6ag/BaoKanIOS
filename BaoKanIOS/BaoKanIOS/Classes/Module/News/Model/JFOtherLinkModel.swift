//
//  JFOtherLinkModel.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/27.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFOtherLinkModel: NSObject {

    var titlepicurl: String?
    
    var id: String?
    
    var classid: String?
    
    var diggdown: String?
    
    var plnum: String?
    
    var titlepic: String?
    
    var smalltext: String?
    
    var newstime: String?
    
    var onclick: String?
    
    var diggtop: String?
    
    var title: String?
    
    var titleurl: String?
    
    var classname: String?
    
    var classurl: String?
    
    var username: String?
    
    var notimg: String?
    
    init(dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
}
