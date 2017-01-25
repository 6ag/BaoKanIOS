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

/// 请求响应状态
///
/// - success: 响应成功  - 就是成功
/// - unusual: 响应异常  - 例如 手机已被注册
/// - failure: 请求错误  - 例如 比如网络错误
enum JFResponseStatus: Int {
    case success  = 0
    case unusual  = 1
    case failure  = 3
}

/// 网络请求回调闭包 status:响应状态 result:JSON tipString:提示给用户的信息
typealias NetworkFinished = (_ status: JFResponseStatus, _ result: JSON?, _ tipString: String?) -> ()

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
    func get(_ APIString: String, parameters: [String : Any]?, finished: @escaping NetworkFinished) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        print("APIString = \(APIString)")
        Alamofire.request(APIString, method: .get, parameters: parameters, headers: nil).responseJSON { (response) in
            self.handle(response: response, finished: finished)
        }
        
    }
    
    /**
     POST请求
     
     - parameter URLString:  urlString
     - parameter parameters: 参数
     - parameter finished:   完成回调
     */
    func post(_ APIString: String, parameters: [String : Any]?, finished: @escaping NetworkFinished) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        print("APIString = \(APIString)")
        Alamofire.request(APIString, method: .post, parameters: parameters, headers: nil).responseJSON { (response) in
            self.handle(response: response, finished: finished)
        }
    }
    
    /// 处理响应结果
    ///
    /// - Parameters:
    ///   - response: 响应对象
    ///   - finished: 完成回调
    fileprivate func handle(response: DataResponse<Any>, finished: @escaping NetworkFinished) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        switch response.result {
        case .success(let value):
//            print(value)
            let json = JSON(value)
            if json["err_msg"].string == "success" {
                finished(.success, json, nil)
            } else {
                finished(.unusual, json, nil)
            }
        case .failure(let error):
            finished(.failure, nil, error.localizedDescription)
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
    func uploadUserAvatar(_ APIString: String, imagePath: URL, parameters: [String : Any]?, finished: @escaping NetworkFinished) {
//        print("APIString=\(APIString)")
        
        let headers = ["content-type" : "multipart/form-data"]
        // 字符串转data型
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            for (key, value) in parameters! {
                let data = (value as AnyObject).data!(using: String.Encoding.utf8.rawValue)!
                multipartFormData.append(data, withName: key)
            }
            
            // 文件流方式上传图片 - 后端根据tempName进行操作上传文件
            multipartFormData.append(imagePath, withName: "file")
        },
                         to: APIString,
                         headers: headers,
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { response in
                                    if let data = response.data {
                                        let json = JSON(data: data)
                                        finished(.success, json, nil)
                                    } else {
                                        JFProgressHUD.showInfoWithStatus("您的网络不给力哦")
                                        finished(.failure, nil, response.result.error?.localizedDescription)
                                    }
                                }
                            case .failure(let encodingError):
                                print(encodingError)
                                JFProgressHUD.showInfoWithStatus("您的网络不给力哦")
                                finished(.failure, nil, encodingError.localizedDescription)
                            }
        })
    }
    
    /**
     获取更新搜索关键词列表的开关
     
     - parameter finished: 数据回调
     */
    func shouldUpdateKeyboardList(_ finished: @escaping (_ update: Bool) -> ()) {
        
        JFNetworkTool.shareNetworkTool.get(UPDATE_SEARCH_KEY_LIST, parameters: nil) { (status, result, tipString) in
            
            switch status {
            case .success:
                let updateNum = result!["data"].intValue
                if UserDefaults.standard.integer(forKey: UPDATE_SEARCH_KEYBOARD) == updateNum {
                    finished(false)
                } else {
                    UserDefaults.standard.set(updateNum, forKey: UPDATE_SEARCH_KEYBOARD)
                    finished(true)
                }
            case .unusual:
                finished(false)
            case .failure:
                finished(false)
            }
            
        }
    }
    
    /**
     从网络加载（搜索结果）列表
     
     - parameter keyboard:  搜索关键词
     - parameter pageIndex: 加载分页
     - parameter finished:  数据回调
     */
    func loadSearchResultFromNetwork(_ keyboard: String, pageIndex: Int, finished: @escaping NetworkFinished) {
        
        let parameters: [String : Any] = [
            "keyboard" : keyboard,   // 搜索关键字
            "pageIndex" : pageIndex, // 页码
            "pageSize" : 20          // 单页数量
        ]
        
        JFNetworkTool.shareNetworkTool.get(SEARCH, parameters: parameters, finished: finished)
    }
    
    /**
     从网络加载（资讯列表）数据
     
     - parameter classid:   资讯分类id
     - parameter pageIndex: 加载分页
     - parameter type:      1为资讯列表 2为资讯幻灯片
     - parameter finished:  数据回调
     */
    func loadNewsListFromNetwork(_ table: String, classid: Int, pageIndex: Int, type: Int, finished: @escaping NetworkFinished) {
        
        var parameters = [String : Any]()
        
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
        
        JFNetworkTool.shareNetworkTool.get(ARTICLE_LIST, parameters: parameters, finished: finished)
    }
    
    /**
     从网络加载（资讯正文）数据
     
     - parameter classid:  资讯分类id
     - parameter id:       资讯id
     - parameter finished: 数据回调
     */
    func loadNewsDetailFromNetwork(_ classid: Int, id: Int, finished: @escaping NetworkFinished) {
        
        var parameters = [String : Any]()
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
        
        JFNetworkTool.shareNetworkTool.get(ARTICLE_DETAIL, parameters: parameters, finished: finished)
    }
    
    /**
     从网络加载（评论列表）数据
     
     - parameter classid:   资讯分类id
     - parameter id:        资讯id
     - parameter pageIndex: 当前页
     - parameter pageSize:  每页条数
     - parameter finished:  数据回调
     */
    func loadCommentListFromNetwork(_ classid: Int, id: Int, pageIndex: Int, pageSize: Int, finished: @escaping NetworkFinished) {
        
        let parameters: [String : Any] = [
            "classid" : classid,
            "id" : id,
            "pageIndex" : pageIndex,
            "pageSize" : pageSize
        ]
        
        JFNetworkTool.shareNetworkTool.get(GET_COMMENT, parameters: parameters, finished: finished)
    }
    
}

// MARK: - 网络工具方法
extension JFNetworkTool {
    
    /**
     获取当前网络状态
     
     - returns: 0未知 1WiFi 2WAN
     */
    func getCurrentNetworkState() -> Int {
        return Reachability.forInternetConnection().currentReachabilityStatus().rawValue
    }
}
