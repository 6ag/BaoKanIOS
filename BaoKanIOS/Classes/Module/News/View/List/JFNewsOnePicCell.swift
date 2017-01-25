//
//  JFNewsOnePicCell.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/14.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

class JFNewsOnePicCell: UITableViewCell {
    
    var postModel: JFArticleListModel? {
        didSet {
            guard let postModel = postModel else { return }
            iconView.image = nil
            iconView.setImage(urlString: postModel.titlepic ?? "", placeholderImage: UIImage(named: "placeholder_logo"))
            articleTitleLabel.text = postModel.title
            timeLabel.text = postModel.newstimeString
            commentLabel.text = postModel.plnum
            showNumLabel.text = postModel.onclick
            
        }
    }
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var showNumLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 离屏渲染 - 异步绘制
        layer.drawsAsynchronously = true
        
        // 栅格化 - 异步绘制之后，会生成一张独立的图像，cell在屏幕上滚动的时候，本质滚动的是这张图片
        layer.shouldRasterize = true
        
        // 使用栅格化，需要指定分辨率
        layer.rasterizationScale = UIScreen.main.scale
    }
}
