//
//  JFNewsThreePicCell.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/14.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

class JFNewsThreePicCell: UITableViewCell {
    
    var postModel: JFArticleListModel? {
        didSet {
            guard let postModel = postModel else { return }
            
            // 防止数据问题出此下策
            if postModel.morepic?.count == 1 {
                iconView1.image = nil
                iconView1.setImage(urlString: postModel.morepic?[0] ?? "", placeholderImage: UIImage(named: "placeholder_logo"))
            } else if postModel.morepic?.count == 2 {
                iconView1.image = nil
                iconView2.image = nil
                iconView1.setImage(urlString: postModel.morepic?[0] ?? "", placeholderImage: UIImage(named: "placeholder_logo"))
                iconView2.setImage(urlString: postModel.morepic?[1] ?? "", placeholderImage: UIImage(named: "placeholder_logo"))
            } else if postModel.morepic?.count == 3 {
                iconView1.image = nil
                iconView2.image = nil
                iconView3.image = nil
                iconView1.setImage(urlString: postModel.morepic?[0] ?? "", placeholderImage: UIImage(named: "placeholder_logo"))
                iconView2.setImage(urlString: postModel.morepic?[1] ?? "", placeholderImage: UIImage(named: "placeholder_logo"))
                iconView3.setImage(urlString: postModel.morepic?[2] ?? "", placeholderImage: UIImage(named: "placeholder_logo"))
            }
            
            articleTitleLabel.text = postModel.title
            timeLabel.text = postModel.newstimeString
            commentLabel.text = postModel.plnum
            showNumLabel.text = postModel.onclick
        }
    }
    
    @IBOutlet weak var iconView1: UIImageView!
    @IBOutlet weak var iconView2: UIImageView!
    @IBOutlet weak var iconView3: UIImageView!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var showNumLabel: UILabel!
    
    /**
     计算行高
     */
    func getRowHeight(_ postModel: JFArticleListModel) -> CGFloat {
        self.postModel = postModel
        layoutIfNeeded()
        return timeLabel.frame.maxY + 15
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
    
}
