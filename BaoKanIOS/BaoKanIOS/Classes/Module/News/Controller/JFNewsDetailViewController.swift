//
//  JFNewsDetailViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/2/19.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFNewsDetailViewController: UIViewController {
    
    /// 文章详情请求参数
    var articleParam: (classid: String, id: String)? {
        didSet {
            loadNewsDetail(articleParam!.classid, id: articleParam!.id)
        }
    }
    
    /// 详情页面模型
    var model: JFArticleDetailModel? {
        didSet {
            // 更新页面数据
            
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
    }
    
    /**
     加载
     
     - parameter classid: 当前子分类id
     - parameter id:      文章id
     */
    func loadNewsDetail(classid: String, id: String)
    {
        let parameters = [
            "table" : "news",
            "classid" : classid,
            "id" : id,
        ]
        
        JFNetworkTool.shareNetworkTool.get(ARTICLE_DETAIL, parameters: parameters) { (success, result, error) -> () in
            if success == true {
                if let successResult = result {
                    print(successResult)
                    
                    let content = successResult["data"]["content"].dictionaryValue
                    
                    let dict = [
                        "title" : content["title"]!.string!,          // 文章标题
                        "username" : content["username"]!.string!,    // 用户名
                        "lastdotime" : content["lastdotime"]!.string!,// 最后编辑时间戳
                        "newstext" : content["newstext"]!.string!,    // 文章内容
                        "titleurl" : "\(BASE_URL)\(content["titleurl"]!.string!)", // 文章url
                        "id" : content["id"]!.string!,                // 文章id
                        "classid" : content["classid"]!.string!,      // 当前子分类id
                    ]
                    
                    self.model = JFArticleDetailModel(dict: dict)
                }
            } else {
                print("error:\(error)")
            }
        }
    }
    
}
