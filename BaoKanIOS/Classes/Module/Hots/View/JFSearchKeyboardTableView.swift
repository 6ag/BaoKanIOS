//
//  JFSearchKeyboardTableView.swift
//  LiuAGeIOS
//
//  Created by zhoujianfeng on 16/6/27.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

protocol JFSearchKeyboardTableViewDelegate {
    func didSelectedKeyboard(keyboard: String)
}

class JFSearchKeyboardTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

    var searchKeyboardmodels: [JFSearchKeyboardModel]? {
        didSet {
            reloadData()
        }
    }
    
    let cellIdentifier = "searchKeyboardListIdentifier"
    var keyboardDelegate: JFSearchKeyboardTableViewDelegate?
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.delegate = self
        self.dataSource = self
        self.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: cellIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchKeyboardmodels?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
        cell.textLabel?.text = searchKeyboardmodels![indexPath.row].keyboard!
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        keyboardDelegate?.didSelectedKeyboard(searchKeyboardmodels![indexPath.row].keyboard!)
    }
}
