//
//  JFStarAndShareCell.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/26.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFStarAndShareCell: UITableViewCell {

    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var weixinButton: UIButton!
    @IBOutlet weak var friendCircleButton: UIButton!
    
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
        
    }
    
    @IBAction func didTappedWeixinButton(sender: UIButton) {
        
    }
    
    @IBAction func didTappedFriendCircleButton(sender: UIButton) {
        
    }
}
