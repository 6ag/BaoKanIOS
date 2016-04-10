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

class JFNewsTableViewController: UITableViewController, SDCycleScrollViewDelegate
{
    
    /// 分类数据
    var classid: Int? {
        didSet {
            if pageIndex == 1 {
                tableView.mj_header.beginRefreshing()
            }
        }
    }
    
    // 页码
    var pageIndex = 1;
    
    /// 模型数组
    var articleList: [JFArticleListModel] = []
    
    /// 新闻cell重用标识符
    let newsReuseIdentifier = "newsReuseIdentifier"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.registerClass(JFNewsCell.self, forCellReuseIdentifier: newsReuseIdentifier)
        tableView.rowHeight = 100
        prepareScrollView()
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(updateNewData))
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        
    }
    
    /**
     准备头部轮播
     */
    private func prepareScrollView()
    {
        let scrollView = SDCycleScrollView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 150), delegate: self, placeholderImage: UIImage(named: "photoview_image_default_white"))
        scrollView.currentPageDotColor = UIColor.redColor()
        scrollView.pageDotColor = UIColor.blackColor()
        scrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight
        scrollView.imageURLStringsGroup = ["http://file.ynet.com/2/1601/14/10731063.jpg", "http://file.ynet.com/2/1601/14/10731063.jpg", "http://file.ynet.com/2/1601/14/10731063.jpg"]
        scrollView.titlesGroup = ["测试轮播标题1", "测试轮播标题2", "测试轮播标题3"]
        scrollView.autoScrollTimeInterval = 5
        tableView.tableHeaderView = scrollView
    }
    
    func cycleScrollView(cycleScrollView: SDCycleScrollView!, didSelectItemAtIndex index: Int)
    {
        print("点击了第\(index)张图")
    }
    
    /**
     下拉加载最新数据
     */
    @objc private func updateNewData()
    {
        loadNews(classid!, pageIndex: 1, method: 0)
    }
    
    /**
     上拉加载更多数据
     */
    @objc private func loadMoreData()
    {
        loadNews(classid!, pageIndex: ++pageIndex, method: 1)
    }
    
    /**
     根据分类id、页码加载数据
     
     - parameter classid:    当前栏目id
     - parameter pageIndex:  当前页码
     - parameter method:     加载方式 0下拉加载最新 1上拉加载更多
     */
    private func loadNews(classid: Int, pageIndex: Int, method: Int)
    {
        let parameters = [
            "table" : "news",
            "classid" : classid,
            "pageIndex" : pageIndex
        ]
        
        JFNetworkTool.shareNetworkTool.get(ARTICLE_LIST, parameters: parameters as? [String : AnyObject]) { (success, result, error) -> () in
            if success == true {
                if let successResult = result {
                    
//                    print(result)
                    
                    let data = successResult["data"][0].arrayValue.reverse()
                    
                    for article in data {
                        
                        var dict = [
                            "title" : article["title"].string!,          // 文章标题
                            "bclassid" : article["bclassid"].string!,    // 终极栏目id
                            "classid" : article["classid"].string!,      // 当前子分类id
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
                        if article["titlepic"].string != "" {
                            dict["titlepic"] = article["titlepic"].string!
                            
                            let postModel = JFArticleListModel(dict: dict)
                            
                            // 如果字典中不包含模型对象才存入
                            if self.articleList.contains(postModel) == false {
                                
                                if method == 0 {
                                    // 下拉加载最新
                                    self.articleList.insert(postModel, atIndex: 0)
                                    
                                } else {
                                    // 上拉加载更多
                                    self.articleList.append(postModel)
                                }
                                
                            }
                            
                        } else {
                            // 如果无图，就跳过
                            continue
                        }
                        
                    }
                    
                    self.tableView.mj_header.endRefreshing()
                    self.tableView.mj_footer.endRefreshing()
                    
                    // 刷新表格
                    self.tableView.reloadData()
                    
                } else {
                    print("error:\(error)")
                }
                
            }
        }
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return articleList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(newsReuseIdentifier) as! JFNewsCell
        cell.postModel = articleList[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // 请求文章详情数据
        let currentListModel = articleList[indexPath.row]
        let detailVc = JFNewsDetailViewController()
        detailVc.articleParam = (currentListModel.classid!, currentListModel.id!)
        self.navigationController?.pushViewController(detailVc, animated: true)
    }
    
    
    
    
}
