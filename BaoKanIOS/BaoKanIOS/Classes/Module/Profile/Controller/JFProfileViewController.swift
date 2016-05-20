//
//  JFProfileViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

class JFProfileViewController: JFBaseTableViewController {
    
    lazy var headerView: UIView = {
        let headerView = UIView()
        let imgView = UIImageView(image: UIImage(named: "head"))
        headerView.addSubview(imgView)
        imgView.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        })
        let avatarButton = UIButton(type: UIButtonType.Custom)
        avatarButton.setBackgroundImage(UIImage(named: "default－portrait"), forState: UIControlState.Normal)
        avatarButton.layer.cornerRadius = 40
        avatarButton.layer.masksToBounds = true
        headerView.addSubview(avatarButton)
        avatarButton.addTarget(self, action: #selector(didTappedAvatarButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        avatarButton.snp_makeConstraints(closure: { (make) in
            make.centerX.equalTo(headerView)
            make.centerY.equalTo(headerView)
            make.size.equalTo(CGSize(width: 80, height: 80))
        })
        return headerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = true
        headerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 150)
        tableView.addSubview(headerView)
        tableView.showsVerticalScrollIndicator = false
        
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 210))
        let redView = UIView(frame: CGRect(x: 0, y: 150, width: SCREEN_WIDTH, height: 60))
        redView.backgroundColor = UIColor.redColor()
        tableHeaderView.addSubview(redView)
        tableView.tableHeaderView = tableHeaderView
        
        let group1CellModel1 = JFProfileCellArrowModel(title: "收藏", icon: "setting_star_icon", destinationVc: JFCollectionTableViewController.self)
        let group1 = JFProfileCellGroupModel(cells: [group1CellModel1])
        
        let group2CellModel1 = JFProfileCellLabelModel(title: "清除缓存", icon: "setting_clear_icon", text: "\(String(format: "%.2f", CGFloat(YYImageCache.sharedCache().diskCache.totalCost()) / 1024 / 1024))M")
        group2CellModel1.operation = { () -> Void in
            JFProgressHUD.showWithStatus("正在清理")
            YYImageCache.sharedCache().diskCache.removeAllObjectsWithBlock({
                JFProgressHUD.showSuccessWithStatus("清理成功")
                group2CellModel1.text = "0.00M"
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            })
        }
        let group2CellModel2 = JFProfileCellSwitchModel(title: "夜间模式", icon: "setting_duty_icon")
        let group2CellModel3 = JFProfileCellArrowModel(title: "离线阅读", icon: "setting_upload_icon")
        group2CellModel3.operation = { () -> Void in
            print("离线阅读")
        }
        let group2CellModel4 = JFProfileCellArrowModel(title: "修改资料", icon: "setting_about_icon", destinationVc: JFEditProfileViewController.self)
        let group2 = JFProfileCellGroupModel(cells: [group2CellModel1, group2CellModel2, group2CellModel3, group2CellModel4])
        
        let group3CellModel1 = JFProfileCellArrowModel(title: "意见反馈", icon: "setting_feedback_icon", destinationVc: JFProfileFeedbackViewController.self)
        let group3CellModel2 = JFProfileCellArrowModel(title: "版权声明", icon: "setting_help_icon", destinationVc: JFDutyViewController.self)
        let group3CellModel3 = JFProfileCellArrowModel(title: "推荐给好友", icon: "setting_share_icon")
        group3CellModel3.operation = { () -> Void in
            print("推荐给好友")
        }
        let group3CellModel4 = JFProfileCellLabelModel(title: "当前版本", icon: "setting_upload_icon", text: (NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String))
        let group3 = JFProfileCellGroupModel(cells: [group3CellModel1, group3CellModel2, group3CellModel3, group3CellModel4])
        
        groupModels = [group1, group2, group3]
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        
        // 下拉放大头部视图
        if offsetY < 0 {
            headerView.frame = CGRect(x: offsetY / 2, y: offsetY, width: SCREEN_WIDTH - offsetY, height: 180 - offsetY)
        }
    }
    
    // MARK: - 各种点击事件
    /**
     头像按钮点击
     */
    @objc private func didTappedAvatarButton(button: UIButton) {
        
        if JFAccountModel.shareAccount().isLogin {
            print(JFAccountModel.shareAccount().username)
        } else {
            presentViewController(JFLoginViewController(nibName: "JFLoginViewController", bundle: nil), animated: true) {}
        }
        
    }
    
}
