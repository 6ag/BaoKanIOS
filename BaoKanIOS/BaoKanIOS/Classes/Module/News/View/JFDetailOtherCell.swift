//
//  JFDetailOtherCell.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/2/24.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

class JFDetailOtherCell: UITableViewCell {
    
    var data: [String : String]? {
        didSet {
            myImageView.yy_setImageWithURL(NSURL(string: data!["titlepic"]!), options: YYWebImageOptions.ShowNetworkActivity)
            myTitleLabel.text = data!["title"]!
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
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
        contentView.addSubview(myImageView)
        contentView.addSubview(myTitleLabel)
        
        myImageView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(10)
            make.centerY.equalTo(contentView)
            make.size.equalTo(CGSize(width: 60, height: 40))
        }
        
        myTitleLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(myImageView.snp_right).offset(10)
            make.right.equalTo(-10)
            make.centerY.equalTo(contentView)
        }
    }
    
    lazy var myImageView: UIImageView = {
        let myImageView = UIImageView()
        return myImageView
    }()
    lazy var myTitleLabel: UILabel = {
        let myTitleLabel = UILabel()
        myTitleLabel.numberOfLines = 0
        myTitleLabel.textColor = UIColor.colorWithRGB(0, g: 5, b: 5)
        myTitleLabel.font = UIFont.systemFontOfSize(15)
        return myTitleLabel
    }()
    
    
}
