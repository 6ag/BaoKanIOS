//
//  JFProfileCell.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/5.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFProfileCell: UITableViewCell {

    /// 是否显示分割线
    var showLineView: Bool = false {
        didSet {
            settingLineView.isHidden = !showLineView
        }
    }
    
    /// cell模型
    var cellModel: JFProfileCellModel? {
        didSet {
            
            // 左边数据
            textLabel?.text = cellModel!.title
            detailTextLabel?.text = cellModel!.subTitle
            
            if cellModel?.icon != nil {
                imageView?.image = UIImage(named: cellModel!.icon!)
            } else {
                imageView?.image = nil
            }
            
            // 右边数据
            selectionStyle = cellModel!.isKind(of: JFProfileCellArrowModel.self) ? .default : .none
            if cellModel!.isKind(of: JFProfileCellArrowModel.self) {
                accessoryView = settingArrowView
            } else if cellModel!.isKind(of: JFProfileCellSwitchModel.self) {
                let settingCellSwitch = cellModel as! JFProfileCellSwitchModel
                settingSwitchView.isOn = settingCellSwitch.on
                accessoryView = settingSwitchView
            } else if cellModel!.isKind(of: JFProfileCellLabelModel.self) {
                let settingCellLabel = cellModel as! JFProfileCellLabelModel
                settingRightLabel.text = settingCellLabel.text
                accessoryView = settingRightLabel
            }
            
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 准备视图
        prepareUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let lineX = textLabel!.frame.origin.x
        let lineH: CGFloat = 0.5
        let lineY = frame.size.height - lineH
        let lineW = frame.size.width - lineX
        settingLineView.frame = CGRect(x: lineX, y: lineY, width: lineW, height: lineH)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func prepareUI() {
        
        textLabel?.font = UIFont.systemFont(ofSize: 14)
        textLabel?.textColor = UIColor.black
        
        detailTextLabel?.font = UIFont.systemFont(ofSize: 11)
        detailTextLabel?.textColor = UIColor.black
        
        contentView.addSubview(settingLineView)
    }
    
    @objc fileprivate func didChangedSwitch(_ settingSwitch: UISwitch) {
        // 修改本地存储的状态
        UserDefaults.standard.set(settingSwitch.isOn, forKey: NIGHT_KEY)
    }
    
    // MARK: - 懒加载
    lazy var settingRightLabel: UILabel = {
        let settingRightLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
        settingRightLabel.textColor = UIColor.gray
        settingRightLabel.textAlignment = .right
        settingRightLabel.font = UIFont.systemFont(ofSize: 14)
        return settingRightLabel
    }()
    
    lazy var settingArrowView: UIImageView = {
        let settingArrowView = UIImageView(image: UIImage(named: "setting_arrow_icon"))
        return settingArrowView
    }()
    
    lazy var settingSwitchView: UISwitch = {
        let settingSwitchView = UISwitch()
        settingSwitchView.addTarget(self, action: #selector(didChangedSwitch(_:)), for: .valueChanged)
        return settingSwitchView
    }()
    
    lazy var settingLineView: UIView = {
        let settingLineView = UIView()
        settingLineView.backgroundColor = UIColor.black
        settingLineView.alpha = 0.1
        return settingLineView
    }()

}
