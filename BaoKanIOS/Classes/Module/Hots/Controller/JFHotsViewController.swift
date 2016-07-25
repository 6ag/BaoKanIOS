//
//  JFHotsViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit

class JFHotsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(newsVc.view)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = NAVIGATIONBAR_RED_COLOR
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    @IBAction func didTappedSearchButton(sender: UIButton) {
        navigationController?.pushViewController(JFSearchViewController(), animated: true)
    }
    // MARK: - 懒加载
    lazy var newsVc: JFNewsTableViewController = {
        let newsVc = JFNewsTableViewController()
        self.addChildViewController(newsVc)
        newsVc.view.frame = self.view.bounds
        newsVc.classid = 461
        return newsVc
    }()

}
