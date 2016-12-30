//
//  JFPhotoBottomBar.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/19.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import pop

protocol JFPhotoBottomBarDelegate {
    func didTappedBackButton(_ button: UIButton)
    func didTappedEditButton(_ button: UIButton)
    func didTappedCommentButton(_ button: UIButton)
    func didTappedCollectButton(_ button: UIButton)
    func didTappedShareButton(_ button: UIButton)
}

class JFPhotoBottomBar : UIView {
    
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var collectionButton: UIButton!
    
    var delegate: JFPhotoBottomBarDelegate?
    
    @IBAction func didTappedBackButton(_ button: UIButton) {
        delegate?.didTappedBackButton(button)
    }
    
    @IBAction func didTappedEditButton(_ button: UIButton) {
        delegate?.didTappedEditButton(button)
    }
    
    @IBAction func didTappedCommentButton(_ button: UIButton) {
        delegate?.didTappedCommentButton(button)
    }
    
    @IBAction func didTappedCollectButton(_ button: UIButton) {
        delegate?.didTappedCollectButton(button)
    }
    
    @IBAction func didTappedShareButton(_ button: UIButton) {
        delegate?.didTappedShareButton(button)
    }
    
}
