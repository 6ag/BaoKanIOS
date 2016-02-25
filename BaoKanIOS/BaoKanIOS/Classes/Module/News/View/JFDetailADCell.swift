//
//  JFDetailADCell.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/2/24.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFDetailADCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     准备UI
     */
    private func prepareUI()
    {
        contentView.addSubview(adImageView)
        contentView.addSubview(adTitleButton)
        
        adImageView.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(UIEdgeInsets(top: 10, left: 10, bottom: -40, right: -10))
        })
        adTitleButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(10)
            make.top.equalTo(adImageView.snp_bottom).offset(10)
            make.height.equalTo(20)
            make.right.equalTo(-10)
        }
    }
    
    /// 广告图片
    lazy var adImageView: UIImageView = {
        let adImageView = UIImageView()
        adImageView.image = UIImage(named: "detail_ad_banner")
        return adImageView
    }()
    
    /// 广告标题
    lazy var adTitleButton: UIButton = {
        let adTitleButton = UIButton(type: UIButtonType.Custom)
        adTitleButton.titleLabel?.font = UIFont.systemFontOfSize(16)
        adTitleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        adTitleButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        adTitleButton.setTitle("这是一条广告信息数据，预留出来以后用", forState: UIControlState.Normal)
        return adTitleButton
    }()
    
}
