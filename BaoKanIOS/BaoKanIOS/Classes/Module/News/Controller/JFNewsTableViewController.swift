//
//  JFNewsTableViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/1.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import SDCycleScrollView

class JFNewsTableViewController: UITableViewController, SDCycleScrollViewDelegate {
    
    /// 分类id
    var id: Int? {
        didSet {
            loadNews(70, page: 1)
        }
    }
    
    /// 模型数组
    var postArray: [JFPostModel] = []
    
    /// 新闻cell重用标识符
    let newsReuseIdentifier = "newsReuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(JFNewsCell.self, forCellReuseIdentifier: newsReuseIdentifier)
        tableView.rowHeight = 100
        prepareScrollView()
    }
    
    /**
     准备头部轮播
     */
    private func prepareScrollView() {
        let scrollView = SDCycleScrollView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 150), delegate: self, placeholderImage: UIImage(named: "photoview_image_default_white"))
        scrollView.currentPageDotColor = UIColor.redColor()
        scrollView.pageDotColor = UIColor.blackColor()
        scrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight
        scrollView.imageURLStringsGroup = ["http://file.ynet.com/2/1601/14/10731063.jpg", "http://file.ynet.com/2/1601/14/10731063.jpg", "http://file.ynet.com/2/1601/14/10731063.jpg"]
        scrollView.titlesGroup = ["测试轮播标题1", "测试轮播标题2", "测试轮播标题3"]
        scrollView.autoScrollTimeInterval = 5
        tableView.tableHeaderView = scrollView
    }
    
    func cycleScrollView(cycleScrollView: SDCycleScrollView!, didSelectItemAtIndex index: Int) {
        print("点击了第\(index)张图")
    }
    
    /**
     根据分类id、页码加载数据
     
     - parameter categoryId: 分类id
     - parameter page:       页码
     */
    private func loadNews(categoryId: Int, page: Int) {
        
        let parameters = [
            "id" : categoryId,
            "page" : page
        ]
        
        JFProgressHUD.showWithStatus("正在加载")
        JFNetworkTool.shareNetworkTool.get("http://wp.baokan.name/api/get_category_posts", parameters: parameters) { (success, result, error) -> () in
            JFProgressHUD.dismiss()
            if success == true {
                if let successResult = result {
                    
                    // 返回条数
                    for index in 0..<successResult["count"]!.intValue {
                        
                        let postDict = successResult["posts"]!.arrayValue[index].dictionaryValue
                        
                        // 取出需要的数据
                        let title = postDict["title"]!.stringValue
                        let content = postDict["content"]!.stringValue
                        let date = postDict["date"]!.stringValue
                        let thumbnailUrl = postDict["thumbnail"]!.stringValue
                        let views = postDict["custom_fields"]!.dictionaryValue["views"]!.arrayValue.first!.stringValue
                        let comment_count = postDict["comment_count"]!.stringValue
                        let id = postDict["id"]!.stringValue
                        let nickname = postDict["author"]!.dictionaryValue["nickname"]!.stringValue
                        
                        let dict = [
                            "title" : title,
                            "content" : content,
                            "date" : date,
                            "thumbnailUrl" : thumbnailUrl,
                            "views" : views,
                            "comment_count" : comment_count,
                            "id": id,
                            "nickname" : nickname
                        ]
                        
                        // 字典转模型
                        let postModel = JFPostModel(dict: dict)
                        
                        // 如果字典中不包含模型对象才存入
                        if self.postArray.contains(postModel) == false {
                            self.postArray.append(postModel)
                        }
                        
                    }
                    
                }
                
                // 刷新表格
                self.tableView.reloadData()
                
            } else {
                print("error:\(error)")
            }
            
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(newsReuseIdentifier) as! JFNewsCell
        
        cell.postModel = postArray[indexPath.row]
        
        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
