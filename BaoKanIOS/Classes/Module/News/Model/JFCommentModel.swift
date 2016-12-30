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
    
    /// 评论昵称
    var plnickname: String?
    
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
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    
    /**
     加载（评论列表）数据
     
     - parameter classid:   资讯分类id
     - parameter id:        资讯id
     - parameter pageIndex: 当前页
     - parameter pageSize:  每页条数
     - parameter finished:  数据回调
     */
    class func loadCommentList(_ classid: Int, id: Int, pageIndex: Int, pageSize: Int, finished: @escaping (_ commentModels: [JFCommentModel]?, _ error: NSError?) -> ()) {
        
        JFNewsDALManager.shareManager.loadCommentList(classid, id: id, pageIndex: pageIndex, pageSize: pageSize) { (result, error) in
            
            // 请求失败
            if error != nil || result == nil {
                finished(nil, error)
                return
            }
            
            // 没有数据了
            if result?.count == 0 {
                finished([JFCommentModel](), nil)
                return
            }
            
            let data = result!.arrayValue
            var commentModels = [JFCommentModel]()
            
            // 遍历转模型添加数据
            for article in data {
                let postModel = JFCommentModel(dict: article.dictionaryObject! as [String : AnyObject])
                commentModels.append(postModel)
            }
            
            finished(commentModels, nil)
        }
    }
}
