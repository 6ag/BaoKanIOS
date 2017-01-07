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

class JFNewsTableViewController: UIViewController, SDCycleScrollViewDelegate {
    
    /// 分类数据
    var classid: Int? {
        didSet {
            loadIsGood(classid!)
            loadNews(classid!, pageIndex: 1, method: 0)
        }
    }
    
    // 当前加载页码
    var pageIndex = 1
    /// 列表模型数组
    var articleList = [JFArticleListModel]()
    /// 幻灯片模型数组
    var isGoodList = [JFArticleListModel]()
    /// 顶部轮播
    var topScrollView: SDCycleScrollView!
    
    /// 新闻cell重用标识符
    let newsNoPicCell = "newsNoPicCell"
    let newsOnePicCell = "newsOnePicCell"
    let newsThreePicCell = "newsThreePicCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
    }
    
    /**
     准备tableView
     */
    fileprivate func prepareTableView() {
        
        view.addSubview(tableView)
        view.addSubview(placeholderView)
        placeholderView.startAnimation()
        
        // 注册cell
        tableView.register(UINib(nibName: "JFNewsNoPicCell", bundle: nil), forCellReuseIdentifier: newsNoPicCell)
        tableView.register(UINib(nibName: "JFNewsOnePicCell", bundle: nil), forCellReuseIdentifier: newsOnePicCell)
        tableView.register(UINib(nibName: "JFNewsThreePicCell", bundle: nil), forCellReuseIdentifier: newsThreePicCell)
        
        // 分割线颜色
        tableView.separatorColor = UIColor(red:0.9,  green:0.9,  blue:0.9, alpha:1)
        
        // 配置上下拉刷新控件
        tableView.mj_header = setupHeaderRefresh(self, action: #selector(updateNewData))
        tableView.mj_footer = setupFooterRefresh(self, action: #selector(loadMoreData))
    }
    
    /**
     准备头部轮播
     */
    fileprivate func prepareScrollView() {
        
        topScrollView = SDCycleScrollView(frame: CGRect(x:0, y:0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT * 0.3), delegate:self, placeholderImage:UIImage(named: "photoview_image_default_white"))
        topScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight
        topScrollView.pageDotColor = NAVIGATIONBAR_RED_COLOR
        topScrollView.currentPageDotColor = UIColor.black
        
        // 过滤无图崩溃
        var images = [String]()
        var titles = [String]()
        
        for index in 0..<isGoodList.count {
            if isGoodList[index].titlepic != nil {
                images.append(isGoodList[index].titlepic!)
                titles.append(isGoodList[index].title!)
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
    
    /// 轮播图点击事件
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        
        let currentListModel = isGoodList[index]
        jumpToDetailViewControllerWith(currentListModel)
    }
    
    /**
     根据当前列表模型跳转到指定控制器
     
     - parameter currentListModel: 模型
     */
    fileprivate func jumpToDetailViewControllerWith(_ currentListModel: JFArticleListModel) {

        // 新闻内容页
        let articleDetailVc = JFNewsDetailViewController()
        articleDetailVc.articleParam = (currentListModel.classid!, currentListModel.id!)
        navigationController?.pushViewController(articleDetailVc, animated: true)
    }
    
    /**
     下拉加载最新数据
     */
    @objc fileprivate func updateNewData() {
        
        // 有网络的时候下拉会自动清除缓存
        if JFNetworkTool.shareNetworkTool.getCurrentNetworkState() != 0 {
            JFArticleListModel.cleanCache(classid!)
        }
        
        // 加载新闻列表数据
        loadNews(classid!, pageIndex: 1, method: 0)
        
        // 只有下拉的时候才去加载更新轮播图数据
        loadIsGood(classid!)
    }
    
    /**
     上拉加载更多数据
     */
    @objc fileprivate func loadMoreData() {
        pageIndex += 1
        loadNews(classid!, pageIndex: pageIndex, method: 1)
    }
    
    /**
     根据分类id加载推荐数据、作为幻灯片数据
     
     - parameter classid: 当前栏目id
     */
    fileprivate func loadIsGood(_ classid: Int) {
        
        JFArticleListModel.loadNewsList("news", classid: classid, pageIndex: pageIndex, type: 2) { (articleListModels, error) in
            
            guard let list = articleListModels, error == nil else {
                return
            }
            
            self.isGoodList = list
            
            // 更新幻灯片
            self.prepareScrollView()
        }
        
    }
    
    /**
     根据分类id、页码加载数据
     
     - parameter classid:    当前栏目id
     - parameter pageIndex:  当前页码
     - parameter method:     加载方式 0下拉加载最新 1上拉加载更多
     */
    fileprivate func loadNews(_ classid: Int, pageIndex: Int, method: Int) {
        
        JFArticleListModel.loadNewsList("news", classid: classid, pageIndex: pageIndex, type: 1) { (articleListModels, error) in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            self.placeholderView.removeAnimation()
            
            guard let list = articleListModels, error == nil else {
                return
            }
            
            if list.count == 0 {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
                
                if self.articleList.count == 0 {
                    self.placeholderView.noAnyData("还没有任何资讯")
                }
                return
            }
            
            // id越大，文章越新
            let minId = self.articleList.last?.id ?? "0"
            
            // 新数据里最大的id
            let newMaxId = Int(list[0].id!)!
            
            if method == 0 {
                self.articleList = list
                self.tableView.reloadData()
            } else {
                // 1上拉加载更多 - 拼接数据
                if Int(minId)! > newMaxId {
                    self.articleList = self.articleList + list
                    self.tableView.reloadData()
                } else {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
            }
            
        }
        
    }
    
    /// 内容区域
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 104), style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.separatorColor = UIColor(red:0.9,  green:0.9,  blue:0.9, alpha:1)
        return tableView
    }()
    
    /// 没有内容的时候的占位图
    fileprivate lazy var placeholderView: JFPlaceholderView = {
        let placeholderView = JFPlaceholderView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 104))
        placeholderView.backgroundColor = UIColor.white
        return placeholderView
    }()
    
}

// MARK: - UITableViewDelegate UITableViewDatasource
extension JFNewsTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let postModel = articleList[indexPath.row]
        if postModel.titlepic == "" { // 无图
            if postModel.rowHeight == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: newsNoPicCell) as! JFNewsNoPicCell
                let height = cell.getRowHeight(postModel)
                postModel.rowHeight = height
            }
            return postModel.rowHeight
        } else if postModel.morepic?.count == 0 { // 单图
            return 96
        } else { // 多图
            if postModel.rowHeight == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: newsThreePicCell) as! JFNewsThreePicCell
                let height = cell.getRowHeight(postModel)
                postModel.rowHeight = height
            }
            return postModel.rowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let postModel = articleList[indexPath.row]
        
        if postModel.titlepic == "" { // 无图
            let cell = tableView.dequeueReusableCell(withIdentifier: newsNoPicCell) as! JFNewsNoPicCell
            cell.postModel = postModel
            return cell
        } else if postModel.morepic?.count == 0 { // 单图
            let cell = tableView.dequeueReusableCell(withIdentifier: newsOnePicCell) as! JFNewsOnePicCell
            cell.postModel = postModel
            return cell
        } else { // 多图
            let cell = tableView.dequeueReusableCell(withIdentifier: newsThreePicCell) as! JFNewsThreePicCell
            cell.postModel = postModel
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 取消cell选中状态
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 跳转控制器
        let currentListModel = articleList[indexPath.row]
        jumpToDetailViewControllerWith(currentListModel)
    }
    
}
