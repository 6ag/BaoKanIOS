//
//  JFProfileCellSwitchModel.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/5.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFProfileCellSwitchModel: JFProfileCellModel {
    
    /// 开关状态
    var on: Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(NIGHT_KEY)
    }
    
}
