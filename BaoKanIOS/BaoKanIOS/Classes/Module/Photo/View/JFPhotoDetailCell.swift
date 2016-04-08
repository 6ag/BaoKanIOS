//
//  JFPhotoDetailCell.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/4/8.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

class JFPhotoDetailCell: UICollectionViewCell {
    
    var model: JFPhotoDetailModel? {
        didSet {
            picImageView.yy_setImageWithURL(NSURL(string: model!.picurl!), placeholder: UIImage(named: "photoview_image_default_white"), options: YYWebImageOptions.ShowNetworkActivity) { (image, url, type, stage, error) in
                self.prepareUI()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        contentView.addSubview(picImageView)
        
        picImageView.snp_makeConstraints { (make) in
            make.center.equalTo(contentView)
            make.width.equalTo(SCREEN_WIDTH)
            make.height.equalTo(SCREEN_WIDTH / picImageView.image!.size.width * picImageView.image!.size.height)
        }
    }
    
    // MARK: - 懒加载
    private lazy var picImageView: UIImageView = {
        let picImageView = UIImageView()
        
        return picImageView
    }()
    
}
