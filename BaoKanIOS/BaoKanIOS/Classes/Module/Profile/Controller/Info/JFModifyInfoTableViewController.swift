//
//  JFModifyInfoTableViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/26.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

class JFModifyInfoTableViewController: JFBaseTableViewController {

    let modifyInfoIdenfitier = "modifyInfoIdenfitier"
    
    override init(style: UITableViewStyle) {
        super.init(style: UITableViewStyle.Grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = false
        tableView.tableFooterView = footerView
        
        let group1CellModel1 = JFProfileCellModel(title: "头像")
        let group1CellModel2 = JFProfileCellModel(title: "用户名:")
        let group1CellModel3 = JFProfileCellModel(title: "真实姓名:")
        let group1CellModel4 = JFProfileCellModel(title: "联系电话:")
        let group1CellModel5 = JFProfileCellModel(title: "QQ号码:")
        let group1CellModel6 = JFProfileCellModel(title: "个性签名:")
        let group1 = JFProfileCellGroupModel(cells: [group1CellModel1, group1CellModel2, group1CellModel3, group1CellModel4, group1CellModel5, group1CellModel6])
        groupModels = [group1]
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 70
        } else {
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        switch indexPath.row {
        case 0:
            avatarImageView.yy_setImageWithURL(NSURL(string: JFAccountModel.shareAccount().avatarUrl!), options: YYWebImageOptions.AllowBackgroundTask)
            cell.contentView.addSubview(avatarImageView)
            return cell
        case 1:
            usernameField.text = JFAccountModel.shareAccount().username!
            cell.contentView.addSubview(usernameField)
            return cell
        case 2:
            cell.contentView.addSubview(realField)
            return cell
        case 3:
            cell.contentView.addSubview(phoneNumberField)
            return cell
        case 4:
            cell.contentView.addSubview(qqField)
            return cell
        case 5:
            cell.contentView.addSubview(signField)
            return cell
        default:
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    /**
     点击了保存
     */
    func didTappedSaveButton(button: UIButton) -> Void {
        
    }
    
    /// 尾部保存视图
    private lazy var footerView: UIView = {
        let logoutButton = UIButton(frame: CGRect(x: 20, y: 0, width: SCREEN_WIDTH - 40, height: 44))
        logoutButton.addTarget(self, action: #selector(didTappedSaveButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        logoutButton.setTitle("保存", forState: UIControlState.Normal)
        logoutButton.backgroundColor = NAVIGATIONBAR_RED_COLOR
        logoutButton.layer.cornerRadius = CORNER_RADIUS
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
        footerView.addSubview(logoutButton)
        return footerView
    }()

    private lazy var usernameField: UITextField = {
        let field = UITextField(frame: CGRect(x: 100, y: 0, width: 200, height: 44))
        field.enabled = false
        field.font = UIFont.systemFontOfSize(14)
        field.placeholder = "用户名"
        return field
    }()
    
    private lazy var realField: UITextField = {
        let field = UITextField(frame: CGRect(x: 100, y: 0, width: 200, height: 44))
        field.font = UIFont.systemFontOfSize(14)
        field.placeholder = "姓名"
        return field
    }()
    
    private lazy var phoneNumberField: UITextField = {
        let field = UITextField(frame: CGRect(x: 100, y: 0, width: 200, height: 44))
        field.font = UIFont.systemFontOfSize(14)
        field.placeholder = "联系电话"
        return field
    }()
    
    private lazy var qqField: UITextField = {
        let field = UITextField(frame: CGRect(x: 100, y: 0, width: 200, height: 44))
        field.font = UIFont.systemFontOfSize(14)
        field.placeholder = "QQ号"
        return field
    }()
    
    private lazy var signField: UITextField = {
        let field = UITextField(frame: CGRect(x: 100, y: 0, width: 200, height: 44))
        field.font = UIFont.systemFontOfSize(14)
        field.placeholder = "个性签名"
        return field
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView(frame: CGRect(x: SCREEN_WIDTH - 70, y: 10, width: 50, height: 50))
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.layer.masksToBounds = true
        return avatarImageView
    }()
}
