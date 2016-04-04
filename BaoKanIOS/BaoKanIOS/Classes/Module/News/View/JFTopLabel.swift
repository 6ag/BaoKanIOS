//
//  JFTopLabel.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/1.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFTopLabel: UILabel {

    var scale : Float? {
        didSet {
            // 通过scale的改变来改变各种参数
            textColor = UIColor(colorLiteralRed: scale! + 254, green: 255.0, blue: 255.0, alpha: 1.0)
            let minScale : Float = 0.9
            let trueScale = minScale + (1 - minScale) * Float(scale!)
            transform = CGAffineTransformMakeScale(CGFloat(trueScale), CGFloat(trueScale))
        }
    }
    
    // MARK: - 构造函数
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textAlignment = NSTextAlignment.Center
        font = UIFont.systemFontOfSize(20.0)
    }

    

}
