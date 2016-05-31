//
//  JFCommentListTableViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/23.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import MJRefresh

class JFCommentListTableViewController: UITableViewController {

    var articleList = [JFUserCommentModel]()
    let identifier = "favaidentifier"
    var pageIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "足迹"
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: identifier)
        let headerRefresh = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(updateNewData))
        headerRefresh.lastUpdatedTimeLabel.hidden = true
        tableView.mj_header = headerRefresh
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        
        tableView.mj_header.beginRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /**
     下拉加载最新数据
     */
    @objc private func updateNewData() {
        loadNews(1, method: 0)
    }
    
    /**
     上拉加载更多数据
     */
    @objc private func loadMoreData() {
        pageIndex += 1
        loadNews(pageIndex, method: 1)
    }
    
    /**
     根据分类id、页码加载数据
     
     - parameter pageIndex:  当前页码
     - parameter method:     加载方式 0下拉加载最新 1上拉加载更多
     */
    private func loadNews(pageIndex: Int, method: Int) {
        
        let parameters: [String : AnyObject] = [
            "username" : JFAccountModel.shareAccount()!.username!,
            "userid" : JFAccountModel.shareAccount()!.id,
            "token" : JFAccountModel.shareAccount()!.token!,
            "pageIndex" : pageIndex
        ]
        
        JFNetworkTool.shareNetworkTool.get(GET_USER_COMMENT, parameters: parameters) { (success, result, error) -> () in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            print(result)
            if success == true {
                if let successResult = result {
                    let data = successResult["data"].arrayValue.reverse()
                    
                    let minId = self.articleList.last?.plid ?? "0"
                    let maxId = self.articleList.first?.plid ?? "0"
                    
                    for fava in data {
                        
                        let dict = [
                            "title" : fava["title"].stringValue,
                            "classid" : fava["classid"].stringValue,
                            "id" : fava["id"].stringValue,
                            "tbname" : fava["tbname"].stringValue,
                            "saytext" : fava["saytext"].stringValue,
                            "saytime" : fava["saytime"].stringValue,
                            "plid" : fava["plid"].stringValue,
                            "plstep" : fava["plstep"].stringValue,
                            "plusername" : fava["plusername"].stringValue,
                            "zcnum" : fava["zcnum"].stringValue,
                            "userpic" : fava["userpic"].stringValue
                        ]
                        
                        let postModel = JFUserCommentModel(dict: dict)
                        
                        if method == 0 {
                            if Int(maxId) < Int(postModel.plid!) {
                                self.articleList.insert(postModel, atIndex: 0)
                            }
                        } else {
                            if Int(minId) > Int(postModel.plid!) {
                                self.articleList.append(postModel)
                            }
                        }
                        
                    }
                    
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
        return articleList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        cell.textLabel?.text = articleList[indexPath.row].title
        cell.textLabel?.font = UIFont.systemFontOfSize(15)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
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
