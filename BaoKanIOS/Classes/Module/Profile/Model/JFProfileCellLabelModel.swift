//
//  JFProfileCellLabelModel.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/5.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFProfileCellLabelModel: JFProfileCellModel {

    /// 显示文本
    var text: String?
    
    init(title: String, text: String) {
        super.init(title: title)
        self.text = text
    }
    
    init(title: String, icon: String, text: String) {
        super.init(title: title, icon: icon)
        self.text = text
    }
}
