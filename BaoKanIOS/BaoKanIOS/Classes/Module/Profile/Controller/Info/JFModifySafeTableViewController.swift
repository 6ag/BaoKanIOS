//
//  JFModifySafeTableViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/26.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFModifySafeTableViewController: JFBaseTableViewController {
    
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
        
        let group1CellModel1 = JFProfileCellModel(title: "原密码:")
        let group1CellModel2 = JFProfileCellModel(title: "新密码:")
        let group1CellModel3 = JFProfileCellModel(title: "确认新密码:")
        let group1CellModel4 = JFProfileCellModel(title: "邮箱:")
        let group1 = JFProfileCellGroupModel(cells: [group1CellModel1, group1CellModel2, group1CellModel3, group1CellModel4])
        groupModels = [group1]
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        switch indexPath.row {
        case 0:
            cell.contentView.addSubview(oldPasswordField)
            return cell
        case 1:
            cell.contentView.addSubview(newPasswordField)
            return cell
        case 2:
            cell.contentView.addSubview(reNewPasswordField)
            return cell
        case 3:
            emailField.text = JFAccountModel.shareAccount().email!
            cell.contentView.addSubview(emailField)
            return cell
        default:
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "修改密码或邮箱时，需要原密码进行验证"
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
    
    private lazy var oldPasswordField: UITextField = {
        let field = UITextField(frame: CGRect(x: 100, y: 0, width: 200, height: 44))
        field.font = UIFont.systemFontOfSize(14)
        field.placeholder = "原密码"
        return field
    }()
    
    private lazy var newPasswordField: UITextField = {
        let field = UITextField(frame: CGRect(x: 100, y: 0, width: 200, height: 44))
        field.font = UIFont.systemFontOfSize(14)
        field.placeholder = "新密码（不修改请留空）"
        return field
    }()
    
    private lazy var reNewPasswordField: UITextField = {
        let field = UITextField(frame: CGRect(x: 100, y: 0, width: 200, height: 44))
        field.font = UIFont.systemFontOfSize(14)
        field.placeholder = "确认新密码（不修改请留空）"
        return field
    }()
    
    private lazy var emailField: UITextField = {
        let field = UITextField(frame: CGRect(x: 100, y: 0, width: 200, height: 44))
        field.font = UIFont.systemFontOfSize(14)
        field.placeholder = "邮箱"
        return field
    }()
    
}
