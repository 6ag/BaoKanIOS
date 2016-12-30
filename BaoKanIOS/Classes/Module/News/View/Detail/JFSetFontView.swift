//
//  JFSetFontView.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/26.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

protocol JFSetFontViewDelegate: NSObjectProtocol {
    func didChangeFontSize(_ fontSize: Int)
    func didChangedFontName(_ fontName: String)
    func didChangedNightMode(_ on: Bool)
}

class JFSetFontView: UIView {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var fontSegment: UISegmentedControl!
    
    var currentButton: UIButton!              // 当前选中状态的按钮
    let bgView = UIView(frame: SCREEN_BOUNDS) // 透明遮罩
    let minSize = 14                          //  16   18   20  22   24  26
    var delegate: JFSetFontViewDelegate?
    
    // 初始化
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if UserDefaults.standard.string(forKey: CONTENT_FONT_TYPE_KEY) == "" {
            fontSegment.selectedSegmentIndex = 0
        } else {
            fontSegment.selectedSegmentIndex = 1
        }
        
        // 字体大小
        let fontSize = UserDefaults.standard.integer(forKey: CONTENT_FONT_SIZE_KEY)
        let scale = (fontSize - minSize) / 2
        currentButton = viewWithTag(scale) as! UIButton
        currentButton.isSelected = true
        slider.setValue(Float(scale), animated: true)
    }
    
    /**
     修改了字体
     */
    @IBAction func didChangedFontSegment(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            delegate?.didChangedFontName("")
            UserDefaults.standard.set("", forKey: CONTENT_FONT_TYPE_KEY)
        } else {
            delegate?.didChangedFontName("汉仪旗黑")
            UserDefaults.standard.set("汉仪旗黑", forKey: CONTENT_FONT_TYPE_KEY)
        }
    }
    
    /**
     修改字体按钮点击
     */
    @IBAction func didTappedFontButton(_ button: UIButton) {
        currentButton = button
        slider.setValue(Float(button.tag), animated: true)
        selectHandle()
    }
    
    /**
     修改字体滑条滑动
     */
    @IBAction func didTappedSlider(_ sender: UISlider) {
        var scale = Int(sender.value)
        if sender.value - Float(Int(sender.value)) >= 0.5 {
            scale = Int(sender.value) + 1
        }
        
        sender.setValue(Float(scale), animated: true)
        currentButton = viewWithTag(scale) as! UIButton
        selectHandle()
    }
    
    /**
     修改字体按钮选中处理
     */
    fileprivate func selectHandle() {
        for subView in subviews {
            if subView.isKind(of: UIButton.classForCoder()) {
                let button = subView as! UIButton
                button.isSelected = false
            }
        }
        currentButton.isSelected = true
        
        // 字体大小系数 1 - 6
        let scale = currentButton.tag
        let fontSize = minSize + scale * 2
        delegate?.didChangeFontSize(fontSize)
        UserDefaults.standard.set(fontSize, forKey: CONTENT_FONT_SIZE_KEY)
    }
    
    /**
     透明背景遮罩触摸事件
     */
    @objc fileprivate func didTappedBgView(_ tap: UITapGestureRecognizer) {
        dismiss()
    }
    
    /**
     弹出视图
     */
    func show() -> Void {
        bgView.backgroundColor = UIColor(white: 0, alpha: 0)
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedBgView(_:))))
        UIApplication.shared.keyWindow?.addSubview(bgView)
        
        frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: 157)
        UIApplication.shared.keyWindow?.addSubview(self)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: -157)
            self.bgView.backgroundColor = UIColor(white: 0, alpha: GLOBAL_SHADOW_ALPHA)
        }, completion: { (_) in
            
        }) 
        
    }
    
    /**
     隐藏视图
     */
    func dismiss() -> Void {
        UIView.animate(withDuration: 0.25, animations: {
            self.transform = CGAffineTransform.identity
            self.bgView.backgroundColor = UIColor(white: 0, alpha: 0)
        }, completion: { (_) in
            self.bgView.removeFromSuperview()
            self.removeFromSuperview()
        }) 
    }
    
}
