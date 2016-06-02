//
//  JFDutyViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/13.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import Mustache

class JFDutyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor()
        
        let html = "<!doctype html>" +
        "<head>" +
        "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"/>" +
        "<style type=\"text/css\">" +
        ".container {background: #FFFFFF;}" +
        ".content {width: 100%;font-size: 16px;}" +
        "p {margin: 0px 0px 5px 0px}" +
        "</style>" +
        "</head>" +
        "<body class=\"container\">" +
        "<div class=\"content\">" +
        "<p>　　一、未经爆侃网文正式书面授权许可，任何个人、媒体、网站、团体不得转载、链接、转贴或以其他方式复制发表爆侃网文上的所有拥有版权的信息，禁止任何媒体在未获得书面授权的情况下转载的作品，或在非爆侃网文所属的服务器上建立镜像。</p>" +
        "<p>　　二、需要使用爆侃网文新闻信息或链接网址的个人、媒体、网站、团体，请与爆侃网文联系。相关授权使用者，在使用时必须注明作者名及稿件来源为“爆侃网文”。</p>" +
        "<p>　　三、本网未注明稿件来源为“爆侃网文”的新闻信息，均为转载稿。本网站转载仅仅出于传递更多信息的目的，并不代表赞同其观点或证实其内容的真实性。如其他个人、媒体、网站、团体从本网下载使用，必须保留本网站注明的“稿件来源”，并自负相关法律责任。如擅自更改稿件来源，将依法追究相关责任。</p>" +
        "<p>　　客服QQ：2911 6488 45</p>" +
        "<p>　　联系邮箱：2911648845@qq.com</p>" +
        "<p>　　新浪微博：http://weibo.com/baokan88</p>" +
        "<p>　　微信订阅号：baokan66</p>" +
        "</div>" +
        "</body>" +
        "</html>"
        
        let webView = UIWebView(frame: SCREEN_BOUNDS)
        view.addSubview(webView)
        
        let template = try! Template(string: html)
        let rendering = try! template.render()
        webView.loadHTMLString(rendering, baseURL: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

}
