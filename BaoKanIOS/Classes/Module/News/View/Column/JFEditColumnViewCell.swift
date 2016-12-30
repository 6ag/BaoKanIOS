//
//  JFEditColumnCollectionViewCell.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/31.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

protocol JFEditColumnViewCellDelegate {
    func deleteItemWithIndexPath(_ indexPath: IndexPath) -> Void
}

class JFEditColumnViewCell: UICollectionViewCell {
    
    var delegate: JFEditColumnViewCellDelegate?
    var indexPath: IndexPath?
    
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
        contentView.backgroundColor = UIColor.clear
        contentView.addSubview(contentLabel)
        contentView.addSubview(deleteButton)
    }
    
    /**
     配置cell
     */
    func configCell(_ dataArray: [[String : String]], withIndexPath indexPath: IndexPath) {
        self.indexPath = indexPath
        contentLabel.isHidden = false
        contentLabel.text = dataArray[indexPath.row]["classname"]!
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            contentLabel.textColor = UIColor.colorWithRGB(214, g: 39, b: 48)
            contentLabel.layer.masksToBounds = true
            contentLabel.layer.borderColor = UIColor.clear.cgColor
            contentLabel.layer.borderWidth = 0.0
        } else {
            contentLabel.textColor = UIColor.colorWithRGB(101, g: 101, b: 101)
            contentLabel.layer.masksToBounds = true
            contentLabel.layer.cornerRadius = self.contentView.bounds.height * 0.5
            contentLabel.layer.borderColor = UIColor.colorWithRGB(211, g: 211, b: 211).cgColor;
            contentLabel.layer.borderWidth = 0.45
        }
    }
    
    /**
     点击了删除按钮
     */
    func didTappedDeleteButton(_ button: UIButton) {
        delegate?.deleteItemWithIndexPath(indexPath!)
    }
    
    deinit {
        if let gestures = gestureRecognizers {
            for pan in gestures {
                removeGestureRecognizer(pan)
            }
        }
    }
    
    // MARK: - 懒加载
    lazy var contentLabel: UILabel = {
        let contentLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.contentView.bounds.size.width, height: self.contentView.bounds.size.height))
        contentLabel.center = self.contentView.center
        contentLabel.textAlignment = NSTextAlignment.center
        contentLabel.font = UIFont.systemFont(ofSize: 15)
        contentLabel.numberOfLines = 1
        contentLabel.adjustsFontSizeToFitWidth = true
        contentLabel.minimumScaleFactor = 0.1
        return contentLabel
    }()
    
    lazy var deleteButton: UIButton = {
        let deleteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        deleteButton.setBackgroundImage(UIImage(named: "delete"), for: UIControlState())
        deleteButton.addTarget(self, action: #selector(didTappedDeleteButton(_:)), for: UIControlEvents.touchUpInside)
        return deleteButton
    }()
}
