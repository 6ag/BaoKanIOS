//
//  JFShareItemCell.swift
//  WindSpeedVPN
//
//  Created by zhoujianfeng on 2016/11/30.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit

class JFShareItemCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var shareItem: JFShareItemModel? {
        didSet {
            guard let shareItem = shareItem else {
                return
            }
            shareTitleLabel.text = shareItem.title!
            shareIconImageView.image = UIImage(named: shareItem.icon!)
        }
    }
    
    /// 准备UI
    private func prepareUI() {
        
        backgroundColor = UIColor.clear
        contentView.addSubview(shareIconImageView)
        contentView.addSubview(shareTitleLabel)
        
        shareIconImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(layoutVertical(iPhone6: 40))
            make.size.equalTo(CGSize(width: layoutVertical(iPhone6: 50), height: layoutVertical(iPhone6: 50)))
        }
        
        shareTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(shareIconImageView.snp.bottom).offset(layoutVertical(iPhone6: 15))
        }
        
    }
    
    // MARK: - 懒加载
    /// 标题
    private lazy var shareTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.colorWithHexString("0D0D0D")
        label.font = UIFont.systemFont(ofSize: layoutFont(iPhone6: 15))
        return label
    }()
    
    /// 图标
    private lazy var shareIconImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
}
