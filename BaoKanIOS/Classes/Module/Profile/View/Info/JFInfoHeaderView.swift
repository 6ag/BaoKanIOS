//
//  JFInfoHeaderView.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/26.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage
import SnapKit

class JFInfoHeaderView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        backgroundColor = UIColor.white
        addSubview(avatarImageView)
        addSubview(usernameLabel)
        addSubview(levelLabel)
        addSubview(pointsLabel)
        
        avatarImageView.snp.makeConstraints { (make) in
            make.left.equalTo(MARGIN)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        usernameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView.snp.right).offset(20)
            make.top.equalTo(avatarImageView).offset(2)
        }
        
        levelLabel.snp.makeConstraints { (make) in
            make.left.equalTo(usernameLabel)
            make.bottom.equalTo(avatarImageView).offset(-2)
        }
        
        pointsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(avatarImageView)
            make.right.equalTo(-MARGIN)
        }
        
        avatarImageView.yy_setImage(with: URL(string: JFAccountModel.shareAccount()!.avatarUrl!), options: YYWebImageOptions.allowBackgroundTask)
        usernameLabel.text = JFAccountModel.shareAccount()!.username!
        levelLabel.text = "等级：\(JFAccountModel.shareAccount()!.groupName!)"
        pointsLabel.text = "\(JFAccountModel.shareAccount()!.points!)积分"
    }
    
    // MARK: - 懒加载
    fileprivate lazy var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.layer.masksToBounds = true
        return avatarImageView
    }()
    
    fileprivate lazy var usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        return usernameLabel
    }()
    
    fileprivate lazy var levelLabel: UILabel = {
        let levelLabel = UILabel()
        levelLabel.font = UIFont.systemFont(ofSize: 13)
        levelLabel.textColor = UIColor.gray
        return levelLabel
    }()
    
    fileprivate lazy var pointsLabel: UILabel = {
        let pointsLabel = UILabel()
        pointsLabel.font = UIFont.systemFont(ofSize: 13)
        pointsLabel.textColor = UIColor.gray
        return pointsLabel
    }()
    
}
