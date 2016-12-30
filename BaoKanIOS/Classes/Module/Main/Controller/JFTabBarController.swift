//
//  JFTabBarController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit

class JFTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 配置tabBar图标颜色
        tabBar.tintColor = NAVIGATIONBAR_RED_COLOR
        
        // 添加所有子控制器
        addAllChildViewController()
    }
    
    /**
     添加所有子控制器
     */
    fileprivate func addAllChildViewController() {
        // 新闻
        let newsVc = UIStoryboard.init(name: "JFNewsViewController", bundle: nil).instantiateInitialViewController()!
        addChildViewController(newsVc, title: "资讯", imageName: "tabbar_icon_news")
        
        // 图秀
        let recVc = UIStoryboard.init(name: "JFPhotoViewController", bundle: nil).instantiateInitialViewController()!
        addChildViewController(recVc, title: "图秀", imageName: "tabbar_icon_media")
        
        // 热门
        let readVc = UIStoryboard.init(name: "JFHotsViewController", bundle: nil).instantiateInitialViewController()!
        addChildViewController(readVc, title: "热门", imageName: "tabbar_icon_reader")
        
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
    fileprivate func addChildViewController(_ childController: UIViewController, title: String, imageName: String) {
        childController.title = title
        childController.tabBarItem.title = title
        childController.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -3)
        childController.tabBarItem.setTitleTextAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: 12)], for: UIControlState())
        childController.tabBarItem.image = UIImage(named: "\(imageName)_normal")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        childController.tabBarItem.selectedImage = UIImage(named: "\(imageName)_highlight")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        addChildViewController(childController)
    }
    
}
