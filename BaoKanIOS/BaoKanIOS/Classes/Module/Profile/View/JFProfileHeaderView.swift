//
//  JFProfileHeaderView.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/20.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

protocol JFProfileHeaderViewDelegate {
    
    func didTappedAvatarButton()
    func didTappedCollectionButton()
    func didTappedCommentButton()
    func didTappedInfoButton()
}

class JFProfileHeaderView: UIView {

    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    var delegate: JFProfileHeaderViewDelegate?
    
    @IBAction func didTappedAvatarButton() {
        delegate?.didTappedAvatarButton()
    }
    
    @IBAction func didTappedCollectionButton() {
        delegate?.didTappedCollectionButton()
    }
    
    @IBAction func didTappedCommentButton() {
        delegate?.didTappedCommentButton()
    }
    
    @IBAction func didTappedInfoButton() {
        delegate?.didTappedInfoButton()
    }
    
}
