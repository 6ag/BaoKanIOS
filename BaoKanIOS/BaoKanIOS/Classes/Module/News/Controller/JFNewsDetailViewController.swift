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
import Mustache

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
            
            // 更新收藏状态
            bottomBarView.collectionButton.selected = model?.havefava == "favorfill"
        }
    }
    
    /// 分享的图片url
    var sharePicUrl: String = ""
    
    /// 相关连接模型
    var otherLinks = [JFOtherLinkModel]()
    
    /// 评论模型
    var commentList = [JFCommentModel]()
    
    let detailContentIdentifier = "detailContentIdentifier"
    let detailStarAndShareIdentifier = "detailStarAndShareIdentifier"
    let detailOtherLinkIdentifier = "detailOtherLinkIdentifier"
    let detailCommentIdentifier = "detailCommentIdentifier"
    
    /// 赞分享cell
    private lazy var starAndShareCell: JFStarAndShareCell = {
        let starAndShareCell = self.tableView.dequeueReusableCellWithIdentifier(self.detailStarAndShareIdentifier) as! JFStarAndShareCell
        starAndShareCell.delegate = self
        return starAndShareCell
    }()
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: detailContentIdentifier)
        tableView.registerNib(UINib(nibName: "JFStarAndShareCell", bundle: nil), forCellReuseIdentifier: detailStarAndShareIdentifier)
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: detailOtherLinkIdentifier)
        tableView.registerNib(UINib(nibName: "JFCommentCell", bundle: nil), forCellReuseIdentifier: detailCommentIdentifier)
        
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
        loadCommentList(articleParam!.classid, id: articleParam!.id)
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
    
    /**
     点击更多评论
     */
    func didTappedmoreCommentButton(button: UIButton) -> Void {
        let commentVc = JFCommentTableViewController(style: UITableViewStyle.Plain)
        commentVc.param = articleParam
        navigationController?.pushViewController(commentVc, animated: true)
    }
    
    // MARK: - 网络请求
    /**
     加载详情
     
     - parameter classid: 当前子分类id
     - parameter id:      文章id
     */
    func loadNewsDetail(classid: String, id: String) {
        
        var parameters = [String : AnyObject]()
        
        if JFAccountModel.isLogin() {
            parameters = [
                "table" : "news",
                "classid" : classid,
                "id" : id,
                "username" : JFAccountModel.shareAccount()!.username!,
                "userid" : JFAccountModel.shareAccount()!.id,
                "token" : JFAccountModel.shareAccount()!.token!,
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
                    
                    // 相关连接
                    self.otherLinks.removeAll()
                    let otherLinks = successResult["data"]["otherLink"].array
                    if let others = otherLinks {
                        for other in others {
                            let dict = [
                                "id" : other["id"].stringValue,
                                "classid" : other["classid"].stringValue,
                                "title" : other["title"].stringValue
                            ]
                            
                            let otherModel = JFOtherLinkModel(dict: dict)
                            self.otherLinks.append(otherModel)
                        }
                    }
                    
                    // 正文数据
                    let content = successResult["data"]["content"].dictionaryValue
                    let dict = [
                        "title" : content["title"]!.stringValue,          // 文章标题
                        "username" : content["username"]!.stringValue,    // 用户名
                        "lastdotime" : content["lastdotime"]!.stringValue,// 最后编辑时间戳
                        "newstext" : content["newstext"]!.stringValue,    // 文章内容
                        "titleurl" : content["titleurl"]!.stringValue, // 文章url
                        "id" : content["id"]!.stringValue,                // 文章id
                        "classid" : content["classid"]!.stringValue,      // 当前子分类id
                        "plnum" : content["plnum"]!.stringValue,          // 评论数
                        "havefava" : content["havefava"]!.stringValue,    // 是否收藏  favor1
                        "smalltext" : content["smalltext"]!.stringValue,  // 文章简介
                        "titlepic" : content["titlepic"]!.stringValue,    // 标题图片
                        "isgood" : content["isgood"]!.stringValue,        // 赞数量
                        "befrom" : content["befrom"]!.stringValue
                    ]
                    self.model = JFArticleDetailModel(dict: dict)
                }
            } else {
                print("error:\(error)")
            }
        }
    }
    
    
    /**
     加载评论
     */
    func loadCommentList(classid: String, id: String) {
        let parameters = [
            "classid" : classid,
            "id" : id,
            "pageIndex" : 1
        ]
        
        JFNetworkTool.shareNetworkTool.get(GET_COMMENT, parameters: parameters as? [String : AnyObject]) { (success, result, error) -> () in
            
            if success {
                if let successResult = result {
                    let data = successResult["data"].arrayValue
                    if data.count == 0 && self.commentList.count == 0 {
                        return
                    }
                    
                    self.commentList.removeAll()
                    
                    for comment in data.reverse() {
                        let dict = [
                            "plstep" : comment["plstep"].intValue,
                            "plid" : comment["plid"].intValue,
                            "plusername" : comment["plusername"].stringValue,
                            "id" : comment["id"].intValue,
                            "classid" : comment["classid"].intValue,
                            "saytext" : comment["saytext"].stringValue,
                            "saytime" : comment["saytime"].stringValue,
                            "userpic" : "\(BASE_URL)\(comment["userpic"].stringValue)",
                            "zcnum" : comment["zcnum"].stringValue
                        ]
                        
                        let commentModel = JFCommentModel(dict: dict as! [String : AnyObject])
                        self.commentList.append(commentModel)
                    }
                    
                    self.tableView.reloadData()
                }
            } else {
                JFProgressHUD.showErrorWithStatus("网络不给力")
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
        webView.scrollView.delegate = self
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
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: UITableViewStyle.Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        return tableView
    }()
    
    /// 尾部退出视图
    private lazy var footerView: UIView = {
        let moreCommentButton = UIButton(frame: CGRect(x: 20, y: 0, width: SCREEN_WIDTH - 40, height: 44))
        moreCommentButton.addTarget(self, action: #selector(didTappedmoreCommentButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        moreCommentButton.setTitle("更多评论", forState: UIControlState.Normal)
        moreCommentButton.backgroundColor = NAVIGATIONBAR_RED_COLOR
        moreCommentButton.layer.cornerRadius = CORNER_RADIUS
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
        footerView.addSubview(moreCommentButton)
        return footerView
    }()
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
        html.appendContentsOf("<!doctype html>")
        html.appendContentsOf("<head>")
        html.appendContentsOf("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"/>")
        
        // css样式
        let css = "<style type=\"text/css\">" +
            ".title {" +
            "text-align: left;" +
            "font-size: 20px;" +
            "color: #3c3c3c;" +
            "font-weight: bold;" +
            "margin-left: 5px;" +
            "}" +
            ".time {" +
            "text-align: left;" +
            "font-size: 15px;" +
            "color: gray;" +
            "margin-top: 7px;" +
            "margin-bottom: 7px;" +
            "margin-left: 5px;" +
            "}" +
            ".img-responsive {" +
            "text-align: center;" +
            "max-width: 98% !important;" +
            "height: auto;" +
            "}" +
            ".container {" +
            "background: #FFFFFF;" +
            "}" +
            ".content {" +
            "width: 100%;" +
            "font-size: \(NSUserDefaults.standardUserDefaults().integerForKey(CONTENT_FONT_SIZE))px;" +
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
        
        let template = try! Template(string: html)
        let rendering = try! template.render()
        webView.loadHTMLString(rendering, baseURL: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return model == nil ? 0 : 5
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return otherLinks.count
        case 4:
            return commentList.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return webView.height
        case 1:
            return 160
        case 2:
//            return 160
            return 1
        case 3:
            return 44
        case 4:
            var rowHeight = commentList[indexPath.row].rowHeight
            if rowHeight < 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier(detailCommentIdentifier) as! JFCommentCell
                commentList[indexPath.row].rowHeight = cell.getCellHeight(commentList[indexPath.row])
                rowHeight = commentList[indexPath.row].rowHeight
            }
            return rowHeight
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(detailContentIdentifier)!
            cell.contentView.addSubview(webView)
            return cell
        case 1:
            return starAndShareCell
        case 2:
//            let cell = UITableViewCell()
//            let adImageView = UIImageView(frame: CGRect(x: 12, y: 0, width: SCREEN_WIDTH - 24, height: 160))
//            adImageView.image = UIImage(named: "temp_ad")
//            cell.contentView.addSubview(adImageView)
//            return cell
            return UITableViewCell()
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier(detailOtherLinkIdentifier)!
            cell.textLabel?.text = otherLinks[indexPath.row].title
            let separatorView = UIView(frame: CGRect(x: 0, y: 43.5, width: SCREEN_WIDTH, height: 0.5))
            separatorView.backgroundColor = UIColor(white: 0.6, alpha: 0.5)
            cell.contentView.addSubview(separatorView)
            return cell
        case 4:
            // 评论
            let cell = tableView.dequeueReusableCellWithIdentifier(detailCommentIdentifier) as! JFCommentCell
            cell.delegate = self
            cell.commentModel = commentList[indexPath.row]
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 3 || section == 4 {
            let leftRedView = UIView(frame: CGRect(x: 0, y: 0, width: 3, height: 30))
            leftRedView.backgroundColor = NAVIGATIONBAR_RED_COLOR
            
            let bgView = UIView(frame: CGRect(x: 3, y: 0, width: SCREEN_WIDTH - 3, height: 30))
            bgView.backgroundColor = UIColor(red:0.914,  green:0.890,  blue:0.847, alpha:0.3)
            
            let titleLabel = UILabel(frame: CGRect(x: 20, y: 0, width: 100, height: 30))
            
            let headerView = UIView()
            headerView.addSubview(leftRedView)
            headerView.addSubview(bgView)
            headerView.addSubview(titleLabel)
            
            if section == 3 {
                titleLabel.text = "相关新闻"
                return otherLinks.count == 0 ? nil : headerView
            } else {
                titleLabel.text = "最新评论"
                return commentList.count == 0 ? nil : headerView
            }
            
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 4 {
            return commentList.count == 0 ? nil : footerView
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 10
        case 3:
            return otherLinks.count == 0 ? 1 : 30
        case 4:
            return commentList.count == 0 ? 1 : 30
        default:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
//            return 20
            return 1
        case 3:
            return commentList.count == 0 ? 1 : 20
        case 4:
            return commentList.count == 0 ? 50 : 100
        default:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 3 {
            let otherModel = otherLinks[indexPath.row]
            let detailVc = JFNewsDetailViewController()
            detailVc.articleParam = (otherModel.classid!, otherModel.id!)
            self.navigationController?.pushViewController(detailVc, animated: true)
        }
    }
}

// MARK: - JFNewsBottomBarDelegate、JFCommentCommitViewDelegate
extension JFNewsDetailViewController: JFNewsBottomBarDelegate, JFCommentCommitViewDelegate, JFSetFontViewDelegate {
    
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
        let commentCommitView = NSBundle.mainBundle().loadNibNamed("JFCommentCommitView", owner: nil, options: nil).last as! JFCommentCommitView
        commentCommitView.delegate = self
        commentCommitView.show()
    }
    
    /**
     底部字体按钮点击 - 原来是评论
     */
    func didTappedCommentButton(button: UIButton) {
        let setFontSizeView = NSBundle.mainBundle().loadNibNamed("JFSetFontView", owner: nil, options: nil).last as! JFSetFontView
        setFontSizeView.delegate = self
        setFontSizeView.show()
    }
    
    /**
     底部收藏按钮点击
     */
    func didTappedCollectButton(button: UIButton) {
        
        if JFAccountModel.isLogin() {
            let parameters: [String : AnyObject] = [
                "username" : JFAccountModel.shareAccount()!.username!,
                "userid" : JFAccountModel.shareAccount()!.id,
                "token" : JFAccountModel.shareAccount()!.token!,
                "classid" : articleParam!.classid,
                "id" : articleParam!.id
            ]
            
            JFNetworkTool.shareNetworkTool.post(ADD_DEL_FAVA, parameters: parameters) { (success, result, error) in
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
                }
            }
        } else {
            presentViewController(JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil)), animated: true, completion: { })
        }
        
    }
    
    /**
     底部分享按钮点击
     */
    func didTappedShareButton(button: UIButton) {
        
        // 从缓存中获取标题图片
        guard let currentModel = model else {return}
        
        var image = YYImageCache.sharedCache().getImageForKey(sharePicUrl)
        if image != nil && (image?.size.width > 300 || image?.size.height > 300) {
            image = image?.resizeImageWithNewSize(CGSize(width: 300, height: 300 * image!.size.height / image!.size.width))
        }
        
        // 标题url
        let titleurl = currentModel.titleurl!.hasPrefix("http") ? currentModel.titleurl! : "\(BASE_URL)\(currentModel.titleurl!)"
        
        let shareParames = NSMutableDictionary()
        shareParames.SSDKSetupShareParamsByText(currentModel.smalltext,
                                                images : image,
                                                url : NSURL(string: titleurl),
                                                title : currentModel.title,
                                                type : SSDKContentType.Auto)
        
        let items = [
            SSDKPlatformType.TypeQQ.rawValue,
            SSDKPlatformType.TypeWechat.rawValue,
            SSDKPlatformType.TypeSinaWeibo.rawValue
        ]
        
        ShareSDK.showShareActionSheet(nil, items: items, shareParams: shareParames) { (state : SSDKResponseState, platform: SSDKPlatformType, userData : [NSObject : AnyObject]!, contentEntity :SSDKContentEntity!, error : NSError!, end: Bool) in
            switch state {
            case SSDKResponseState.Success:
                print("分享成功")
            case SSDKResponseState.Fail:
                print("分享失败,错误描述:\(error)")
            case SSDKResponseState.Cancel:
                print("取消分享")
            default:
                break
            }
        }
        
    }
    
    /**
     点击了提交评论视图的发送按钮
     
     - parameter message: 评论信息
     */
    func didTappedSendButtonWithMessage(message: String) {
        
        var parameters = [String : AnyObject]()
        
        if JFAccountModel.isLogin() {
            parameters = [
                "classid" : articleParam!.classid,
                "id" : articleParam!.id,
                "userid" : JFAccountModel.shareAccount()!.id,
                "nomember" : "0",
                "username" : JFAccountModel.shareAccount()!.username!,
                "token" : JFAccountModel.shareAccount()!.token!,
                "saytext" : message
            ]
        } else {
            parameters = [
                "classid" : articleParam!.classid,
                "id" : articleParam!.id,
                "nomember" : "1",
                "saytext" : message
            ]
        }
        
        JFNetworkTool.shareNetworkTool.get(SUBMIT_COMMENT, parameters: parameters) { (success, result, error) in
            if success {
                // 加载数据
                self.updateData()
            }
        }
    }
    
    /**
     修改了正文字体大小，需要重新显示
     */
    func didChangeFontSize() {
        loadWebViewContent(model!)
    }
}

// MARK: - WKNavigationDelegate
extension JFNewsDetailViewController: WKNavigationDelegate {
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        print("didFinishNavigation")
        webView.evaluateJavaScript("document.body.offsetHeight") { (result, error) in
            if let height = result {
                let frame = webView.frame
                webView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, CGFloat(height as! NSNumber) + 20)
                self.tableView.reloadData()
                self.activityView.stopAnimating()
            }
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return nil
    }
}

// MARK: - JFStarAndShareCellDelegate
extension JFNewsDetailViewController: JFStarAndShareCellDelegate {
    
    /**
     根据类型分享
     */
    private func shareWithType(type: SSDKPlatformType) {
        
        guard let currentModel = model else {return}
        
        var image = YYImageCache.sharedCache().getImageForKey(sharePicUrl)
        if image != nil && (image?.size.width > 300 || image?.size.height > 300) {
            image = image?.resizeImageWithNewSize(CGSize(width: 300, height: 300 * image!.size.height / image!.size.width))
        }
        
        // 标题url
        let titleurl = currentModel.titleurl!.hasPrefix("http") ? currentModel.titleurl! : "\(BASE_URL)\(currentModel.titleurl!)"
        
        let shareParames = NSMutableDictionary()
        shareParames.SSDKSetupShareParamsByText(currentModel.smalltext,
                                                images : image,
                                                url : NSURL(string: titleurl),
                                                title : currentModel.title,
                                                type : SSDKContentType.Auto)
        
        ShareSDK.share(type, parameters: shareParames) { (state : SSDKResponseState, userData : [NSObject : AnyObject]!, contentEntity :SSDKContentEntity!, error : NSError!) -> Void in
            switch state {
            case SSDKResponseState.Success:
                print("分享成功")
            case SSDKResponseState.Fail:
                print("分享失败,错误描述:\(error)")
            case SSDKResponseState.Cancel:
                print("取消分享")
            default:
                break
            }
        }
    }
    
    /**
     点击QQ
     */
    func didTappedQQButton(button: UIButton) {
        shareWithType(SSDKPlatformType.SubTypeQQFriend)
    }
    
    /**
     点击了微信
     */
    func didTappedWeixinButton(button: UIButton) {
        shareWithType(SSDKPlatformType.SubTypeWechatSession)
    }
    
    /**
     点击了朋友圈
     */
    func didTappedFriendCircleButton(button: UIButton) {
        shareWithType(SSDKPlatformType.SubTypeWechatTimeline)
    }
}

// MARK: - JFCommentCellDelegate
extension JFNewsDetailViewController: JFCommentCellDelegate {
    func didTappedStarButton(button: UIButton, commentModel: JFCommentModel) {
        button.selected = true
        
        let parameters = [
            "classid" : commentModel.classid,
            "id" : commentModel.id,
            "plid" : commentModel.plid,
            "dopl" : "1",
            "action" : "DoForPl"
        ]
        
        JFNetworkTool.shareNetworkTool.get(TOP_DOWN, parameters: parameters as? [String : AnyObject]) { (success, result, error) in
            print(result)
            JFProgressHUD.showInfoWithStatus(result!["result"]["info"].stringValue)
            if success {
                commentModel.zcnum += 1
                self.tableView.reloadData()
            }
        }
    }
}