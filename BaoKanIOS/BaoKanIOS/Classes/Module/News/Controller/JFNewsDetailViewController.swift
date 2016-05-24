//
//  JFNewsDetailViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/2/19.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage
import MJRefresh
import WebKit

class JFNewsDetailViewController: UIViewController {
    
    // MARK: - 属性
    var contentOffsetY: CGFloat = 0.0
    
    /// 文章详情请求参数
    var articleParam: (classid: String, id: String)?
    
    /// 详情页面模型
    var model: JFArticleDetailModel? {
        didSet {
            // 更新页面数据
            loadWebViewContent(model!)
            
            // 更新评论数量
            if model!.plnum! != "0" {
                bottomBarView.commentButton.setTitle(model!.plnum!, forState: UIControlState.Normal)
            }
            
            // 更新收藏状态
            bottomBarView.collectionButton.selected = model?.havefava == "favorfill"
        }
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // 加载数据
        updateData()
    }
    
    deinit {
        print("文章详情释放了")
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(tableView)
        view.addSubview(topBarView)
        view.addSubview(bottomBarView)
        view.addSubview(activityView)
        
        topBarView.snp_makeConstraints { (make) in
            make.left.right.top.equalTo(0)
            make.height.equalTo(20)
        }
        bottomBarView.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(45)
        }
    }
    
    @objc private func updateData() {
        // 请求页面数据
        loadNewsDetail(articleParam!.classid, id: articleParam!.id)
    }
    
    // MARK: - 底部条操作
    // 开始拖拽视图
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        contentOffsetY = scrollView.contentOffset.y
    }
    
    /**
     手指滑动屏幕开始滚动
     */
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if (scrollView.dragging) {
            if scrollView.contentOffset.y - contentOffsetY > 5.0 {
                // 向上拖拽 隐藏
                bottomBarView.snp_updateConstraints(closure: { (make) in
                    make.bottom.equalTo(44)
                })
                UIView.animateWithDuration(0.25, animations: {
                    self.view.layoutIfNeeded()
                })
            } else if contentOffsetY - scrollView.contentOffset.y > 5.0 {
                // 向下拖拽 显示
                bottomBarView.snp_updateConstraints(closure: { (make) in
                    make.bottom.equalTo(0)
                })
                UIView.animateWithDuration(0.25, animations: {
                    self.view.layoutIfNeeded()
                })
            }
            
        }
    }
    
    /**
     滚动减速结束
     */
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        // 滚动到底部后 显示
        if case let space = scrollView.contentOffset.y + SCREEN_HEIGHT - scrollView.contentSize.height where space > -5 && space < 5 {
            bottomBarView.snp_updateConstraints(closure: { (make) in
                make.bottom.equalTo(0)
            })
            UIView.animateWithDuration(0.25, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // MARK: - 网络请求
    /**
     加载
     
     - parameter classid: 当前子分类id
     - parameter id:      文章id
     */
    func loadNewsDetail(classid: String, id: String) {
        
        var parameters = [String : AnyObject]()
        
        if JFAccountModel.shareAccount().isLogin {
            parameters = [
                "table" : "news",
                "classid" : classid,
                "id" : id,
                "username" : JFAccountModel.shareAccount().username!,
                "userid" : JFAccountModel.shareAccount().id,
                "token" : JFAccountModel.shareAccount().token!,
            ]
        } else {
            parameters = [
                "table" : "news",
                "classid" : classid,
                "id" : id,
            ]
        }
        
        activityView.startAnimating()
        JFNetworkTool.shareNetworkTool.get(ARTICLE_DETAIL, parameters: parameters) { (success, result, error) -> () in
            if success == true {
                if let successResult = result {
                    
                    let content = successResult["data"]["content"].dictionaryValue
                    let dict = [
                        "title" : content["title"]!.stringValue,          // 文章标题
                        "username" : content["username"]!.stringValue,    // 用户名
                        "lastdotime" : content["lastdotime"]!.stringValue,// 最后编辑时间戳
                        "newstext" : content["newstext"]!.stringValue,    // 文章内容
                        "titleurl" : "\(BASE_URL)\(content["titleurl"]!.stringValue)", // 文章url
                        "id" : content["id"]!.stringValue,                // 文章id
                        "classid" : content["classid"]!.stringValue,      // 当前子分类id
                        "plnum" : content["plnum"]!.stringValue,          // 评论数
                        "havefava" : content["havefava"]!.stringValue     // 是否收藏  favor1
                    ]
                    
                    self.model = JFArticleDetailModel(dict: dict)
                }
            } else {
                print("error:\(error)")
            }
        }
    }
    
    // MARK: - 懒加载
    
    /// 活动指示器
    private lazy var activityView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityView.center = self.view.center
        return activityView
    }()
    
    /// webView
    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        webView.navigationDelegate = self
        webView.scrollView.scrollEnabled = false
        return webView
    }()
    
    /// 底部条
    private lazy var bottomBarView: JFNewsBottomBar = {
        let bottomBarView = NSBundle.mainBundle().loadNibNamed("JFNewsBottomBar", owner: nil, options: nil).last as! JFNewsBottomBar
        bottomBarView.delegate = self
        return bottomBarView
    }()
    
    /// 顶部条
    private lazy var topBarView: UIView = {
        let topBarView = UIView()
        topBarView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.8)
        return topBarView
    }()
    
    /// tableView
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: UITableViewStyle.Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        return tableView
    }()
}

// MARK: - JFNewsBottomBarDelegate、JFCommentCommitViewDelegate
extension JFNewsDetailViewController: JFNewsBottomBarDelegate, JFCommentCommitViewDelegate {
    
    /**
     底部返回按钮点击
     */
    func didTappedBackButton(button: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    /**
     底部编辑按钮点击
     */
    func didTappedEditButton(button: UIButton) {
        if JFAccountModel.shareAccount().isLogin {
            let commentCommitView = NSBundle.mainBundle().loadNibNamed("JFCommentCommitView", owner: nil, options: nil).last as! JFCommentCommitView
            commentCommitView.delegate = self
            commentCommitView.show()
        } else {
            presentViewController(JFLoginViewController(nibName: "JFLoginViewController", bundle: nil), animated: true, completion: {
                
            })
        }
    }
    
    /**
     底部评论按钮点击
     */
    func didTappedCommentButton(button: UIButton) {
        let commentVc = JFCommentTableViewController(style: UITableViewStyle.Plain)
        commentVc.param = articleParam
        navigationController?.pushViewController(commentVc, animated: true)
    }
    
    /**
     底部收藏按钮点击
     */
    func didTappedCollectButton(button: UIButton) {
        
        if JFAccountModel.shareAccount().isLogin {
            
            let parameters = [
                "username" : JFAccountModel.shareAccount().username!,
                "userid" : JFAccountModel.shareAccount().id,
                "token" : JFAccountModel.shareAccount().token!,
                "classid" : articleParam!.classid,
                "id" : articleParam!.id
            ]
            
            JFNetworkTool.shareNetworkTool.post(ADD_DEL_FAVA, parameters: parameters as? [String : AnyObject]) { (success, result, error) in
                if success {
                    if let successResult = result {
                        if successResult["result"]["status"].intValue == 1 {
                            // 增加成功
                            JFProgressHUD.showSuccessWithStatus("收藏成功")
                            button.selected = true
                        } else if successResult["result"]["status"].intValue == 3 {
                            // 删除成功
                            JFProgressHUD.showSuccessWithStatus("取消收藏")
                            button.selected = false
                        }
                    }
                } else {
                    print(error)
                }
            }
        } else {
            presentViewController(JFLoginViewController(nibName: "JFLoginViewController", bundle: nil), animated: true, completion: { })
        }
        
    }
    
    /**
     底部分享按钮点击
     */
    func didTappedShareButton(button: UIButton) {
        
    }
    
    /**
     点击了提交评论视图的发送按钮
     
     - parameter message: 评论信息
     */
    func didTappedSendButtonWithMessage(message: String) {
        
        let parameters = [
            "classid" : articleParam!.classid,
            "id" : articleParam!.id,
            "userid" : JFAccountModel.shareAccount().id,
            "username" : JFAccountModel.shareAccount().username!,
            "saytext" : message
        ]
        
        JFNetworkTool.shareNetworkTool.get(SUBMIT_COMMENT, parameters: parameters as? [String : AnyObject]) { (success, result, error) in
            if success {
                JFProgressHUD.showInfoWithStatus("评论成功")
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension JFNewsDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    /**
     加载webView内容
     
     - parameter model: 新闻模型
     */
    func loadWebViewContent(model: JFArticleDetailModel) {
        
        // 内容页html
        var html = ""
        html.appendContentsOf("<html>")
        html.appendContentsOf("<head>")
        html.appendContentsOf("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"/>")
        
        // css样式
        let css = "<style type=\"text/css\">" +
            ".title {" +
                "text-align: left;" +
                "font-size: 20px;" +
                "color: #3c3c3c;" +
                "font-weight: bold;" +
                "margin-left: 10px;" +
            "}" +
            ".time {" +
                "text-align: left;" +
                "font-size: 15px;" +
                "color: gray;" +
                "margin-top: 7px;" +
                "margin-bottom: 7px;" +
                "margin-left: 10px;" +
            "}" +
            ".img-responsive {" +
                "text-align: center;" +
                "margin-bottom: 10px;" +
                "width: 98%;" +
            "}" +
            ".container {" +
                "background: #FFFFFF;" +
            "}" +
            ".content {" +
                "width: 100%;" +
            "}" +
        "</style>"
        
        html.appendContentsOf(css)
        html.appendContentsOf("</head>")
        
        // body开始
        html.appendContentsOf("<body class=\"container\">")
        html.appendContentsOf("<div class=\"title\">\(model.title!)</div>")
        html.appendContentsOf("<div class=\"time\">\(model.lastdotime!.timeStampToString())</div>")
        
        // 拼接内容主体时替换图片前的缩进
        var contentString = model.newstext!.stringByReplacingOccurrencesOfString("<p style=\"text-indent: 2em; text-align: center;\"><img", withString: "<p style=\"text-align: center;\"><img")
        contentString = contentString.stringByReplacingOccurrencesOfString("<p style=\"text-indent:2em;text-align:center;\"><img", withString: "<p style=\"text-align: center;\"><img")
        contentString = contentString.stringByReplacingOccurrencesOfString("<p style=\"TEXT-ALIGN: center; TEXT-INDENT: 2em\">", withString: "<p style=\"TEXT-ALIGN: center;\">")
        contentString = contentString.stringByReplacingOccurrencesOfString("<p style=\"TEXT-ALIGN:center;TEXT-INDENT:2em\">", withString: "<p style=\"TEXT-ALIGN:center;\">")
        contentString = contentString.stringByReplacingOccurrencesOfString("<p><br /></p>", withString: "")
        
        html.appendContentsOf("<div class=\"content\">\(contentString)</div>")
        html.appendContentsOf("</body>")
        html.appendContentsOf("</html>")
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return webView.height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("detailContent")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "detailContent")
        }
        cell?.contentView.addSubview(webView)
        return cell!
    }
}

// MARK: - WKNavigationDelegate
extension JFNewsDetailViewController: WKNavigationDelegate {
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.offsetHeight") { (result, error) in
            if let height = result {
                let frame = webView.frame
                webView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, CGFloat(height as! NSNumber) + 60)
                self.tableView.reloadData()
                self.activityView.stopAnimating()
            }
        }
    }
}
