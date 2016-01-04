//
//  JFNetworkTool.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit
import Alamofire

class JFNetworkTool: NSObject {
    
    /// 网络请求回调闭包 success:是否成功  flag:预留参数  result:字典数据 error:错误信息
    typealias NetworkFinished = (success: Bool, flag: Bool, result: [String: AnyObject]?, error: NSError?) -> ()
    
    /// 网络工具类单例
    static let shareNetworkTool = JFNetworkTool()

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
        
        Alamofire.request(.GET, URLString).response { request, response, data, error in
            print(response)
        }
    }
    
    /**
     POST请求
     
     - parameter URLString:  urlString
     - parameter parameters: 参数
     - parameter finished:   完成回调
     */
    func post(URLString: String, parameters: AnyObject?, finished: NetworkFinished) -> () {
        Alamofire.request(.GET, URLString).responseJSON { (response) -> Void in
            print(response)
        }
    }
}
