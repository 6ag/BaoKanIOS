//
//  JFNetworkTool.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit
import AFNetworking

class JFNetworkTool: NSObject {
    
    /// 网络请求回调闭包 success:是否成功  flag:预留参数  result:字典数据 error:错误信息
    typealias NetworkFinished = (success: Bool, flag: Bool, result: [String: AnyObject]?, error: NSError?) -> ()
    
    /// 网络工具类单例
    static let shareNetworkTool = JFNetworkTool()
    private var manager: AFHTTPSessionManager
    
    override init() {
        let baseURL = "http://wp.baokan.name/"
        manager = AFHTTPSessionManager(baseURL: NSURL(string: baseURL))
        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
    }
    
}

// MARK: - 各种网络请求
extension JFNetworkTool {
    
    /**
     GET请求
     
     - parameter URLString:  urlString
     - parameter parameters: 参数
     - parameter finished:   完成回调
     */
    func get(URLString: String, parameters: AnyObject?, finished: NetworkFinished) -> () {
        
        manager.GET(URLString, parameters: parameters, progress: { (progress) -> Void in
            
            }, success: { (_, result) -> Void in
                finished(success: true, flag: false, result: result as? [String: AnyObject], error: nil)
            }) { (_, error) -> Void in
                finished(success: false, flag: false, result: nil, error: error)
        }
    }
    
    /**
     POST请求
     
     - parameter URLString:  urlString
     - parameter parameters: 参数
     - parameter finished:   完成回调
     */
    func post(URLString: String, parameters: AnyObject?, finished: NetworkFinished) -> () {
        
        manager.POST(URLString, parameters: parameters, progress: { (progress) -> Void in
            
            }, success: { (_, result) -> Void in
                finished(success: true, flag: false, result: result as? [String: AnyObject], error: nil)
            }) { (_, error) -> Void in
                finished(success: false, flag: false, result: nil, error: error)
        }
    }
}
