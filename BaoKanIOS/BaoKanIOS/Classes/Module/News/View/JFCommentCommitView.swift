//
//  JFCommentCommitView.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/12.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

protocol JFCommentCommitViewDelegate {
    func didTappedSendButtonWithMessage(message: String) -> Void
}

class JFCommentCommitView: UIView, UITextViewDelegate {
    
    var delegate: JFCommentCommitViewDelegate?
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    let bgView = UIView(frame: SCREEN_BOUNDS)
    
    /**
     取消按钮点击
     */
    @IBAction func didTappedCancelButton(sender: UIButton) {
        dismiss()
    }
    
    /**
     发送按钮点击
     */
    @IBAction func didTappedSendButton(sender: UIButton) {
        delegate?.didTappedSendButtonWithMessage(textView.text)
        dismiss()
    }
    
    /**
     弹出评论视图
     */
    func show() -> Void {
        
        bgView.backgroundColor = UIColor(white: 0, alpha: GLOBAL_SHADOW_ALPHA)
        UIApplication.sharedApplication().keyWindow?.addSubview(bgView)
        
        frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        UIApplication.sharedApplication().keyWindow?.addSubview(self)
        
        textView.becomeFirstResponder()
        
        UIView.animateWithDuration(0.25, animations: {
            self.transform = CGAffineTransformMakeTranslation(0, -480)
        }) { (_) in
            self.textView.delegate = self
        }
    }
    
    /**
     隐藏评论视图
     */
    func dismiss() -> Void {
        
        textView.resignFirstResponder()
        
        UIView.animateWithDuration(0.25, animations: {
            self.transform = CGAffineTransformIdentity
            }) { (_) in
                self.bgView.removeFromSuperview()
                self.removeFromSuperview()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView.text.characters.count >= 3 {
            sendButton.enabled = true
            sendButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        } else {
            sendButton.enabled = false
            sendButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        }
    }

}
