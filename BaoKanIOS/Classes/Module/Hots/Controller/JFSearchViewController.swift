//
//  JFSearchViewController.swift
//  LiuAGeIOS
//
//  Created by zhoujianfeng on 16/6/24.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFSearchViewController: UIViewController {

    // 当前加载页码
    var pageIndex = 0
    /// 列表模型数组
    var articleList = [JFArticleListModel]()
    
    /// 新闻cell重用标识符 无图、单图、三图
    let newsNoPicCell = "newsNoPicCell"
    let newsOnePicCell = "newsOnePicCell"
    let newsThreePicCell = "newsThreePicCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = BACKGROUND_COLOR
        navigationItem.titleView = searchTextField
        UIApplication.shared.keyWindow?.addSubview(searchKeyboardTableView)
        searchKeyboardTableView.snp.makeConstraints { (make) in
            make.left.equalTo(70)
            make.top.equalTo(57)
            make.right.equalTo(-SCREEN_WIDTH * 0.05)
            make.height.equalTo(0)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = NAVIGATIONBAR_WHITE_COLOR
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchTextField.endEditing(true)
        self.searchKeyboardTableView.snp.updateConstraints({ (make) in
            make.height.equalTo(0)
        })
        super.viewWillDisappear(animated)
    }
    
    deinit {
        searchKeyboardTableView.removeFromSuperview()
    }

    /**
     准备tableView
     */
    fileprivate func prepareTableView() {
        
        view.addSubview(tableView)
        view.addSubview(placeholderView)
        placeholderView.startAnimation()
    }
    
    /**
     上拉加载更多数据
     */
    @objc fileprivate func loadMoreData() {
        pageIndex += 1
        loadSearchResult(searchTextField.text!, pageIndex: pageIndex)
    }
    
    /**
     加载搜索结果
     
     - parameter keyboard:  关键词
     - parameter pageIndex: 页码
     */
    fileprivate func loadSearchResult(_ keyboard: String, pageIndex: Int) {
        
        JFArticleListModel.loadSearchResult(keyboard, pageIndex: pageIndex) { (searchResultModels, error) in
            
            self.tableView.mj_footer.endRefreshing()
            
            guard let list = searchResultModels else {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            
            if error != nil {
                return
            }
            
            if list.count == 0 {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
                if self.articleList.count == 0 {
                    self.placeholderView.noAnyData("没有搜索到任何内容")
                }
                return
            }
            
            // id越大，文章越新
            let minId = self.articleList.last?.id ?? "0"
            
            // 新数据里最大的id
            let newMaxId = Int(list[0].id!)!

            if Int(minId)! > newMaxId {
                self.articleList = self.articleList + list
            } else {
                self.articleList = list
            }
            
            self.placeholderView.removeAnimation()
            self.tableView.reloadData()
        }
        
    }
    
    /**
     加载关键词列表
     
     - parameter keyboard: 关键词
     */
    fileprivate func loadSearchKeyboardList(_ keyboard: String) {
        
        JFSearchKeyboardModel.loadSearchKeyList(keyboard) { (searchKeyboardModels, error) in
            
            guard let list = searchKeyboardModels else {
                self.searchKeyboardTableView.snp.updateConstraints({ (make) in
                    make.height.equalTo(0)
                })
                return
            }
            
            if error != nil {
                return
            }
            
            self.searchKeyboardTableView.searchKeyboardmodels = list
            
            // 更新高度
            self.searchKeyboardTableView.snp.updateConstraints({ (make) in
                make.height.equalTo(list.count * 44)
            })
            
        }
    }
    
    /**
     根据当前列表模型跳转到指定控制器
     
     - parameter currentListModel: 模型
     */
    fileprivate func jumpToDetailViewControllerWith(_ currentListModel: JFArticleListModel) {
        
        // 如果是多图就跳转到图片浏览器
        if currentListModel.morepic?.count == 3 {
            let photoDetailVc = JFPhotoDetailViewController()
            photoDetailVc.photoParam = (currentListModel.classid!, currentListModel.id!)
            navigationController?.pushViewController(photoDetailVc, animated: true)
        } else {
            let articleDetailVc = JFNewsDetailViewController()
            articleDetailVc.articleParam = (currentListModel.classid!, currentListModel.id!)
            navigationController?.pushViewController(articleDetailVc, animated: true)
        }
    }
    
    /// 搜索框
    fileprivate lazy var searchTextField: UISearchBar = {
        let searchTextField = UISearchBar(frame: CGRect(x: 20, y: 5, width: SCREEN_WIDTH - 40, height: 34))
        searchTextField.searchBarStyle = .minimal
        searchTextField.delegate = self
        searchTextField.placeholder = "请输入关键词..."
        return searchTextField
    }()
    
    /// 内容区域
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.separatorColor = UIColor(red:0.9,  green:0.9,  blue:0.9, alpha:1)
        tableView.register(UINib(nibName: "JFNewsNoPicCell", bundle: nil), forCellReuseIdentifier: self.newsNoPicCell)
        tableView.register(UINib(nibName: "JFNewsOnePicCell", bundle: nil), forCellReuseIdentifier: self.newsOnePicCell)
        tableView.register(UINib(nibName: "JFNewsThreePicCell", bundle: nil), forCellReuseIdentifier: self.newsThreePicCell)
        tableView.mj_footer = setupFooterRefresh(self, action: #selector(loadMoreData))
        return tableView
    }()
    
    /// 没有内容的时候的占位图
    fileprivate lazy var placeholderView: JFPlaceholderView = {
        let placeholderView = JFPlaceholderView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64))
        placeholderView.backgroundColor = UIColor.white
        return placeholderView
    }()
    
    /// 搜索关键词关联列表
    fileprivate lazy var searchKeyboardTableView: JFSearchKeyboardTableView = {
        let searchKeyboardTableView = JFSearchKeyboardTableView()
        searchKeyboardTableView.keyboardDelegate = self
        return searchKeyboardTableView
    }()
}

// MARK: - UISearchBarDelegate
extension JFSearchViewController: UISearchBarDelegate {
    
    // 已经改变搜索文字
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loadSearchKeyboardList(searchBar.text!)
    }
    
    // 点击了搜索按钮
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchTextField.endEditing(true)
        prepareTableView()
        
        // 每次搜索都初始化结果数组
        articleList = [JFArticleListModel]()
        pageIndex = 1
        loadSearchResult(searchBar.text!, pageIndex: pageIndex)
        
        // 更新关联视图高度
        self.searchKeyboardTableView.snp.updateConstraints({ (make) in
            make.height.equalTo(0)
        })
        
    }
    
}

// MARK: - JFSearchKeyboardTableViewDelegate
extension JFSearchViewController: JFSearchKeyboardTableViewDelegate {
    
    /**
     点击了关联搜索列表里的关键词
     
     - parameter keyboard: 关键词
     */
    func didSelectedKeyboard(_ keyboard: String) {
        searchKeyboardTableView.snp.updateConstraints { (make) in
            make.height.equalTo(0)
        }
        
        // 搜索
        searchTextField.text = keyboard
        searchBarSearchButtonClicked(searchTextField)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JFSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
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
            if iPhoneModel.getCurrentModel() == .iPad {
                return 162
            } else {
                return 96
            }
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
        
        // 取消cell选中状态
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 跳转控制器
        let currentListModel = articleList[indexPath.row]
        jumpToDetailViewControllerWith(currentListModel)
    }
}
