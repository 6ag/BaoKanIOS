//
//  JFNewsDetailViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/2/19.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

class JFNewsDetailViewController: UIViewController, UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource, JFNewsBottomBarDelegate
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
    
    /// 其他文章连接
    var otherLinks = [[String : String]]()
    
    /// tableView
    @IBOutlet weak var tableView: UITableView!
    
    /// 底部条
    var bottomBarView: JFNewsBottomBar!
    /// 顶部条
    var topBarView: UIView!
    
    var contentOffsetY: CGFloat = 0.0
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
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
    
    func didTappedBackButton(button: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func didTappedEditButton(button: UIButton) {
        
    }
    
    func didTappedCollectButton(button: UIButton) {
        
    }
    
    func didTappedShareButton(button: UIButton) {
        
    }
    
    func didTappedFontButton(button: UIButton) {
        
    }
    
    // MARK: - UITableView委托
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return otherLinks.count
        default:
            break
        }
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return webView.height
        case 1:
            return 180
        case 2:
            return 60
        default:
            break
        }
        return 0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            var cell = tableView.dequeueReusableCellWithIdentifier("detailContent")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "detailContent")
            }
            cell?.contentView.addSubview(webView)
            return cell!
        case 1:
            var cell = tableView.dequeueReusableCellWithIdentifier("detailAD") as? JFDetailADCell
            if cell == nil {
                cell = JFDetailADCell(style: UITableViewCellStyle.Default, reuseIdentifier: "detailAD")
            }
            return cell!
        case 2:
            var cell = tableView.dequeueReusableCellWithIdentifier("detailOther") as? JFDetailOtherCell
            if cell == nil {
                cell = JFDetailOtherCell(style: UITableViewCellStyle.Default, reuseIdentifier: "detailOther")
            }
            cell?.data = otherLinks[indexPath.row]
            return cell!
        default:
            break
        }
        return UITableViewCell()
    }
    
    // MARK: - 网络请求
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
        html.appendContentsOf("<body style=\"background:#F6F6F6\">")
        html.appendContentsOf("<div class=\"title\">\(model.title!)</div>")
        html.appendContentsOf("<div class=\"time\">\(model.lastdotime!.timeStampToString())</div>")
        
        // 拼接内容主体时替换图片前的缩进
        html.appendContentsOf("<div class=\"container\">\(model.newstext!.stringByReplacingOccurrencesOfString("<p style=\"text-indent: 2em; text-align: center;\"><img", withString: "<p style=\"text-align: center;\"><img"))</div>")
        html.appendContentsOf("</body>")
        
        html.appendContentsOf("</html>")
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    /**
     webView加载完成回调
     
     - parameter webView: 加载完成的webView
     */
    func webViewDidFinishLoad(webView: UIWebView) {
        
        var frame = webView.frame
        frame.size.height = webView.scrollView.contentSize.height
        webView.frame = frame
        webView.scrollView.scrollEnabled = false
        tableView.reloadData()
    }
    
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
                    
                    let otherLink = successResult["data"]["otherLink"].arrayValue
                    for link in otherLink {
                        
                        var dict = [
                            "classid" : link["classid"].string!,
                            "id" : link["id"].string!,
                            "title" : link["title"].string!
                        ]
                        
                        // 标题图片不一定有值
                        if let titlepic = link["titlepic"].string {
                            if titlepic != "" {
                                dict["titlepic"] = "\(BASE_URL)\(titlepic)"
                            } else {
                                dict["titlepic"] = "\(BASE_URL)\(link["notimg"].string!)"
                            }
                            
                        }
                        
                        // 将字典添加到其他连接数组里，懒得搞模型
                        self.otherLinks.append(dict)
                        
                        //                        print(self.otherLinks)
                    }
                    
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
        return webView
    }()
    
}
