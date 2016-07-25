//
//  JFPopoverModalAnimation.swift
//  popoverDemo
//
//  Created by jianfeng on 15/11/9.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit

class JFNewsPhotoModalAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    // 动画时间
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1
    }
    
    // modal动画
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // 获取到需要modal的控制器的view
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        toView.alpha = 0
        
        // 将需要modal的控制器的view添加到容器视图
        transitionContext.containerView()?.addSubview(toView)
        
        UIView.animateWithDuration(transitionDuration(nil), animations: {
            toView.alpha = 1
            }) { (_) in
                transitionContext.completeTransition(true)
        }
    }
}