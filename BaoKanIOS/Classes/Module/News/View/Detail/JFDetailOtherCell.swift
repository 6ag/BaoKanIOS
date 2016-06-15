//
//  JFDetailOtherCell.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/2/24.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

class JFDetailOtherCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var befromLabel: UILabel!
    @IBOutlet weak var showNumLabel: UILabel!
    
    var model: JFOtherLinkModel? {
        didSet {
            iconImageView.yy_setImageWithURL(NSURL(string: model!.titlepic!), placeholder: UIImage(named: "list_placeholder"))
            articleTitleLabel.text = model!.title!
            befromLabel.text = model!.classname!
            showNumLabel.text = model!.onclick!
        }
    }
}
