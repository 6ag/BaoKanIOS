//
//  JFEditColumnCollectionViewCell.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/31.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

protocol JFEditColumnViewCellDelegate {
    func deleteItemWithIndexPath(indexPath: NSIndexPath) -> Void
}

class JFEditColumnViewCell: UICollectionViewCell {
    
    var delegate: JFEditColumnViewCellDelegate?
    var indexPath: NSIndexPath?
    
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
    private func prepareUI() {
        contentView.backgroundColor = UIColor.clearColor()
        contentView.addSubview(contentLabel)
        contentView.addSubview(deleteButton)
    }
    
    /**
     配置cell
     */
    func configCell(dataArray: NSArray, withIndexPath indexPath: NSIndexPath) -> Void {
        self.indexPath = indexPath
        contentLabel.hidden = false
        contentLabel.text = dataArray[indexPath.row]["classname"] as? String
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            contentLabel.textColor = UIColor.colorWithRGB(214, g: 39, b: 48)
            contentLabel.layer.masksToBounds = true
            contentLabel.layer.borderColor = UIColor.clearColor().CGColor
            contentLabel.layer.borderWidth = 0.0
        } else {
            contentLabel.textColor = UIColor.colorWithRGB(101, g: 101, b: 101)
            contentLabel.layer.masksToBounds = true
            contentLabel.layer.cornerRadius = CGRectGetHeight(self.contentView.bounds) * 0.5
            contentLabel.layer.borderColor = UIColor.colorWithRGB(211, g: 211, b: 211).CGColor;
            contentLabel.layer.borderWidth = 0.45
        }
    }
    
    /**
     点击了删除按钮
     */
    func didTappedDeleteButton(button: UIButton) -> Void {
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
        contentLabel.textAlignment = NSTextAlignment.Center
        contentLabel.font = UIFont.systemFontOfSize(15)
        contentLabel.numberOfLines = 1
        contentLabel.adjustsFontSizeToFitWidth = true
        contentLabel.minimumScaleFactor = 0.1
        return contentLabel
    }()
    
    lazy var deleteButton: UIButton = {
        let deleteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        deleteButton.setBackgroundImage(UIImage(named: "delete"), forState: UIControlState.Normal)
        deleteButton.addTarget(self, action: #selector(didTappedDeleteButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return deleteButton
    }()
}
