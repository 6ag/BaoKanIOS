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
    
    let imagePickerC = UIImagePickerController()
    
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
     配置imagePicker
     
     - parameter sourceType:  资源类型
     */
    func setupImagePicker(sourceType: UIImagePickerControllerSourceType) {
        imagePickerC.view.backgroundColor = BACKGROUND_COLOR
        imagePickerC.delegate = self
        imagePickerC.sourceType = sourceType
        imagePickerC.allowsEditing = true
        imagePickerC.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
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
//        let group2CellModel3 = JFProfileCellSwitchModel(title: "夜间模式", icon: "setting_duty_icon")
        let group2 = JFProfileCellGroupModel(cells: [group2CellModel1, group2CellModel2])
        
        let group3CellModel1 = JFProfileCellArrowModel(title: "意见反馈", icon: "setting_feedback_icon", destinationVc: JFProfileFeedbackViewController.classForCoder())
        let group3CellModel2 = JFProfileCellArrowModel(title: "关于我们", icon: "setting_help_icon", destinationVc: JFAboutMeViewController.classForCoder())
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
            headerView.nameLabel.text = JFAccountModel.shareAccount()!.nickname
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
            let alertC = UIAlertController()
            let takeAction = UIAlertAction(title: "拍照上传", style: UIAlertActionStyle.Default, handler: { (action) in
                self.setupImagePicker(.Camera)
                self.presentViewController(self.imagePickerC, animated: true, completion: {})
            })
            let photoLibraryAction = UIAlertAction(title: "图库选择", style: UIAlertActionStyle.Default, handler: { (action) in
                self.setupImagePicker(.PhotoLibrary)
                self.presentViewController(self.imagePickerC, animated: true, completion: {})
            })
            let albumAction = UIAlertAction(title: "相册选择", style: UIAlertActionStyle.Default, handler: { (action) in
                self.setupImagePicker(.SavedPhotosAlbum)
                self.presentViewController(self.imagePickerC, animated: true, completion: {})
            })
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: { (action) in
                
            })
            alertC.addAction(takeAction)
            alertC.addAction(photoLibraryAction)
            alertC.addAction(albumAction)
            alertC.addAction(cancelAction)
            self.presentViewController(alertC, animated: true, completion: {})
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

// MARK: - JFSetFontViewDelegate
extension JFProfileViewController: JFSetFontViewDelegate {
    
    func didChangeFontSize(fontSize: Int) {
        
    }
    
    func didChangedFontName(fontName: String) {
        
    }
    
    func didChangedNightMode(on: Bool) {
        
    }
}

// MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension JFProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        let newImage = image.resizeImageWithNewSize(CGSize(width: 108, height: 108))
        uploadUserAvatar(newImage)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     上传用户头像
     
     - parameter image: 头像图片
     */
    func uploadUserAvatar(image: UIImage) {
        
        let imagePath = saveImageAndGetURL(image, imageName: "avatar.png")
        
        let parameters: [String : AnyObject] = [
            "username" : JFAccountModel.shareAccount()!.username!,
            "userid" : "\(JFAccountModel.shareAccount()!.id)",
            "token" : JFAccountModel.shareAccount()!.token!,
            "action" : "UploadAvatar",
            ]
        
        JFProgressHUD.showWithStatus("正在上传")
        JFNetworkTool.shareNetworkTool.uploadUserAvatar("\(MODIFY_ACCOUNT_INFO)", imagePath: imagePath, parameters: parameters) { (success, result, error) in
            print(result)
            if success {
                JFProgressHUD.showInfoWithStatus("上传成功")
                
                // 更新用户信息并刷新tableView
                JFAccountModel.checkUserInfo({
                    self.updateHeaderData()
                })
            } else {
                JFProgressHUD.showInfoWithStatus("上传失败")
            }
        }
    }
    
    /**
     保存图片并获取保存的图片路径
     */
    func saveImageAndGetURL(image: UIImage, imageName: NSString) -> NSURL {
        
        let home = NSHomeDirectory() as NSString
        let docPath = home.stringByAppendingPathComponent("Documents") as NSString;
        let fullPath = docPath.stringByAppendingPathComponent(imageName as NSString as String);
        let imageData: NSData = UIImageJPEGRepresentation(image, 0.5)!
        imageData.writeToFile(fullPath as String, atomically: false)
        return NSURL(fileURLWithPath: fullPath)
    }
    
}
