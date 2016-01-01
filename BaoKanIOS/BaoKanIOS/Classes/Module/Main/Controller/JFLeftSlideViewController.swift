//
//  JFLeftSlideViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/1.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFLeftSlideViewController: UIViewController {

    // 唯一标识符
    let leftSlideIdentifier = "leftSlideCell"
    /// 头像
    @IBOutlet weak var avatarImageView: UIImageView!
    /// 名字
    @IBOutlet weak var nameLabel: UILabel!
    /// 侧栏列表
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: leftSlideIdentifier)
        
        avatarImageView.layer.borderColor = UIColor.redColor().CGColor
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.layer.masksToBounds = true
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension JFLeftSlideViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(leftSlideIdentifier)!
        cell.textLabel?.text = "测试数据"
        cell.backgroundColor = UIColor(colorLiteralRed: 19/255.0, green: 143/255.0, blue: 208/255.0, alpha: 1.0)
        return cell
    }
    
}
