//
//  JFProfileCellGroupModel.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/5.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFProfileCellGroupModel: NSObject {
    
    var cells: [JFProfileCellModel]?
    
    var headerTitle: String?
    
    var footerTitle: String?
    
    init(cells: [JFProfileCellModel]) {
        self.cells = cells
        super.init()
    }
    
}
