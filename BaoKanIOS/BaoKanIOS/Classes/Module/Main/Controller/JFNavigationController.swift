//
//  JFNavigationController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit

class JFNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置全局导航栏
        let navBar = UINavigationBar.appearance()
        navBar.barTintColor = NAVIGATIONBAR_COLOR
        navBar.translucent = false
        navBar.barStyle = UIBarStyle.Black
        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navBar.shadowImage = UIImage()
        navBar.titleTextAttributes = [
            "NSForegroundColorAttributeName" : UIColor.whiteColor(),
            "NSFontAttributeName" : UIFont.systemFontOfSize(22)
        ]
        
    }
    
    /**
     拦截push操作
     
     - parameter viewController: 即将压入栈的控制器
     - parameter animated:       是否动画
     */
    override func pushViewController(viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        
        // 压入栈后创建返回按钮
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "top_navigation_back"), style: UIBarButtonItemStyle.Done, target: self, action: "back")
    }
    
    /**
     全局返回操作
     */
    private func back() {
        self.popViewControllerAnimated(true)
    }
    
}
