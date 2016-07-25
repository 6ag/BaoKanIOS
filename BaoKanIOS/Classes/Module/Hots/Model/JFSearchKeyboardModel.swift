//
//  JFSearchKeyboardModel.swift
//  LiuAGeIOS
//
//  Created by zhoujianfeng on 16/6/27.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFSearchKeyboardModel: NSObject {

    /// 关键词
    var keyboard: String?
    
    /// 拼音
    var pinyin: String?
    
    /// 结果数量
    var num: Int = 1
    
    init(dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    /**
     加载搜索关键词数据
     
     - parameter keyboard: 关键词
     - parameter finished: 数据回调
     */
    class func loadSearchKeyList(keyboard: String, finished: (searchKeyboardModels: [JFSearchKeyboardModel]?, error: NSError?) -> ()) {
        
        JFNewsDALManager.shareManager.loadSearchKeyListFromLocation(keyboard) { (success, result, error) in
            
            guard let successResult = result where error == nil && success == true else {
                finished(searchKeyboardModels: nil, error: error)
                return
            }
            
            var searchKeyboardModels = [JFSearchKeyboardModel]()
            
            for dict in successResult {
                let model = JFSearchKeyboardModel(dict: dict)
                searchKeyboardModels.append(model)
            }
            
            finished(searchKeyboardModels: searchKeyboardModels, error: error)
        }
    }
}
