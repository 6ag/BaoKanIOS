//
//  JFAboutMeViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/6/11.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFAboutMeViewController: UIViewController {

    override func loadView() {
        view = UIWebView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        let htmlPath = NSBundle.mainBundle().pathForResource("www/html/aboutme.html", ofType: nil)!
        let htmlString = try! String(contentsOfFile: htmlPath, encoding: NSUTF8StringEncoding)
        (view as! UIWebView).loadHTMLString(htmlString, baseURL: NSURL(fileURLWithPath: htmlPath))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

}
