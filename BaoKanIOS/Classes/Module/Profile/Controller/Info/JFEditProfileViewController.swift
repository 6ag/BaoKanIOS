//
//  JFEditProfileViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/13.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFEditProfileViewController: JFBaseTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "账号管理"
        
        let group1CellModel1 = JFProfileCellArrowModel(title: "修改资料", destinationVc: JFModifyInfoTableViewController.classForCoder())
        let group1CellModel2 = JFProfileCellArrowModel(title: "修改安全信息", destinationVc: JFModifySafeTableViewController.classForCoder())
        let group1 = JFProfileCellGroupModel(cells: [group1CellModel1, group1CellModel2])
        
        let group2CellModel1 = JFProfileCellLabelModel(title: "注册时间", text: JFAccountModel.shareAccount()!.registerTime!)
        let group2CellModel2 = JFProfileCellLabelModel(title: "我的积分", text: JFAccountModel.shareAccount()!.points!)
        let group2CellModel3 = JFProfileCellLabelModel(title: "我的等级", text: JFAccountModel.shareAccount()!.groupName!)
        let group2 = JFProfileCellGroupModel(cells: [group2CellModel1, group2CellModel2, group2CellModel3])
        
        groupModels = [group1, group2]
        
        tableView.tableFooterView = footerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        tableView.tableHeaderView = JFInfoHeaderView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 70))
    }
    
    fileprivate func prepareData() {
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 20
        } else {
            return 0.1
        }
    }
    
    /**
     退出登录点击
     */
    func didTappedLogoutButton(_ button: UIButton) -> Void {
        
        let alertC = UIAlertController(title: "确定注销登录状态？", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let action1 = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) { (action) in
            JFAccountModel.logout()
            JFProgressHUD.showSuccessWithStatus("退出成功")
            _ = self.navigationController?.popViewController(animated: true)
        }
        let action2 = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel) { (action) in
            
        }
        alertC.addAction(action1)
        alertC.addAction(action2)
        present(alertC, animated: true) {}
    }
    
    // MARK: - 懒加载
    /// 尾部退出视图
    fileprivate lazy var footerView: UIView = {
        let logoutButton = UIButton(frame: CGRect(x: 20, y: 0, width: SCREEN_WIDTH - 40, height: 44))
        logoutButton.addTarget(self, action: #selector(didTappedLogoutButton(_:)), for: UIControlEvents.touchUpInside)
        logoutButton.setTitle("退出登录", for: UIControlState())
        logoutButton.backgroundColor = NAVIGATIONBAR_RED_COLOR
        logoutButton.layer.cornerRadius = CORNER_RADIUS
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
        footerView.addSubview(logoutButton)
        return footerView
    }()
}
