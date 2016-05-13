//
//  JFPhotoListCell.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/14.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

class JFPhotoListCell: UITableViewCell {
    
    var postModel: JFArticleListModel? {
        didSet {
            // 进度圈半径
            let radius: CGFloat = 30.0
            let progressView = JFProgressView(frame: CGRect(x: SCREEN_WIDTH / 2 - radius, y: 240 / 2 - radius, width: radius * 2, height: radius * 2))
            progressView.radius = radius
            progressView.backgroundColor = UIColor.whiteColor()
            
            iconView.yy_setImageWithURL(NSURL(string: postModel!.titlepic!), placeholder: nil, options: YYWebImageOptions.SetImageWithFadeAnimation, progress: { (receivedSize, expectedSize) in
                self.contentView.addSubview(progressView)
                progressView.progress = CGFloat(receivedSize) / CGFloat(expectedSize)
                }, transform: { (image, url) -> UIImage! in
                    return image
            }) { (image, url, type, stage, error) in
                progressView.removeFromSuperview()
            }
            
            titleLabel.text = postModel!.title
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        // 准备uI
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        
        // 约束控件
        iconView.snp_makeConstraints { (make) -> Void in
            make.top.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(200)
        }
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(iconView.snp_bottom).offset(10)
            make.centerX.equalTo(iconView)
        }
        
    }
    
    // MARK: - 懒加载
    private lazy var iconView: UIImageView = {
        let iconView = UIImageView()
        iconView.contentMode = UIViewContentMode.ScaleAspectFill
        iconView.layer.masksToBounds = true
        return iconView
    }()
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        return titleLabel
    }()
    
}
