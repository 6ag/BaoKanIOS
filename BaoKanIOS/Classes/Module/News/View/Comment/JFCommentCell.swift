//
//  JFCommentCell.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/18.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

protocol JFCommentCellDelegate {
    func didTappedStarButton(_ button: UIButton, commentModel: JFCommentModel)
}

class JFCommentCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    var delegate: JFCommentCellDelegate?
    
    var commentModel: JFCommentModel? {
        didSet {
            guard let commentModel = commentModel else { return }
            avatarImageView.setAvatarImage(urlString: commentModel.userpic, placeholderImage: UIImage(named: "default－portrait"))
            usernameLabel.text = commentModel.plnickname
            timeLabel.text = commentModel.saytime
            contentLabel.text = commentModel.saytext
            starButton.setTitle("\(commentModel.zcnum)", for: UIControlState())
        }
    }
    
    func getCellHeight(_ commentModel: JFCommentModel) -> CGFloat {
        self.commentModel = commentModel
        layoutIfNeeded()
        return contentLabel.frame.maxY + 10
    }
    
    /**
     点击了赞
     */
    @IBAction func didTappedStarButton(_ sender: UIButton) {
        delegate?.didTappedStarButton(sender, commentModel: commentModel!)
    }
    
}
