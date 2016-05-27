//
//  JFStarAndShareCell.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/26.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

protocol JFStarAndShareCellDelegate {
    func didTappedStarButton(button: UIButton)
    func didTappedWeixinButton(button: UIButton)
    func didTappedFriendCircleButton(button: UIButton)
}

class JFStarAndShareCell: UITableViewCell {

    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var weixinButton: UIButton!
    @IBOutlet weak var friendCircleButton: UIButton!
    var delegate: JFStarAndShareCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        prepareButton(starButton)
        prepareButton(weixinButton)
        prepareButton(friendCircleButton)
    }
    
    private func prepareButton(button: UIButton) {
        button.layer.cornerRadius = 17
        button.layer.borderColor = UIColor(white: 0.6, alpha: 0.4).CGColor
        button.layer.borderWidth = 0.3
    }
    
    @IBAction func didTappedStarButton(sender: UIButton) {
        delegate?.didTappedStarButton(sender)
    }
    
    @IBAction func didTappedWeixinButton(sender: UIButton) {
        delegate?.didTappedWeixinButton(sender)
    }
    
    @IBAction func didTappedFriendCircleButton(sender: UIButton) {
        delegate?.didTappedFriendCircleButton(sender)
    }
}
