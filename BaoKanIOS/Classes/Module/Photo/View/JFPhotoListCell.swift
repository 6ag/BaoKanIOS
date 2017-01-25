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
    
    var cellHeight: CGFloat = 200
    
    var postModel: JFArticleListModel? {
        didSet {
            // 进度圈半径
            let radius: CGFloat = 30.0
            let progressView = JFProgressView(frame: CGRect(x: SCREEN_WIDTH / 2 - radius, y: cellHeight / 2 - radius, width: radius * 2, height: radius * 2))
            progressView.radius = radius
            
            iconView.yy_setImage(with: URL(string: postModel!.titlepic!), placeholder: nil, options: YYWebImageOptions.setImageWithFadeAnimation, progress: { (receivedSize, expectedSize) in
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
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        // 准备uI
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 离屏渲染 - 异步绘制
        layer.drawsAsynchronously = true
        
        // 栅格化 - 异步绘制之后，会生成一张独立的图像，cell在屏幕上滚动的时候，本质滚动的是这张图片
        layer.shouldRasterize = true
        
        // 使用栅格化，需要指定分辨率
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        
        layer.borderColor = UIColor.white.cgColor
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
        let centerToWindow = convert(bounds, to: window)
        let centerY = centerToWindow.midY
        let windowCenter = window!.center
        let cellOffsetY = centerY - windowCenter.y
        let offsetDig = cellOffsetY / SCREEN_HEIGHT * 3
        postModel!.offsetY = -offsetDig * (SCREEN_HEIGHT / 1.7 - self.cellHeight) / 6
        iconView.transform = CGAffineTransform(translationX: 0, y: postModel!.offsetY)
        return postModel!.offsetY
    }
    
    // MARK: - 懒加载
    fileprivate lazy var iconView: UIImageView = {
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFill
        iconView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: self.cellHeight)
        return iconView
    }()
    
    fileprivate lazy var bottomBarView: UIView = {
        let bottomBarView = UIView(frame: CGRect(x: 0, y: self.cellHeight - 30, width: SCREEN_WIDTH, height: 30))
        bottomBarView.backgroundColor = UIColor(white: 0.2, alpha: 0.7)
        return bottomBarView
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.frame = CGRect(x: 0, y: self.cellHeight - 30, width: SCREEN_WIDTH, height: 30)
        return titleLabel
    }()
}
