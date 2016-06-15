//
//  JFColumnReusableView.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/31.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

enum ButtonState {
    case StateComplish
    case StateSortDelete
}

class JFColumnReusableView: UICollectionReusableView {
    
    typealias ClickBlock = (state: ButtonState) -> ()
    var clickBlock: ClickBlock?
    var buttonHidden: Bool? {
        didSet {
            clickButton.hidden = buttonHidden!
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clickWithBlock(clickBlock: ClickBlock) -> Void {
        self.clickBlock = clickBlock
    }
    
    private func prepareUI() {
        addSubview(titleLabel)
        addSubview(clickButton)
    }
    
    
    func didTappedClickButton(button: UIButton) -> Void {
        button.selected = !button.selected
        if button.selected {
            clickBlock!(state: ButtonState.StateSortDelete)
        } else {
            clickBlock!(state: ButtonState.StateComplish)
        }
    }
    
    // MARK: - 懒加载
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect(x: 10, y: 0, width: 200, height: self.bounds.size.height))
        titleLabel.font = UIFont.systemFontOfSize(14)
        titleLabel.textColor = UIColor.colorWithRGB(51, g: 51, b: 51)
        return titleLabel
    }()
    
    lazy var clickButton: UIButton = {
        let clickButton = UIButton(frame: CGRect(x: SCREEN_WIDTH - 80, y: 10, width: 60, height: 20))
        clickButton.backgroundColor = UIColor.whiteColor()
        clickButton.layer.masksToBounds = true
        clickButton.layer.cornerRadius = 10
        clickButton.layer.borderColor = UIColor.colorWithRGB(214, g: 39, b: 48) .CGColor;
        clickButton.layer.borderWidth = 0.7;
        clickButton.setTitle("排序删除", forState: UIControlState.Normal)
        clickButton.setTitle("完成", forState: UIControlState.Selected)
        clickButton.titleLabel!.font = UIFont.systemFontOfSize(13)
        clickButton.setTitleColor(UIColor.colorWithRGB(214, g: 39, b: 48), forState: UIControlState.Normal)
        clickButton.addTarget(self, action: #selector(didTappedClickButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return clickButton
    }()
    
}
