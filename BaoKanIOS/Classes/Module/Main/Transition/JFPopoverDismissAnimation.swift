//
//  JFPopoverDismissAnimation.swift
//  popoverDemo
//
//  Created by jianfeng on 15/11/9.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit

class JFPopoverDismissAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    // 动画时间
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    // dismiss动画
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // 获取到modal出来的控制器的view
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        
        // 动画收起modal出来的控制器的view
        UIView.animateWithDuration(transitionDuration(nil), animations: {
            fromView.transform = CGAffineTransformMakeTranslation(0, (SCREEN_HEIGHT + 64))
        }) { (_) in
            transitionContext.completeTransition(true)
        }
        
    }
}
