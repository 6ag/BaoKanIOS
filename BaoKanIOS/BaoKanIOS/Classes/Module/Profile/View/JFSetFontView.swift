//
//  JFSetFontView.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/26.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

protocol JFSetFontViewDelegate: NSObjectProtocol {
    func didChangeFontSize() -> Void
}

class JFSetFontView: UIView {
    
    @IBOutlet weak var slider: UISlider!
    
    var currentButton: UIButton!
    let bgView = UIView(frame: SCREEN_BOUNDS)
    let minSize = 12 // 14   16   18   20  22   24
    var delegate: JFSetFontViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let fontSize = NSUserDefaults.standardUserDefaults().integerForKey(CONTENT_FONT_SIZE)
        let scale = (fontSize - minSize) / 2
        currentButton = viewWithTag(scale) as! UIButton
        currentButton.selected = true
        slider.setValue(Float(scale), animated: true)
    }
    
    /**
     选中处理
     */
    private func selectHandle() {
        for subView in subviews {
            if subView.isKindOfClass(UIButton.classForCoder()) {
                let button = subView as! UIButton
                button.selected = false
            }
        }
        currentButton.selected = true
        
        // 字体大小系数 1 - 6
        let scale = currentButton.tag
        let fontSize = minSize + scale * 2
        NSUserDefaults.standardUserDefaults().setInteger(fontSize, forKey: CONTENT_FONT_SIZE)
        delegate?.didChangeFontSize()
    }
    
    @IBAction func didTappedFontButton(button: UIButton) {
        currentButton = button
        slider.setValue(Float(button.tag), animated: true)
        selectHandle()
    }
    
    @IBAction func didTappedSlider(sender: UISlider) {
        var scale = Int(sender.value)
        if sender.value - Float(Int(sender.value)) >= 0.5 {
            scale = Int(sender.value) + 1
        }
        
        sender.setValue(Float(scale), animated: true)
        currentButton = viewWithTag(scale) as! UIButton
        selectHandle()
    }
    
    @objc private func didTappedBgView(tap: UITapGestureRecognizer) {
        dismiss()
    }
    
    /**
     弹出视图
     */
    func show() -> Void {
        bgView.backgroundColor = UIColor(white: 0, alpha: 0)
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedBgView(_:))))
        UIApplication.sharedApplication().keyWindow?.addSubview(bgView)
        
        frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: 120)
        UIApplication.sharedApplication().keyWindow?.addSubview(self)
        
        UIView.animateWithDuration(0.25, animations: {
            self.transform = CGAffineTransformMakeTranslation(0, -120)
            self.bgView.backgroundColor = UIColor(white: 0, alpha: GLOBAL_SHADOW_ALPHA)
        }) { (_) in
            
        }
        
    }
    
    /**
     隐藏视图
     */
    func dismiss() -> Void {
        UIView.animateWithDuration(0.25, animations: {
            self.transform = CGAffineTransformIdentity
            self.bgView.backgroundColor = UIColor(white: 0, alpha: 0)
        }) { (_) in
            self.bgView.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    
}
