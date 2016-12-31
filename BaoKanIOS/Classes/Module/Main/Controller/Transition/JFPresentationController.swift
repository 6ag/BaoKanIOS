//
//  JFPresentationController.swift
//  popoverDemo
//
//  Created by jianfeng on 15/11/9.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit

class JFPresentationController: UIPresentationController {
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        presentedView?.frame = CGRect(x: 0, y: 20, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 20)
        
        // 关闭按钮
        let closeButton = UIButton(frame: CGRect(x: SCREEN_WIDTH - 40, y: 20, width: 40, height: 40))
        closeButton.setImage(UIImage(named: "channel_nav_plus_colse"), for: UIControlState())
        closeButton.addTarget(self, action: #selector(didTappedCloseButton(_:)), for: UIControlEvents.touchUpInside)
        closeButton.alpha = 0
        containerView?.addSubview(closeButton)
        
        UIView.animate(withDuration: 0.5, animations: {
            closeButton.alpha = 1
            closeButton.imageView!.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI) - 0.01)
        })
        
    }
    
    /**
     容器视图区域的点击手势
     */
    @objc fileprivate func didTappedCloseButton(_ button: UIButton) {
        // 发出栏目管理视图即将消失的通知
        NotificationCenter.default.post(name: Notification.Name(rawValue: "columnViewWillDismiss"), object: nil)
        UIView.animate(withDuration: 0.5, animations: {
            button.alpha = 0
            button.imageView!.transform = CGAffineTransform.identity
            }, completion: { (_) in
                button.removeFromSuperview()
        }) 
        
        // 会触发自定义dismiss动画
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
