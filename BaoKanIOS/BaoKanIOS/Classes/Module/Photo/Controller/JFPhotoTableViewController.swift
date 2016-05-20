//
//  JFPhotoTableViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/1.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import SDCycleScrollView
import MJRefresh

class JFPhotoTableViewController: UITableViewController, SDCycleScrollViewDelegate {
    
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
    var photoList: [JFArticleListModel] = []
    
    /// 新闻cell重用标识符
    let newsReuseIdentifier = "newsReuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(JFPhotoListCell.self, forCellReuseIdentifier: newsReuseIdentifier)
        tableView.rowHeight = 200
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(updateNewData))
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        
    }
    
    /**
     下拉加载最新数据
     */
    @objc private func updateNewData() {
        loadNews(classid!, pageIndex: 1, method: 0)
    }
    
    /**
     上拉加载更多数据
     */
    @objc private func loadMoreData() {
        pageIndex += 1
        loadNews(classid!, pageIndex: pageIndex, method: 1)
    }
    
    /**
     根据分类id、页码加载数据
     
     - parameter classid:    当前栏目id
     - parameter pageIndex:  当前页码
     - parameter method:     加载方式 0下拉加载最新 1上拉加载更多
     */
    private func loadNews(classid: Int, pageIndex: Int, method: Int) {
        let parameters = [
            "table" : "photo",
            "classid" : classid,
            "pageIndex" : pageIndex,
            ]
        
        JFNetworkTool.shareNetworkTool.get(ARTICLE_LIST, parameters: parameters as? [String : AnyObject]) { (success, result, error) -> () in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            if success == true {
                if let successResult = result {
                    
//                    print(successResult)
                    
                    let minId = self.photoList.last?.id ?? "0"
                    let maxId = self.photoList.first?.id ?? "0"
                    
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
                            
                            if method == 0 {
                                if Int(maxId) < Int(postModel.id!) {
                                    self.photoList.insert(postModel, atIndex: 0)
                                }
                            } else {
                                if Int(minId) > Int(postModel.id!) {
                                    self.photoList.append(postModel)
                                }
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
        return photoList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(newsReuseIdentifier) as! JFPhotoListCell
        cell.postModel = photoList[indexPath.row]
        cell.cellHeight = 200
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 请求文章详情数据
        let currentListModel = photoList[indexPath.row]
        let detailVc = JFPhotoDetailViewController()
        detailVc.photoParam = (currentListModel.classid!, currentListModel.id!)
        navigationController?.pushViewController(detailVc, animated: true)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as! JFPhotoListCell).cellOffset()
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let array = tableView.visibleCells
        for cell in array {
            // 里面的图片跟随移动
            (cell as! JFPhotoListCell).cellOffset()
        }
        
    }
    
}
