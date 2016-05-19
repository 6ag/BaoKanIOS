//
//  JFPhotoBottomBar.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/19.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

protocol JFPhotoBottomBarDelegate {
    func didTappedBackButton(button: UIButton)
    func didTappedEditButton(button: UIButton)
    func didTappedCommentButton(button: UIButton)
    func didTappedCollectButton(button: UIButton)
    func didTappedShareButton(button: UIButton)
}

class JFPhotoBottomBar : UIView {
    
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var collectionButton: UIButton!
    
    var delegate: JFPhotoBottomBarDelegate?
    
    @IBAction func didTappedBackButton(button: UIButton) {
        delegate?.didTappedBackButton(button)
    }
    
    @IBAction func didTappedEditButton(button: UIButton) {
        delegate?.didTappedEditButton(button)
    }
    
    @IBAction func didTappedCommentButton(button: UIButton) {
        delegate?.didTappedCommentButton(button)
    }
    
    @IBAction func didTappedCollectButton(button: UIButton) {
        delegate?.didTappedCollectButton(button)
    }
    
    @IBAction func didTappedShareButton(button: UIButton) {
        delegate?.didTappedShareButton(button)
    }
    
}