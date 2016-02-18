//
//  JFNewsTableViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/1.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import SDCycleScrollView
import MJRefresh

class JFNewsTableViewController: UITableViewController, SDCycleScrollViewDelegate {
    
    /// 分类数据 （父id, 本身id）
    var classData: (classid: Int, id: Int)? {
        didSet {
            loadNews(classData!.classid, id: classData!.id, pageIndex: 1)
        }
    }
    
    /// 模型数组
    var postArray: [JFArticleModel] = []
    
    /// 新闻cell重用标识符
    let newsReuseIdentifier = "newsReuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(JFNewsCell.self, forCellReuseIdentifier: newsReuseIdentifier)
        tableView.rowHeight = 100
        prepareScrollView()
        
    }
    
    /**
     准备头部轮播
     */
    private func prepareScrollView() {
        let scrollView = SDCycleScrollView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 150), delegate: self, placeholderImage: UIImage(named: "photoview_image_default_white"))
        scrollView.currentPageDotColor = UIColor.redColor()
        scrollView.pageDotColor = UIColor.blackColor()
        scrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight
        scrollView.imageURLStringsGroup = ["http://file.ynet.com/2/1601/14/10731063.jpg", "http://file.ynet.com/2/1601/14/10731063.jpg", "http://file.ynet.com/2/1601/14/10731063.jpg"]
        scrollView.titlesGroup = ["测试轮播标题1", "测试轮播标题2", "测试轮播标题3"]
        scrollView.autoScrollTimeInterval = 5
        tableView.tableHeaderView = scrollView
    }
    
    func cycleScrollView(cycleScrollView: SDCycleScrollView!, didSelectItemAtIndex index: Int) {
        print("点击了第\(index)张图")
    }
    
    /**
     根据分类id、页码加载数据
     
     - parameter classid:   分类id
     - parameter pageIndex: 页码
     */
    private func loadNews(classid: Int, id: Int, pageIndex: Int) {
        
        let parameters = [
            "table" : "news",
            "classid" : classid,
            "id" : id,
            "pageIndex" : pageIndex
        ]
        
        JFProgressHUD.showWithStatus("正在加载")
        JFNetworkTool.shareNetworkTool.get("http://www.baokan.name/e/api/getNewsList.php", parameters: parameters as? [String : AnyObject]) { (success, result, error) -> () in
            JFProgressHUD.dismiss()
            if success == true {
                
                if let successResult = result {
                    print(successResult)
                    
                    let data = successResult["data"][0].arrayValue
                    
                    for article in data {
                        
                        var dict = [
                            "title" : article["title"].string!,          // 文章标题
                            "bclassid" : article["bclassid"].string!,    // 终极栏目id
                            "classid" : article["classid"].string!,      // 当前子分类
                            "newstime" : article["newstime"].string!,    // 发布时间
                            "created_at" : article["created_at"].string!,// 创建文章时间戳
                            "username" : article["username"].string!,    // 用户名
                            "onclick" : article["onclick"].string!,      // 点击量
                            "smalltext" : article["smalltext"].string!,  // 简介
                            "id" : article["id"].string!,                // 文章id
                            "classname" : article["classname"].string!,  // 分类名称
                            "table" : article["table"].string!,          // 数据表名
                            "titleurl" : "\(BASE_URL)\(article["titleurl"].string!)", // 文章url
                        ]
                        
                        // 标题图片可能无值
                        if article["titlepic"].string != nil {
                            dict["titlepic"] = article["titlepic"].string!
                            
                            let postModel = JFArticleModel(dict: dict)
                            
                            // 如果字典中不包含模型对象才存入
                            if self.postArray.contains(postModel) == false {
                                self.postArray.append(postModel)
                            }
                            
                        } else {
                            // 如果无图，就跳过
                            continue
                        }
                        
                    }
                    
                    // 刷新表格
                    self.tableView.reloadData()
                    
                } else {
                    print("error:\(error)")
                }
                
            }
        }
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(newsReuseIdentifier) as! JFNewsCell
        
        cell.postModel = postArray[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
    
}
