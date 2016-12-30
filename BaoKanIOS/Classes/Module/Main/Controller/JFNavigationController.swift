//
//  JFNavigationController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit

class JFNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBar = navigationBar
        navBar.barTintColor = NAVIGATIONBAR_WHITE_COLOR
        navBar.isTranslucent = false
        navBar.barStyle = UIBarStyle.black
        navBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navBar.shadowImage = UIImage()
        navBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor(red:0.173,  green:0.173,  blue:0.173, alpha:1),
            NSFontAttributeName : UIFont.systemFont(ofSize: 18)
        ]
        
        // 全屏返回手势
        panGestureBack()
    }
    
    /**
     全屏返回手势
     */
    func panGestureBack() -> Void {
        let target = interactivePopGestureRecognizer?.delegate
        let pan = UIPanGestureRecognizer(target: target, action: Selector("handleNavigationTransition:"))
        pan.delegate = self
        view.addGestureRecognizer(pan)
        interactivePopGestureRecognizer?.isEnabled = false
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gesture: UIGestureRecognizer) -> Bool {
        if childViewControllers.count == 1 {
            return false
        } else {
            return true
        }
    }
    
    /**
     拦截push操作
     
     - parameter viewController: 即将压入栈的控制器
     - parameter animated:       是否动画
     */
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        } else {
            viewController.hidesBottomBarWhenPushed = false
        }
        
        super.pushViewController(viewController, animated: animated)
        
        // 压入栈后创建返回按钮
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "top_navigation_back")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal),
            style: UIBarButtonItemStyle.done,
            target: self,
            action: #selector(back)
        )
    }
    
    /**
     全局返回操作
     */
    @objc fileprivate func back() {
        popViewController(animated: true)
    }
    
}
