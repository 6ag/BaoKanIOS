//
//  JFCommentCommitView.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/12.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

protocol JFCommentCommitViewDelegate {
    func didTappedSendButtonWithMessage(_ message: String) -> Void
}

class JFCommentCommitView: UIView, UITextViewDelegate {
    
    var delegate: JFCommentCommitViewDelegate?
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    let bgView = UIView(frame: SCREEN_BOUNDS)
    
    /**
     取消按钮点击
     */
    @IBAction func didTappedCancelButton(_ sender: UIButton) {
        dismiss()
    }
    
    /**
     发送按钮点击
     */
    @IBAction func didTappedSendButton(_ sender: UIButton) {
        delegate?.didTappedSendButtonWithMessage(textView.text)
        dismiss()
    }
    
    @objc fileprivate func didTappedBgView(_ tap: UITapGestureRecognizer) {
        dismiss()
    }
    
    /**
     弹出评论视图
     */
    func show() -> Void {
        
        bgView.backgroundColor = UIColor(white: 0, alpha: 0)
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedBgView(_:))))
        UIApplication.shared.keyWindow?.addSubview(bgView)
        
        frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        UIApplication.shared.keyWindow?.addSubview(self)
        
        textView.becomeFirstResponder()
        
        UIView.animate(withDuration: 0.25, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: -480)
            self.bgView.backgroundColor = UIColor(white: 0, alpha: GLOBAL_SHADOW_ALPHA)
        }, completion: { (_) in
            self.textView.delegate = self
        }) 
    }
    
    /**
     隐藏评论视图
     */
    func dismiss() -> Void {
        
        textView.resignFirstResponder()
        
        UIView.animate(withDuration: 0.25, animations: {
            self.transform = CGAffineTransform.identity
            self.bgView.backgroundColor = UIColor(white: 0, alpha: 0)
            }, completion: { (_) in
                self.bgView.removeFromSuperview()
                self.removeFromSuperview()
        }) 
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.characters.count >= 3 {
            sendButton.isEnabled = true
            sendButton.setTitleColor(UIColor.black, for: UIControlState())
        } else {
            sendButton.isEnabled = false
            sendButton.setTitleColor(UIColor.gray, for: UIControlState())
        }
    }

}
