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

class JFNewsDetailViewController: UIViewController
{
    // MARK: - 属性
    /// 文章详情请求参数
    var articleParam: (classid: String, id: String)? {
        didSet {
            loadNewsDetail(articleParam!.classid, id: articleParam!.id)
        }
    }
    
    /// 详情页面模型
    var model: JFArticleDetailModel? {
        didSet {
            // 更新页面数据
            loadWebViewContent(model!)
        }
    }
    
    /// 底部条
    var bottomBarView: JFNewsBottomBar!
    /// 顶部条
    var topBarView: UIView!
    
    var contentOffsetY: CGFloat = 0.0
    
    /// tableView
    var tableView: UITableView!
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: UITableViewStyle.Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.addSubview(tableView)
        
        view.backgroundColor = UIColor.whiteColor()
        topBarView = UIView()
        topBarView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.8)
        view.addSubview(topBarView)
        
        topBarView.snp_makeConstraints { (make) in
            make.left.right.top.equalTo(0)
            make.height.equalTo(20)
        }
        
        // 创建BottomBar
        bottomBarView = NSBundle.mainBundle().loadNibNamed("JFNewsBottomBar", owner: nil, options: nil).last as! JFNewsBottomBar
        view.addSubview(bottomBarView)
        
        bottomBarView.delegate = self
        bottomBarView.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(44)
        }
        
        self.view.bringSubviewToFront(self.topBarView)
        self.view.bringSubviewToFront(self.bottomBarView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        topBarView.removeFromSuperview()
    }
    
    // MARK: - 底部条操作
    // 开始拖拽视图
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        contentOffsetY = scrollView.contentOffset.y
    }
    
    // 手指离开屏幕开始滚动
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
    
    // 滚动减速结束
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
        let parameters = [
            "table" : "news",
            "classid" : classid,
            "id" : id,
            ]
        
        JFNetworkTool.shareNetworkTool.get(ARTICLE_DETAIL, parameters: parameters) { (success, result, error) -> () in
            if success == true {
                if let successResult = result {
                    
                    print(successResult)
                    
                    let content = successResult["data"]["content"].dictionaryValue
                    let dict = [
                        "title" : content["title"]!.string!,          // 文章标题
                        "username" : content["username"]!.string!,    // 用户名
                        "lastdotime" : content["lastdotime"]!.string!,// 最后编辑时间戳
                        "newstext" : content["newstext"]!.string!,    // 文章内容
                        "titleurl" : "\(BASE_URL)\(content["titleurl"]!.string!)", // 文章url
                        "id" : content["id"]!.string!,                // 文章id
                        "classid" : content["classid"]!.string!,      // 当前子分类id
                    ]
                    
                    self.model = JFArticleDetailModel(dict: dict)
                    
                }
            } else {
                print("error:\(error)")
            }
        }
    }
    
    // MARK: - 懒加载
    /// webView
    lazy var webView: UIWebView = {
        let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        webView.delegate = self
        
        // 禁止滚动
        let scrollView = webView.subviews[0] as! UIScrollView
        scrollView.scrollEnabled = false
        return webView
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
        print(message)
        
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

// MARK: - UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource
extension JFNewsDetailViewController: UIWebViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    /**
     加载webView内容
     
     - parameter model: 新闻模型
     */
    func loadWebViewContent(model: JFArticleDetailModel) {
        // 内容页html
        var html = ""
        html.appendContentsOf("<html>")
        html.appendContentsOf("<head>")
        html.appendContentsOf("<link rel=\"stylesheet\" href=\"\(NSBundle.mainBundle().URLForResource("style.css", withExtension: nil)!)\">")
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
    
    /**
     webView加载完成回调
     
     - parameter webView: 加载完成的webView
     */
    func webViewDidFinishLoad(webView: UIWebView) {
        
        let height = Int(webView.stringByEvaluatingJavaScriptFromString("document.body.offsetHeight")!)! + 60
        let frame = webView.frame
        webView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, CGFloat(height))
        tableView.reloadData()
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
