//
//  JFNewsDetailViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/2/19.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

class JFNewsDetailViewController: UIViewController, UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource
{
    /// 文章详情请求参数
    var articleParam: (classid: String, id: String)? {
        didSet {
            loadNewsDetail(articleParam!.classid, id: articleParam!.id)
        }
    }
    
    /// 其他文章连接
    var otherLinks = [[String : String]]()
    
    /// 详情页面模型
    var model: JFArticleDetailModel? {
        didSet {
            // 更新页面数据
            loadWebViewContent(model!)
        }
    }
    
    /// tableView
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 5
        default:
            break
        }
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        switch indexPath.section {
        case 0:
            var cell = tableView.dequeueReusableCellWithIdentifier("detailContent")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "detailContent")
            }
            cell?.contentView.addSubview(webView)
            return cell!
        case 1:
            let adButton = UIButton(type: UIButtonType.Custom)
            adButton.setBackgroundImage(UIImage(named: "detail_ad_banner"), forState: UIControlState.Normal)
            var cell = tableView.dequeueReusableCellWithIdentifier("detailAD")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "detailAD")
            }
            cell?.contentView.addSubview(adButton)
            adButton.snp_makeConstraints(closure: { (make) -> Void in
                make.edges.equalTo(UIEdgeInsets(top: 10, left: 10, bottom: -40, right: -10))
            })
            return cell!
        case 2:
            var cell = tableView.dequeueReusableCellWithIdentifier("detailHot") as? JFDetailOtherCell
            if cell == nil {
                cell = JFDetailOtherCell(style: UITableViewCellStyle.Default, reuseIdentifier: "detailHot")
            }
            cell?.data = otherLinks[indexPath.row]
            return cell!
        default:
            break
        }
        return UITableViewCell()
    }
    
    /**
     加载webView内容
     
     - parameter model: 新闻模型
     */
    func loadWebViewContent(model: JFArticleDetailModel)
    {
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
        html.appendContentsOf("<div class=\"container\">\(model.newstext!)</div>")
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
    func loadNewsDetail(classid: String, id: String)
    {
        let parameters = [
            "table" : "news",
            "classid" : classid,
            "id" : id,
        ]
        
        JFNetworkTool.shareNetworkTool.get(ARTICLE_DETAIL, parameters: parameters) { (success, result, error) -> () in
            if success == true {
                if let successResult = result {
                    
//                    print(successResult)
                    
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
                        
                        print( self.otherLinks)
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
    
    /// webView
    lazy var webView: UIWebView = {
        let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        webView.delegate = self
        return webView
    }()
    
}
