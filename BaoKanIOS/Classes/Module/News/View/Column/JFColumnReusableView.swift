//
//  JFColumnReusableView.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/31.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

enum ButtonState {
    case stateComplish
    case stateSortDelete
}

class JFColumnReusableView: UICollectionReusableView {
    
    typealias ClickBlock = (_ state: ButtonState) -> ()
    var clickBlock: ClickBlock?
    var buttonHidden: Bool? {
        didSet {
            clickButton.isHidden = buttonHidden!
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clickWithBlock(_ clickBlock: @escaping ClickBlock) -> Void {
        self.clickBlock = clickBlock
    }
    
    fileprivate func prepareUI() {
        addSubview(titleLabel)
        addSubview(clickButton)
    }
    
    
    func didTappedClickButton(_ button: UIButton) -> Void {
        button.isSelected = !button.isSelected
        if button.isSelected {
            clickBlock!(ButtonState.stateSortDelete)
        } else {
            clickBlock!(ButtonState.stateComplish)
        }
    }
    
    // MARK: - 懒加载
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect(x: 10, y: 0, width: 200, height: self.bounds.size.height))
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = UIColor.colorWithRGB(51, g: 51, b: 51)
        return titleLabel
    }()
    
    lazy var clickButton: UIButton = {
        let clickButton = UIButton(frame: CGRect(x: SCREEN_WIDTH - 100, y: 10, width: 60, height: 20))
        clickButton.backgroundColor = UIColor.white
        clickButton.layer.masksToBounds = true
        clickButton.layer.cornerRadius = 10
        clickButton.layer.borderColor = UIColor.colorWithRGB(214, g: 39, b: 48) .cgColor;
        clickButton.layer.borderWidth = 0.7;
        clickButton.setTitle("排序删除", for: UIControlState())
        clickButton.setTitle("完成", for: UIControlState.selected)
        clickButton.titleLabel!.font = UIFont.systemFont(ofSize: 13)
        clickButton.setTitleColor(UIColor.colorWithRGB(214, g: 39, b: 48), for: UIControlState())
        clickButton.addTarget(self, action: #selector(didTappedClickButton(_:)), for: UIControlEvents.touchUpInside)
        return clickButton
    }()
    
}
