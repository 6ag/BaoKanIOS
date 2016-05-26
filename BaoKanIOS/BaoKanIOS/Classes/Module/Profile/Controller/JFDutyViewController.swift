//
//  JFDutyViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/13.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFDutyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = BACKGROUND_COLOR
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

}
