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
            if let titlepic = model?.titlepic {
                iconImageView.isHidden = false
                model!.titlepic = model!.titlepic!.hasPrefix("http") ? model!.titlepic! : "http://www.baokan.name\(model!.titlepic!)"
                iconImageView.yy_setImage(with: URL(string: model!.titlepic!), placeholder: UIImage(named: "list_placeholder"))
            } else {
                iconImageView.isHidden = true
            }
            
            articleTitleLabel.text = model!.title!
            befromLabel.text = model!.classname!
            showNumLabel.text = model!.onclick!
        }
    }
}
