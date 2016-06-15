//
//  JFNetworkTool.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

/// 网络请求回调闭包 success:是否成功  flag:预留参数  result:字典数据 error:错误信息
typealias NetworkFinished = (success: Bool, result: JSON?, error: NSError?) -> ()

class JFNetworkTool: NSObject {
    
    /// 网络工具类单例
    static let shareNetworkTool = JFNetworkTool()
}

// MARK: - 基础请求方法
extension JFNetworkTool {
    
    /**
     GET请求
     
     - parameter URLString:  urlString
     - parameter parameters: 参数
     - parameter finished:   完成回调
     */
    func get(APIString: String, parameters: [String : AnyObject]?, finished: NetworkFinished) {
        
        var urlString = ""
        if APIString.hasPrefix("http") {
            urlString = APIString
        } else {
            urlString = "\(API_URL)\(APIString)"
        }
        
        Alamofire.request(.GET, urlString, parameters: parameters).responseJSON { (response) -> Void in
            
            if let data = response.data {
                let json = JSON(data: data)
                if json["err_msg"].string == "success" {
                    finished(success: true, result: json, error: nil)
                } else {
                    finished(success: false, result: json, error: response.result.error)
                }
            } else {
                finished(success: false, result: nil, error: response.result.error)
            }
        }
        
    }
    
    /**
     POST请求
     
     - parameter URLString:  urlString
     - parameter parameters: 参数
     - parameter finished:   完成回调
     */
    func post(APIString: String, parameters: [String : AnyObject]?, finished: NetworkFinished) {
        
        var urlString = ""
        if APIString.hasPrefix("http") {
            urlString = APIString
        } else {
            urlString = "\(API_URL)\(APIString)"
        }
        
        Alamofire.request(.POST, urlString, parameters: parameters).responseJSON { (response) -> Void in
            
            if let data = response.data {
                let json = JSON(data: data)
                if json["err_msg"].string == "success" {
                    finished(success: true, result: json, error: nil)
                } else {
                    finished(success: false, result: json, error: response.result.error)
                }
            } else {
                finished(success: false, result: nil, error: response.result.error)
            }
        }
    }
}

// MARK: - 各种网络请求
extension JFNetworkTool {
    
    /**
     上传用户头像
     
     - parameter APIString:  api接口
     - parameter image:      图片对象
     - parameter parameters: 绑定参数
     - parameter finished:   完成回调
     */
    func uploadUserAvatar(APIString: String, imagePath: NSURL, parameters: [String : AnyObject]?, finished: NetworkFinished) {
        
        var urlString = ""
        if APIString.hasPrefix("http") {
            urlString = APIString
        } else {
            urlString = "\(API_URL)\(APIString)"
        }
        
        Alamofire.upload(.POST, urlString, multipartFormData: { multipartFormData in
            
            for (key, value) in parameters! {
                multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
            }
            // 文件流方式上传图片 - 后端根据tempName进行操作上传文件
            multipartFormData.appendBodyPart(fileURL: imagePath, name: "file")
            
            },encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        finished(success: true, result: nil, error: nil)
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                    finished(success: false, result: nil, error: nil)
                }
            }
        )
        
    }
    
    /**
     从网络加载（资讯列表）数据
     
     - parameter classid:   资讯分类id
     - parameter pageIndex: 加载分页
     - parameter type:      1为资讯列表 2为资讯幻灯片
     - parameter finished:  数据回调
     */
    func loadNewsListFromNetwork(table: String, classid: Int, pageIndex: Int, type: Int, finished: NetworkFinished) {
        
        var parameters = [String : AnyObject]()
        
        if type == 1 {
            parameters = [
                "table" : table,
                "classid" : classid,
                "pageIndex" : pageIndex, // 页码
                "pageSize" : 20          // 单页数量
            ]
        } else {
            parameters = [
                "table" : table,
                "classid" : classid,
                "query" : "isgood",
                "pageSize" : 3
            ]
        }
        
        JFNetworkTool.shareNetworkTool.get(ARTICLE_LIST, parameters: parameters) { (success, result, error) -> () in
            
            guard let successResult = result where success == true else {
                finished(success: false, result: nil, error: error)
                return
            }
            print(successResult)
            finished(success: true, result: successResult["data"], error: nil)
        }
    }
    
    /**
     从网络加载（资讯正文）数据
     
     - parameter classid:  资讯分类id
     - parameter id:       资讯id
     - parameter finished: 数据回调
     */
    func loadNewsDetailFromNetwork(classid: Int, id: Int, finished: NetworkFinished) {
        
        var parameters = [String : AnyObject]()
        if JFAccountModel.isLogin() {
            parameters = [
                "classid" : classid,
                "id" : id,
                "username" : JFAccountModel.shareAccount()!.username!,
                "userid" : JFAccountModel.shareAccount()!.id,
                "token" : JFAccountModel.shareAccount()!.token!,
            ]
        } else {
            parameters = [
                "classid" : classid,
                "id" : id,
            ]
        }
        
        JFNetworkTool.shareNetworkTool.get(ARTICLE_DETAIL, parameters: parameters) { (success, result, error) -> () in
            
            guard let successResult = result where success == true else {
                finished(success: false, result: nil, error: error)
                return
            }
            print(successResult)
            finished(success: true, result: successResult["data"], error: nil)
        }
    }
    
    /**
     从网络加载（评论列表）数据
     
     - parameter classid:   资讯分类id
     - parameter id:        资讯id
     - parameter pageIndex: 当前页
     - parameter pageSize:  每页条数
     - parameter finished:  数据回调
     */
    func loadCommentListFromNetwork(classid: Int, id: Int, pageIndex: Int, pageSize: Int, finished: NetworkFinished) {
        
        let parameters: [String : AnyObject] = [
            "classid" : classid,
            "id" : id,
            "pageIndex" : pageIndex,
            "pageSize" : pageSize
        ]
        
        JFNetworkTool.shareNetworkTool.get(GET_COMMENT, parameters: parameters) { (success, result, error) -> () in
            
            guard let successResult = result where success == true else {
                finished(success: false, result: nil, error: error)
                return
            }
            print(successResult)
            finished(success: true, result: successResult["data"], error: nil)
        }
    }
    
}
