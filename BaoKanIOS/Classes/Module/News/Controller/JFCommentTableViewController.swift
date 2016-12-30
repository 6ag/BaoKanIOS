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
        tableView.register(UINib(nibName: "JFCommentCell", bundle: nil), forCellReuseIdentifier: "commentCell")
        
        // 配置上下拉刷新控件
        tableView.mj_header = setupHeaderRefresh(self, action: #selector(updateNewData))
        tableView.mj_footer = setupFooterRefresh(self, action: #selector(loadMoreData))
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
        loadCommentList(Int(param!.classid)!, id: Int(param!.id)!, pageIndex: 1, method: 0)
    }
    
    /**
     上拉加载更多数据
     */
    @objc fileprivate func loadMoreData() {
        pageIndex += 1
        loadCommentList(Int(param!.classid)!, id: Int(param!.id)!, pageIndex: pageIndex, method: 1)
    }
    
    /**
     根据id、页码加载评论数据
     
     - parameter classid:    当前栏目id
     - parameter id:         当前新闻id
     - parameter pageIndex:  当前页码
     - parameter method:     加载方式 0下拉加载最新 1上拉加载更多
     */
    func loadCommentList(_ classid: Int, id: Int, pageIndex: Int, method: Int) {
        
        JFCommentModel.loadCommentList(classid, id: id, pageIndex: pageIndex, pageSize: 20) { (commentModels, error) in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            guard let models = commentModels, error == nil else {return}
            
            if models.count == 0 {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            
            let maxId = self.commentList.first?.plid ?? 0
            let minId = self.commentList.last?.plid ?? 0
            
            if method == 0 {
                if maxId < models[0].plid {
                    self.commentList = models + self.commentList
                }
            } else {
                if minId > models[0].plid {
                    self.commentList = self.commentList + models
                }
            }
            
            self.tableView.reloadData()
        }
        
    }
    
}

// MARK: - tableView
extension JFCommentTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! JFCommentCell
        cell.delegate = self
        cell.commentModel = commentList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 回复指定评论，下一版实现
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight = commentList[indexPath.row].rowHeight
        if rowHeight < 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! JFCommentCell
            commentList[indexPath.row].rowHeight = cell.getCellHeight(commentList[indexPath.row])
            rowHeight = commentList[indexPath.row].rowHeight
        }
        return rowHeight
    }
    
}

// MARK: - JFCommentCellDelegate
extension JFCommentTableViewController: JFCommentCellDelegate {
    
    func didTappedStarButton(_ button: UIButton, commentModel: JFCommentModel) {
        
        let parameters = [
            "classid" : commentModel.classid,
            "id" : commentModel.id,
            "plid" : commentModel.plid,
            "dopl" : "1",
            "action" : "DoForPl"
        ] as [String : Any]
        
        JFNetworkTool.shareNetworkTool.get(TOP_DOWN, parameters: parameters) { (status, result, tipString) in
            
            if status == .success {
                JFProgressHUD.showInfoWithStatus("谢谢支持")
                
                // 只要顶成功才选中
                button.isSelected = true
                
                commentModel.zcnum += 1
                commentModel.isStar = true
                
                // 刷新单行
                let indexPath = IndexPath(row: self.commentList.index(of: commentModel)!, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            } else {
                JFProgressHUD.showInfoWithStatus("不能重复顶哦")
            }
            
            jf_setupButtonSpringAnimation(button)
        }
    }
}


