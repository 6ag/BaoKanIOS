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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.showsVerticalScrollIndicator = false
        tableView.addSubview(headerView)
        // 这个是用来占位的
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 275))
        tableView.tableHeaderView = tableHeaderView
        prepareData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        updateHeaderData()
        tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    /**
     准备数据
     */
    private func prepareData() {
        //        let group1CellModel1 = JFProfileCellArrowModel(title: "离线阅读", icon: "setting_star_icon")
        //        group1CellModel1.operation = { () -> Void in
        //            print("离线阅读")
        //        }
        //        let group1 = JFProfileCellGroupModel(cells: [group1CellModel1])
        
        let group2CellModel1 = JFProfileCellLabelModel(title: "清除缓存", icon: "setting_clear_icon", text: "0.0M")
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
        let group2CellModel2 = JFProfileCellArrowModel(title: "正文字体", icon: "setting_star_icon")
        group2CellModel2.operation = { () -> Void in
            let setFontSizeView = NSBundle.mainBundle().loadNibNamed("JFSetFontView", owner: nil, options: nil).last as! JFSetFontView
            setFontSizeView.delegate = self
            setFontSizeView.show()
        }
        let group2CellModel3 = JFProfileCellSwitchModel(title: "夜间模式", icon: "setting_duty_icon")
        let group2 = JFProfileCellGroupModel(cells: [group2CellModel1, group2CellModel2, group2CellModel3])
        
        let group3CellModel1 = JFProfileCellArrowModel(title: "意见反馈", icon: "setting_feedback_icon", destinationVc: JFProfileFeedbackViewController.classForCoder())
        let group3CellModel2 = JFProfileCellArrowModel(title: "版权声明", icon: "setting_help_icon", destinationVc: JFDutyViewController.classForCoder())
        let group3CellModel3 = JFProfileCellArrowModel(title: "推荐给好友", icon: "setting_share_icon")
        group3CellModel3.operation = { () -> Void in
            var image = UIImage(named: "launchScreen")
            if image != nil && (image?.size.width > 300 || image?.size.height > 300) {
                image = image?.resizeImageWithNewSize(CGSize(width: 300, height: 300 * image!.size.height / image!.size.width))
            }
            
            let shareParames = NSMutableDictionary()
            shareParames.SSDKSetupShareParamsByText("爆侃网文精心打造网络文学互动平台，专注最新文学市场动态，聚焦第一手网文圈资讯！",
                                                    images : image,
                                                    url : NSURL(string:"https://itunes.apple.com/cn/app/id\(APPLE_ID)"),
                                                    title : "爆侃网文",
                                                    type : SSDKContentType.Auto)
            
            let items = [
                SSDKPlatformType.TypeQQ.rawValue,
                SSDKPlatformType.TypeWechat.rawValue,
                SSDKPlatformType.TypeSinaWeibo.rawValue
            ]
            
            ShareSDK.showShareActionSheet(nil, items: items, shareParams: shareParames) { (state : SSDKResponseState, platform: SSDKPlatformType, userData : [NSObject : AnyObject]!, contentEntity :SSDKContentEntity!, error : NSError!, end: Bool) in
                switch state {
                    
                case SSDKResponseState.Success:
                    print("分享成功")
                case SSDKResponseState.Fail:
                    print("分享失败,错误描述:\(error)")
                case SSDKResponseState.Cancel:
                    print("取消分享")
                default:
                    break
                }
            }
        }
        let group3CellModel4 = JFProfileCellLabelModel(title: "当前版本", icon: "setting_upload_icon", text: (NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String))
        let group3 = JFProfileCellGroupModel(cells: [group3CellModel1, group3CellModel2, group3CellModel3, group3CellModel4])
        
        groupModels = [group2, group3]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as! JFProfileCell
        
        // 更新缓存数据
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.settingRightLabel.text = "\(String(format: "%.2f", CGFloat(YYImageCache.sharedCache().diskCache.totalCost()) / 1024 / 1024))M"
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    /**
     更新头部数据
     */
    private func updateHeaderData() {
        if JFAccountModel.isLogin() {
            headerView.avatarButton.yy_setBackgroundImageWithURL(NSURL(string: JFAccountModel.shareAccount()!.avatarUrl!), forState: UIControlState.Normal, options: YYWebImageOptions.AllowBackgroundTask)
            headerView.nameLabel.text = JFAccountModel.shareAccount()!.username
        } else {
            headerView.avatarButton.setBackgroundImage(UIImage(named: "default－portrait"), forState: UIControlState.Normal)
            headerView.nameLabel.text = "登录账号"
        }
    }
    
    lazy var headerView: JFProfileHeaderView = {
        let headerView = NSBundle.mainBundle().loadNibNamed("JFProfileHeaderView", owner: nil, options: nil).last as! JFProfileHeaderView
        headerView.delegate = self
        headerView.frame = CGRect(x: 0, y: -(SCREEN_HEIGHT * 2 - 265), width: SCREEN_WIDTH, height: SCREEN_HEIGHT * 2)
        return headerView
    }()
    
}

// MARK: - JFProfileHeaderViewDelegate
extension JFProfileViewController: JFProfileHeaderViewDelegate {
    
    /**
     头像按钮点击
     */
    func didTappedAvatarButton() {
        if JFAccountModel.isLogin() {
//            // 更换头像
//            let avaterAlertC = UIAlertController(title: "修改头像", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
//            let selectPhoto = UIAlertAction(title: "相册选择", style: .Default, handler: { (action) in
//                
//            })
//            let takePhoto = UIAlertAction(title: "拍照", style: .Default, handler: { (action) in
//                
//            })
//            let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: { (action) in
//                
//            })
//            avaterAlertC.addAction(selectPhoto)
//            avaterAlertC.addAction(takePhoto)
//            avaterAlertC.addAction(cancel)
//            presentViewController(avaterAlertC, animated: true, completion: nil)
            // 还没有修改头像的接口，这里进个人资料里
            navigationController?.pushViewController(JFEditProfileViewController(style: UITableViewStyle.Grouped), animated: true)
        } else {
            presentViewController(JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil)), animated: true, completion: {
            })
        }
    }
    
    /**
     收藏列表
     */
    func didTappedCollectionButton() {
        if JFAccountModel.isLogin() {
            navigationController?.pushViewController(JFCollectionTableViewController(style: UITableViewStyle.Plain), animated: true)
        } else {
            presentViewController(JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil)), animated: true, completion: {
            })
        }
    }
    
    /**
     评论列表
     */
    func didTappedCommentButton() {
        if JFAccountModel.isLogin() {
            navigationController?.pushViewController(JFCommentListTableViewController(style: UITableViewStyle.Plain), animated: true)
        } else {
            presentViewController(JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil)), animated: true, completion: {
            })
        }
    }
    
    /**
     修改个人信息
     */
    func didTappedInfoButton() {
        if JFAccountModel.isLogin() {
            navigationController?.pushViewController(JFEditProfileViewController(style: UITableViewStyle.Grouped), animated: true)
        } else {
            presentViewController(JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil)), animated: true, completion: {
            })
        }
    }
}

extension JFProfileViewController: JFSetFontViewDelegate {
    func didChangeFontSize() {
        print("改变了字体大小")
    }
}
