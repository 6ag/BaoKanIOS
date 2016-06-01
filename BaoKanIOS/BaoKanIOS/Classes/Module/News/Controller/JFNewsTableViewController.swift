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
    
    /// 分类数据
    var classid: Int? {
        didSet {
            if pageIndex == 1 {
                tableView.mj_header.beginRefreshing()
            }
        }
    }
    
    // 页码
    var pageIndex = 1
    
    /// 模型数组
    var articleList = [JFArticleListModel]()
    
    /// 新闻cell重用标识符
    let newsNoPicCell = "newsNoPicCell"
    let newsOnePicCell = "newsOnePicCell"
    let newsThreePicCell = "newsThreePicCell"
    
    /// 顶部轮播
    var topScrollView: SDCycleScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "JFNewsNoPicCell", bundle: nil), forCellReuseIdentifier: newsNoPicCell)
        tableView.registerNib(UINib(nibName: "JFNewsOnePicCell", bundle: nil), forCellReuseIdentifier: newsOnePicCell)
        tableView.registerNib(UINib(nibName: "JFNewsThreePicCell", bundle: nil), forCellReuseIdentifier: newsThreePicCell)
        tableView.separatorColor = UIColor(red:0.9,  green:0.9,  blue:0.9, alpha:1)
        
        let headerRefresh = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(updateNewData))
        headerRefresh.lastUpdatedTimeLabel.hidden = true
        tableView.mj_header = headerRefresh
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
    }
    
    /**
     准备头部轮播
     */
    private func prepareScrollView() {
        
        topScrollView = SDCycleScrollView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 150), delegate: self, placeholderImage: UIImage(named: "photoview_image_default_white"))
        topScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight
        topScrollView.pageDotColor = NAVIGATIONBAR_WHITE_COLOR
        topScrollView.currentPageDotColor = NAVIGATIONBAR_RED_COLOR
        
        // 过滤无图崩溃
        var images = [String]()
        var titles = [String]()
        
        if articleList.count < 3 {
            return
        }
        for index in 0...2 {
            if articleList[index].titlepic != nil {
                images.append(articleList[index].titlepic!)
                titles.append(articleList[index].title!)
            }
        }
        if images.count == 0 {
            return
        }
        
        topScrollView.imageURLStringsGroup = images
        topScrollView.titlesGroup = titles
        topScrollView.autoScrollTimeInterval = 5
        tableView.tableHeaderView = topScrollView
    }
    
    func cycleScrollView(cycleScrollView: SDCycleScrollView!, didSelectItemAtIndex index: Int) {
        
        let currentListModel = articleList[index]
        let detailVc = JFNewsDetailViewController()
        detailVc.articleParam = (currentListModel.classid!, currentListModel.id!)
        self.navigationController?.pushViewController(detailVc, animated: true)
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
        
        var parameters: [String : AnyObject]
        if classid == 10000 {
            parameters = [
            "pageIndex" : pageIndex
            ]
        } else {
            parameters = [
            "classid" : classid,
            "pageIndex" : pageIndex
            ]
        }
        
        JFNetworkTool.shareNetworkTool.get(ARTICLE_LIST, parameters: parameters) { (success, result, error) -> () in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            if success == true {
                if let successResult = result {
//                    print(successResult)
                    let data = successResult["data"][0].arrayValue.reverse()
                    
                    let minId = self.articleList.last?.id ?? "0"
                    let maxId = self.articleList.first?.id ?? "0"
                    
                    for article in data {
                        var dict: [String : AnyObject] = [
                            "title" : article["title"].stringValue,          // 文章标题
                            "bclassid" : article["bclassid"].stringValue,    // 终极栏目id
                            "classid" : article["classid"].stringValue,      // 当前子分类id
                            "newstime" : article["newstime"].stringValue,    // 发布时间
                            "created_at" : article["created_at"].stringValue,// 创建文章时间戳
                            "username" : article["username"].stringValue,    // 用户名
                            "onclick" : article["onclick"].stringValue,      // 点击量
                            "smalltext" : article["smalltext"].stringValue,  // 简介
                            "id" : article["id"].stringValue,                // 文章id
                            "classname" : article["classname"].stringValue,  // 分类名称
                            "table" : article["table"].stringValue,          // 数据表名
                            "plnum" : article["plnum"].stringValue,          // 评论数量
                        ]
                        
                        // 判断是否有标题图片
                        if article["titlepic"].string != "" {
                            
                            var titlepicUrl = article["titlepic"].stringValue
                            // 判断url是否包含前缀
                            titlepicUrl = titlepicUrl.hasPrefix("http") ? titlepicUrl : "\(BASE_URL)\(titlepicUrl)"
                            dict["titlepic"] = titlepicUrl
                            
                            // 标题多图
                            let morepics = article["morepic"].array
                            if let morepic = morepics {
                                var morepicArray = [String]()
                                for picdict in morepic {
                                    var bigpicUrl = picdict["bigpic"].stringValue
                                    // 判断url是否包含前缀
                                    bigpicUrl = bigpicUrl.hasPrefix("http") ? bigpicUrl : "\(BASE_URL)\(bigpicUrl)"
                                    morepicArray.append(bigpicUrl)
                                }
                                dict["morepic"] = morepicArray
                                dict["piccount"] = 3
                            } else {
                                dict["piccount"] = 1
                            }
                        } else {
                            dict["piccount"] = 0
                        }
                        
                        // 字典转模型
                        let postModel = JFArticleListModel(dict: dict)
                        
                        // 根据加载方式拼接数据
                        if method == 0 {
                            if Int(maxId) < Int(postModel.id!) {
                                if self.articleList.count >= 3 || postModel.piccount != 0 {
                                    self.articleList.insert(postModel, atIndex: 0)
                                }
                            }
                        } else {
                            if Int(minId) > Int(postModel.id!) {
                                if self.articleList.count >= 3 || postModel.piccount != 0 {
                                    self.articleList.append(postModel)
                                }
                            }
                        }
                        
                    }
                    
                    self.tableView.reloadData()
                    self.prepareScrollView()
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
        if articleList.count >= 3 {
            return articleList.count - 3
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if articleList.count >= 3 {
            let postModel = articleList[indexPath.row + 3]
            if postModel.piccount == 0 {
                if postModel.rowHeight == 0 {
                    let cell = tableView.dequeueReusableCellWithIdentifier(newsNoPicCell) as! JFNewsNoPicCell
                    let height = cell.getRowHeight(postModel)
                    postModel.rowHeight = height
                }
                return postModel.rowHeight
            } else if postModel.piccount == 1 {
                // 单图的高度固定
                return 96
            } else if postModel.piccount == 3 {
                if postModel.rowHeight == 0 {
                    let cell = tableView.dequeueReusableCellWithIdentifier(newsThreePicCell) as! JFNewsThreePicCell
                    let height = cell.getRowHeight(postModel)
                    postModel.rowHeight = height
                }
                return postModel.rowHeight
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if articleList.count >= 3 {
            let postModel = articleList[indexPath.row + 3]
            if postModel.piccount == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier(newsNoPicCell) as! JFNewsNoPicCell
                cell.postModel = postModel
                return cell
            } else if postModel.piccount == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier(newsOnePicCell) as! JFNewsOnePicCell
                cell.postModel = postModel
                return cell
            } else if postModel.piccount == 3 {
                let cell = tableView.dequeueReusableCellWithIdentifier(newsThreePicCell) as! JFNewsThreePicCell
                cell.postModel = postModel
                return cell
            }
            
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if articleList.count >= 3 {
            let currentListModel = articleList[indexPath.row + 3]
            let detailVc = JFNewsDetailViewController()
            
            // 传递分享需要的图片连接
            if currentListModel.piccount == 3 {
                detailVc.sharePicUrl = currentListModel.morepic![0]
            } else if currentListModel.piccount == 1 {
                detailVc.sharePicUrl = currentListModel.titlepic!
            }
            
            detailVc.articleParam = (currentListModel.classid!, currentListModel.id!)
            self.navigationController?.pushViewController(detailVc, animated: true)
        }
        
    }
    
}
