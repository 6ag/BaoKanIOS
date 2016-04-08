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

class JFPhotoTableViewController: UITableViewController, SDCycleScrollViewDelegate
{
    
    /// 分类数据 （父id, 本身id）
    var classData: (bclassid: Int, classid: Int)? {
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.registerClass(JFPhotoListCell.self, forCellReuseIdentifier: newsReuseIdentifier)
        tableView.rowHeight = 240
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(updateNewData))
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        
    }
    
    /**
     下拉加载最新数据
     */
    @objc private func updateNewData()
    {
        loadNews(classData!.bclassid, classid: classData!.classid, pageIndex: 1, method: 0)
    }
    
    /**
     上拉加载更多数据
     */
    @objc private func loadMoreData()
    {
        loadNews(classData!.bclassid, classid: classData!.classid, pageIndex: ++pageIndex, method: 1)
    }
    
    /**
     根据分类id、页码加载数据
     
     - parameter bclassid:   父类栏目id
     - parameter classid:    当前栏目id
     - parameter pageIndex:  当前页码
     - parameter method:     加载方式 0下拉加载最新 1上拉加载更多
     */
    private func loadNews(bclassid: Int, classid: Int, pageIndex: Int, method: Int)
    {
        let parameters = [
            "table" : "photo",
            "classid" : bclassid,
            "id" : classid,
            "pageIndex" : pageIndex,
        ]
        
        JFNetworkTool.shareNetworkTool.get(ARTICLE_LIST, parameters: parameters as? [String : AnyObject]) { (success, result, error) -> () in
            if success == true {
                
                if let successResult = result {
                    
                    print(result)
                    
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
                            if self.photoList.contains(postModel) == false {
                                
                                if method == 0 {
                                    // 下拉加载最新
                                    self.photoList.insert(postModel, atIndex: 0)
                                } else {
                                    // 上拉加载更多
                                    self.photoList.append(postModel)
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
        return photoList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(newsReuseIdentifier) as! JFPhotoListCell
        cell.postModel = photoList[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        // 请求文章详情数据
        let currentListModel = photoList[indexPath.row]
        let detailVc = JFPhotoDetailViewController(collectionViewLayout: UICollectionViewLayout())
        detailVc.photoParam = (currentListModel.classid!, currentListModel.id!)
        self.navigationController?.pushViewController(detailVc, animated: true)
    }
    
    
    
    
}
