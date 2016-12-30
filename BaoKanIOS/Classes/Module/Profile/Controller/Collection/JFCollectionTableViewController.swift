//
//  JFCollectionTableViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/13.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import MJRefresh

class JFCollectionTableViewController: UITableViewController {
    
    var articleList = [JFCollectionModel]()
    let identifier = "favaidentifier"
    var pageIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "收藏"
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: identifier)
        let headerRefresh = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(updateNewData))
        headerRefresh?.lastUpdatedTimeLabel.isHidden = true
        tableView.mj_header = headerRefresh
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        
        tableView.mj_header.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /**
     下拉加载最新数据
     */
    @objc fileprivate func updateNewData() {
        loadNews(1, method: 0)
    }
    
    /**
     上拉加载更多数据
     */
    @objc fileprivate func loadMoreData() {
        pageIndex += 1
        loadNews(pageIndex, method: 1)
    }
    
    /**
     根据分类id、页码加载数据
     
     - parameter pageIndex:  当前页码
     - parameter method:     加载方式 0下拉加载最新 1上拉加载更多
     */
    fileprivate func loadNews(_ pageIndex: Int, method: Int) {
        
        let parameters: [String : AnyObject] = [
            "username" : JFAccountModel.shareAccount()!.username! as AnyObject,
            "userid" : JFAccountModel.shareAccount()!.id as AnyObject,
            "token" : JFAccountModel.shareAccount()!.token! as AnyObject,
            "pageIndex" : pageIndex as AnyObject
        ]
        
        JFNetworkTool.shareNetworkTool.get(GET_USER_FAVA, parameters: parameters) { (status, result, tipString) -> () in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
//            print(result)
            if status == .success {
                if let successResult = result {
                    let data = successResult["data"].arrayValue.reversed()
                    
                    let minId = self.articleList.last?.favaid ?? "0"
                    let maxId = self.articleList.first?.favaid ?? "0"
                    
                    for fava in data {
                        
                        let dict = [
                            "title" : fava["title"].stringValue,
                            "classid" : fava["classid"].stringValue,
                            "id" : fava["id"].stringValue,
                            "tbname" : fava["tbname"].stringValue,
                            "favatime" : fava["favatime"].stringValue,
                            "favaid" : fava["favaid"].stringValue,
                            "cid" : fava["cid"].stringValue
                        ]
                        
                        let postModel = JFCollectionModel(dict: dict as [String : AnyObject])
                        
                        if method == 0 {
                            if Int(maxId)! < Int(postModel.favaid!)! {
                                self.articleList.insert(postModel, at: 0)
                            }
                        } else {
                            if Int(minId)! > Int(postModel.favaid!)! {
                                self.articleList.append(postModel)
                            }
                        }
                        
                    }
                    
                    self.tableView.reloadData()
                    
                } else {
                    print("error:\(tipString)")
                }
                
            }
        }
        
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.textLabel?.text = articleList[indexPath.row].title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if articleList[indexPath.row].tbname == "photo" {
            let currentListModel = articleList[indexPath.row]
            let detailVc = JFPhotoDetailViewController()
            detailVc.photoParam = (currentListModel.classid!, currentListModel.id!)
            navigationController?.pushViewController(detailVc, animated: true)
        } else if articleList[indexPath.row].tbname == "news" {
            let currentListModel = articleList[indexPath.row]
            let detailVc = JFNewsDetailViewController()
            detailVc.articleParam = (currentListModel.classid!, currentListModel.id!)
            self.navigationController?.pushViewController(detailVc, animated: true)
        }
    }
}
