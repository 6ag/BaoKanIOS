//
//  JFPlaceholderView.swift
//  LiuAGeIOS
//
//  Created by zhoujianfeng on 16/6/25.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFPlaceholderView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     没有任何数据时提示
     
     - parameter text: 提示文字
     */
    func noAnyData(text: String) {
        imageView.stopAnimating()
        imageView.animationImages = nil
        
        imageView.image = UIImage(named: "nodata")
        titleLabel.text = text
    }
    
    /**
     开始动画
     */
    func startAnimation() {
        
        var imageArray = [UIImage]()
        for index in 0..<25 {
            let imageName = String(format: "loading%02d.jpg", arguments: [index])
            let image = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("loading/\(imageName)", ofType: nil)!)!
            imageArray.append(image)
        }
        
        imageView.animationImages = imageArray
        imageView.animationDuration = 2
        imageView.animationRepeatCount = Int.max
        imageView.startAnimating()
    }
    
    /**
     移除动画
     */
    func removeAnimation() {
        imageView.stopAnimating()
        imageView.animationImages = nil
        removeFromSuperview()
    }
    
    /// 图片区域
    lazy var imageView: UIImageView = {
        let image = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("loading/loading00.jpg", ofType: nil)!)!
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(origin: CGPointZero, size: CGSize(width: image.size.width * 0.5, height: image.size.height * 0.5))
        imageView.center = CGPoint(x: SCREEN_WIDTH * 0.5, y: (SCREEN_HEIGHT - 104) * 0.49)
        return imageView
    }()
    
    /// 提示文字
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .Center
        titleLabel.frame = CGRect(x: 0, y: CGRectGetMaxY(self.imageView.frame) + 10, width: SCREEN_WIDTH, height: 30)
        titleLabel.textColor = UIColor(white: 0.3, alpha: 1)
        titleLabel.text = "正在拼命加载中"
        return titleLabel
    }()
}
