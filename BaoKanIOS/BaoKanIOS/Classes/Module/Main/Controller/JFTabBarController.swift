//
//  JFTabBarController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit

class JFTabBarController: UITabBarController {
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // 配置tabBar图标颜色
        tabBar.tintColor = UIColor.redColor()
        
        // 添加所有子控制器
        addAllChildViewController()
    }
    
    /**
     添加所有子控制器
     */
    private func addAllChildViewController()
    {
        // 新闻
        let newsVc = UIStoryboard.init(name: "JFNewsViewController", bundle: nil).instantiateInitialViewController()!
        addChildViewController(newsVc, title: "新闻", imageName: "tabbar_icon_news")
        
        // 阅读
        let readVc = UIStoryboard.init(name: "JFReadViewController", bundle: nil).instantiateInitialViewController()!
        addChildViewController(readVc, title: "阅读", imageName: "tabbar_icon_reader")
        
        // 娱乐
        let recVc = UIStoryboard.init(name: "JFRecViewController", bundle: nil).instantiateInitialViewController()!
        addChildViewController(recVc, title: "娱乐", imageName: "tabbar_icon_media")
        
        // 社区
        let bzoneVc = UIStoryboard.init(name: "JFBzoneViewController", bundle: nil).instantiateInitialViewController()!
        addChildViewController(bzoneVc, title: "社区", imageName: "tabbar_icon_bar")
        
        // 我
        let profileVc = UIStoryboard.init(name: "JFProfileViewController", bundle: nil).instantiateInitialViewController()!
        addChildViewController(profileVc, title: "我", imageName: "tabbar_icon_me")
    }
    
    /**
     配置添加子控制器
     
     - parameter childController: 控制器
     - parameter title:           标题
     - parameter imageName:       图片
     */
    private func addChildViewController(childController: UIViewController, title: String, imageName: String)
    {
        childController.title = title
        childController.tabBarItem.title = title
        childController.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -3)
        childController.tabBarItem.setTitleTextAttributes([NSFontAttributeName : UIFont.systemFontOfSize(12)], forState: UIControlState.Normal)
        childController.tabBarItem.image = UIImage(named: "\(imageName)_normal")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        childController.tabBarItem.selectedImage = UIImage(named: "\(imageName)_highlight")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        addChildViewController(childController)
    }
    
}
