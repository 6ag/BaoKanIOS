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
    
    var cellHeight: CGFloat = 240
    
    var postModel: JFArticleListModel? {
        didSet {
            // 进度圈半径
            let radius: CGFloat = 30.0
            let progressView = JFProgressView(frame: CGRect(x: SCREEN_WIDTH / 2 - radius, y: cellHeight / 2 - radius, width: radius * 2, height: radius * 2))
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
        
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = 3
        layer.masksToBounds = true
        
        contentView.addSubview(iconView)
        contentView.addSubview(bottomBarView)
        contentView.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let model = postModel {
            var rect = bounds
            rect.origin.y += model.offsetY
            iconView.frame = rect
        }
        
    }
    
    func cellOffset() -> CGFloat {
        let centerToWindow = convertRect(bounds, toView: window)
        let centerY = CGRectGetMidY(centerToWindow)
        let windowCenter = window!.center
        let cellOffsetY = centerY - windowCenter.y
        let offsetDig = cellOffsetY / SCREEN_HEIGHT * 3
        postModel!.offsetY = -offsetDig * (SCREEN_HEIGHT / 1.7 - 240) / 2
        iconView.transform = CGAffineTransformMakeTranslation(0, postModel!.offsetY)
        return postModel!.offsetY
    }
    
    // MARK: - 懒加载
    private lazy var iconView: UIImageView = {
        let iconView = UIImageView()
        iconView.contentMode = .ScaleAspectFill
        iconView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: self.cellHeight)
        return iconView
    }()
    
    private lazy var bottomBarView: UIView = {
        let bottomBarView = UIView(frame: CGRect(x: 0, y: self.cellHeight - 30, width: SCREEN_WIDTH, height: 30))
        bottomBarView.backgroundColor = UIColor(white: 0.2, alpha: 0.7)
        return bottomBarView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont.systemFontOfSize(15)
        titleLabel.frame = CGRect(x: 0, y: self.cellHeight - 30, width: SCREEN_WIDTH, height: 30)
        return titleLabel
    }()
}
