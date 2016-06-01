//
//  JFCommentTableViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/18.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import MJRefresh

class JFCommentTableViewController: UITableViewController {
    
    var param: (classid: String, id: String)? {
        didSet {
            updateNewData()
        }
    }
    
    // 页码
    var pageIndex = 1
    
    var commentList = [JFCommentModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "评论列表"
        tableView.registerNib(UINib(nibName: "JFCommentCell", bundle: nil), forCellReuseIdentifier: "commentCell")
        
        let headerRefresh = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(updateNewData))
        headerRefresh.lastUpdatedTimeLabel.hidden = true
        tableView.mj_header = headerRefresh
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
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
        loadCommentList(param!.classid, id: param!.id, pageIndex: 1, method: 0)
    }
    
    /**
     上拉加载更多数据
     */
    @objc private func loadMoreData() {
        pageIndex += 1
        loadCommentList(param!.classid, id: param!.id, pageIndex: pageIndex, method: 1)
    }
    
    /**
     根据id、页码加载评论数据
     
     - parameter classid:    当前栏目id
     - parameter id:         当前新闻id
     - parameter pageIndex:  当前页码
     - parameter method:     加载方式 0下拉加载最新 1上拉加载更多
     */
    func loadCommentList(classid: String, id: String, pageIndex: Int, method: Int) {
        let parameters = [
//            "table" : "news",
            "classid" : classid,
            "id" : id,
            "pageIndex" : pageIndex
        ]
        
        JFNetworkTool.shareNetworkTool.get(GET_COMMENT, parameters: parameters as? [String : AnyObject]) { (success, result, error) -> () in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            print(result)
            if success {
                if let successResult = result {
                    
                    let maxId = self.commentList.first?.plid ?? 0
                    let minId = self.commentList.last?.plid ?? 0
                    
                    let data = successResult["data"].arrayValue
                    
                    if data.count == 0 && self.commentList.count == 0 {
                        return
                    }
                    
                    if data.count == 0 {
                        JFProgressHUD.showInfoWithStatus("没有更多评论")
                        return
                    }
                    
                    for comment in data.reverse() {
                        let dict = [
                            "plstep" : comment["plstep"].intValue,
                            "plid" : comment["plid"].intValue,
                            "plusername" : comment["plusername"].stringValue,
                            "id" : comment["id"].intValue,
                            "classid" : comment["classid"].intValue,
                            "saytext" : comment["saytext"].stringValue,
                            "saytime" : comment["saytime"].stringValue,
                            "userpic" : "\(BASE_URL)\(comment["userpic"].stringValue)",
                            "zcnum" : comment["zcnum"].stringValue
                        ]
                        
                        let commentModel = JFCommentModel(dict: dict as! [String : AnyObject])
                        
                        if method == 0 {
                            if maxId < commentModel.plid {
                                self.commentList.insert(commentModel, atIndex: 0)
                            }
                        } else {
                            if minId > commentModel.plid {
                                self.commentList.append(commentModel)
                            }
                        }
                        
                    }
                    
                    // 刷新表格
                    self.tableView.reloadData()
                    
                }
            } else {
                JFProgressHUD.showErrorWithStatus("网络不给力")
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var rowHeight = commentList[indexPath.row].rowHeight
        if rowHeight < 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! JFCommentCell
            commentList[indexPath.row].rowHeight = cell.getCellHeight(commentList[indexPath.row])
            rowHeight = commentList[indexPath.row].rowHeight
        }
        return rowHeight
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! JFCommentCell
        cell.delegate = self
        cell.commentModel = commentList[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // 回复指定评论，下一版实现
    }
    
}

// MARK: - JFCommentCellDelegate
extension JFCommentTableViewController: JFCommentCellDelegate {
    func didTappedStarButton(button: UIButton, commentModel: JFCommentModel) {
        button.selected = true
        
        let parameters = [
            "classid" : commentModel.classid,
            "id" : commentModel.id,
            "plid" : commentModel.plid,
            "dopl" : "1",
            "action" : "DoForPl"
        ]
        
        JFNetworkTool.shareNetworkTool.get(TOP_DOWN, parameters: parameters as? [String : AnyObject]) { (success, result, error) in
            print(result)
            JFProgressHUD.showInfoWithStatus(result!["result"]["info"].stringValue)
            if success {
                commentModel.zcnum += 1
                self.tableView.reloadData()
            }
        }
    }
}


