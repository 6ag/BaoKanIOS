//
//  JFNewsOnePicCell.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/14.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

class JFNewsOnePicCell: UITableViewCell {
    
    var postModel: JFArticleListModel? {
        didSet {
            iconView.image = nil
            iconView.yy_setImageWithURL(NSURL(string: postModel!.titlepic!), placeholder: UIImage(named: "placeholder_logo"))
            articleTitleLabel.text = postModel?.title!
            timeLabel.text = postModel?.newstime!
            commentLabel.text = postModel?.plnum!
            showNumLabel.text = postModel?.onclick!
        }
    }
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var showNumLabel: UILabel!
    
}
