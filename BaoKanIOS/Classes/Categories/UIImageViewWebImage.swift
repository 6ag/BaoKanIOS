//
//  UIImageViewWebImage.swift
//  WeiboSwift
//
//  Created by zhoujianfeng on 2017/1/21.
//  Copyright © 2017年 周剑峰. All rights reserved.
//

import YYWebImage

extension UIImageView {
    
    /// 设置图像
    ///
    /// - Parameters:
    ///   - urlString: 图片url
    ///   - placeholderImage: 占位图像
    func setImage(urlString: String?, placeholderImage: UIImage?) {
        
        guard let urlString = urlString,
            let url = URL(string: urlString) else {
                image = placeholderImage
                return
        }
        
        yy_setImage(with: url, placeholder: placeholderImage, options: []) { [weak self] (image, _, _, _, _) in
            // 重绘图片 - 解决图片拉伸引起的性能问题
            self?.image = image?.redrawImage(size: self?.bounds.size)
        }
        
    }
    
    /// 设置圆形头像
    ///
    /// - Parameters:
    ///   - urlString: 图片url
    ///   - placeholderImage: 占位图
    func setAvatarImage(urlString: String?, placeholderImage: UIImage?) {
        
        guard let urlString = urlString,
            let url = URL(string: urlString) else {
                image = placeholderImage
                return
        }
        
        yy_setImage(with: url, placeholder: placeholderImage, options: []) { [weak self] (image, _, _, _, _) in
            // 重绘图片 - 解决图片拉伸引起的性能问题
            self?.image = image?.redrawOvalImage(size: self?.bounds.size, bgColor: self?.superview?.backgroundColor ?? UIColor.white)
        }
        
    }
}
