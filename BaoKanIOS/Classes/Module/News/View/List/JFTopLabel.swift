//
//  JFTopLabel.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/1.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFTopLabel: UILabel {

    var scale : CGFloat? {
        didSet {
            // 通过scale的改变来改变各种参数
            textColor = UIColor(red:1 * scale! + 0.95,  green:1 * scale! +  0.95,  blue:1 * scale! +  0.95, alpha:1)
            let minScale : CGFloat = 0.9
            let trueScale = minScale + (1 - minScale) * scale!
            transform = CGAffineTransform(scaleX: trueScale, y: trueScale)
        }
    }
    
    // MARK: - 构造函数
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textAlignment = NSTextAlignment.center
        font = UIFont.systemFont(ofSize: 20.0)
    }
    
}
