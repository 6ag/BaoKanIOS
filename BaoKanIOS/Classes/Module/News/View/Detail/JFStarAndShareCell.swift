//
//  JFStarAndShareCell.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/26.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

protocol JFStarAndShareCellDelegate {
    func didTappedQQButton(_ button: UIButton)
    func didTappedWeixinButton(_ button: UIButton)
    func didTappedFriendCircleButton(_ button: UIButton)
}

class JFStarAndShareCell: UITableViewCell {

    @IBOutlet weak var qqButton: UIButton!
    @IBOutlet weak var weixinButton: UIButton!
    @IBOutlet weak var friendCircleButton: UIButton!
    @IBOutlet weak var befromLabel: UILabel!
    
    var delegate: JFStarAndShareCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        prepareButton(qqButton)
        prepareButton(weixinButton)
        prepareButton(friendCircleButton)
        
        #if TARGET_IPHONE_SIMULATOR // 模拟器
            
        #elseif TARGET_OS_IPHONE // 真机要根据情况隐藏
            // 微信
            if WXApi.isWXAppInstalled() && WXApi.isWXAppSupportApi() {
                weixinButton.hidden = false
                friendCircleButton.hidden = false
            } else {
                weixinButton.hidden = true
                friendCircleButton.hidden = true
            }
            
            // QQ
            if QQApiInterface.isQQInstalled() && QQApiInterface.isQQSupportApi() {
                qqButton.hidden = false
            } else {
                qqButton.hidden = true
            }
        #endif
    }
    
    fileprivate func prepareButton(_ button: UIButton) {
        button.layer.cornerRadius = 17
        button.layer.borderColor = UIColor(white: 0.6, alpha: 0.4).cgColor
        button.layer.borderWidth = 0.3
    }
    
    @IBAction func didTappedQQButton(_ sender: UIButton) {
        delegate?.didTappedQQButton(sender)
    }
    
    @IBAction func didTappedWeixinButton(_ sender: UIButton) {
        delegate?.didTappedWeixinButton(sender)
    }
    
    @IBAction func didTappedFriendCircleButton(_ sender: UIButton) {
        delegate?.didTappedFriendCircleButton(sender)
    }
}
