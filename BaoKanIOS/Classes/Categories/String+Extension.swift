//
//  String+Extension.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/2/22.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import Foundation

extension String
{
    
    /**
     时间戳转为时间
     
     - returns: 时间字符串
     */
    func timeStampToString() -> String
    {
        let string = NSString(string: self)
        let timeSta: TimeInterval = string.doubleValue
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = "yyyy年MM月dd日"
        let date = Date(timeIntervalSince1970: timeSta)
        return dfmatter.string(from: date)
    }
    
    /**
     时间转为时间戳
     
     - returns: 时间戳字符串
     */
    func stringToTimeStamp()->String
    {
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = "yyyy年MM月dd日"
        let date = dfmatter.date(from: self)
        let dateStamp: TimeInterval = date!.timeIntervalSince1970
        let dateSt:Int = Int(dateStamp)
        return String(dateSt)
    }
}
