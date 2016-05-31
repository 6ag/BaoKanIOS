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
    
    func didChangeTextField(sender: UITextField) {
        if oldPasswordField.text?.characters.count > 1 && newPasswordField.text?.characters.count > 1 && reNewPasswordField.text?.characters.count > 1 && emailField.text?.characters.count > 1 {
            saveButton.enabled = true
            saveButton.backgroundColor = NAVIGATIONBAR_RED_COLOR
        } else {
            saveButton.enabled = false
            saveButton.backgroundColor = UIColor.grayColor()
        }
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
            emailField.text = JFAccountModel.shareAccount()!.email!
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
        let parameters: [String : AnyObject] = [
            "username" : JFAccountModel.shareAccount()!.username!,
            "userid" : JFAccountModel.shareAccount()!.id,
            "action" : "EditSafeInfo",
            "token" : JFAccountModel.shareAccount()!.token!,
            "oldpassword" : oldPasswordField.text!,
            "password" : newPasswordField.text!,
            "repassword" : reNewPasswordField.text!,
            "email" : emailField.text!
            ]
        
        JFNetworkTool.shareNetworkTool.post(MODIFY_ACCOUNT_INFO, parameters: parameters) { (success, result, error) in
            if result != nil {
                if result!["data"]["info"].stringValue == "修改信息成功！" {
                    self.navigationController?.popViewControllerAnimated(true)
                }
                JFProgressHUD.showInfoWithStatus(result!["data"]["info"].stringValue)
            } else {
                JFProgressHUD.showInfoWithStatus("修改失败，请联系管理员！")
            }
        }
    }
    
    /// 尾部保存视图
    private lazy var footerView: UIView = {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
        footerView.addSubview(self.saveButton)
        return footerView
    }()
    
    private lazy var saveButton: UIButton = {
        let saveButton = UIButton(frame: CGRect(x: 20, y: 0, width: SCREEN_WIDTH - 40, height: 44))
        saveButton.addTarget(self, action: #selector(didTappedSaveButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        saveButton.setTitle("保存", forState: UIControlState.Normal)
        saveButton.enabled = false
        saveButton.backgroundColor = UIColor.grayColor()
        saveButton.layer.cornerRadius = CORNER_RADIUS
        return saveButton
    }()
    
    private lazy var oldPasswordField: UITextField = {
        let field = UITextField(frame: CGRect(x: 100, y: 0, width: SCREEN_WIDTH - 120, height: 44))
        field.addTarget(self, action: #selector(didChangeTextField(_:)), forControlEvents: UIControlEvents.EditingChanged)
        field.font = UIFont.systemFontOfSize(14)
        field.placeholder = "原密码"
        field.secureTextEntry = true
        field.clearButtonMode = .WhileEditing
        return field
    }()
    
    private lazy var newPasswordField: UITextField = {
        let field = UITextField(frame: CGRect(x: 100, y: 0, width: SCREEN_WIDTH - 120, height: 44))
        field.addTarget(self, action: #selector(didChangeTextField(_:)), forControlEvents: UIControlEvents.EditingChanged)
        field.font = UIFont.systemFontOfSize(14)
        field.placeholder = "新密码（不修改请留空）"
        field.secureTextEntry = true
        field.clearButtonMode = .WhileEditing
        return field
    }()
    
    private lazy var reNewPasswordField: UITextField = {
        let field = UITextField(frame: CGRect(x: 100, y: 0, width: SCREEN_WIDTH - 120, height: 44))
        field.addTarget(self, action: #selector(didChangeTextField(_:)), forControlEvents: UIControlEvents.EditingChanged)
        field.font = UIFont.systemFontOfSize(14)
        field.placeholder = "确认新密码（不修改请留空）"
        field.secureTextEntry = true
        field.clearButtonMode = .WhileEditing
        return field
    }()
    
    private lazy var emailField: UITextField = {
        let field = UITextField(frame: CGRect(x: 100, y: 0, width: SCREEN_WIDTH - 120, height: 44))
        field.addTarget(self, action: #selector(didChangeTextField(_:)), forControlEvents: UIControlEvents.EditingChanged)
        field.font = UIFont.systemFontOfSize(14)
        field.placeholder = "邮箱"
        field.secureTextEntry = true
        field.clearButtonMode = .WhileEditing
        return field
    }()
    
}
