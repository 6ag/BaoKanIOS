//
//  Color+Extension.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/2/19.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

extension UIColor
{
    /**
     快速构建rgb颜色
     
     - parameter r: r
     - parameter g: g
     - parameter b: b
     
     - returns: 返回rgb颜色对象，alpha默认1
     */
    class func colorWithRGB(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1)
    }
    
    /**
     生成随机颜色
     
     - returns: 返回随机色
     */
    class func randomColor() -> UIColor {
        let r = CGFloat(arc4random_uniform(256))
        let g = CGFloat(arc4random_uniform(256))
        let b = CGFloat(arc4random_uniform(256))
        return UIColor.colorWithRGB(r, g: g, b: b)
    }
}