//
//  JFCommentCell.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/18.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

class JFCommentCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    var commentModel: JFCommentModel? {
        didSet {
            avatarImageView.yy_setImageWithURL(NSURL(string: commentModel!.userpic!), options: YYWebImageOptions.IgnorePlaceHolder)
            usernameLabel.text = commentModel?.plusername!
            timeLabel.text = commentModel?.saytime!
            contentLabel.text = commentModel?.saytext!
        }
        
    }
    
    func getCellHeight(commentModel: JFCommentModel) -> CGFloat {
        self.commentModel = commentModel
        layoutIfNeeded()
        return CGRectGetMaxY(contentLabel.frame) + 10
    }
    
}
