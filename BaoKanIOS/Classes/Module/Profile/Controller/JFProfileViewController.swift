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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        updateHeaderData()
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    /**
     配置imagePicker
     
     - parameter sourceType:  资源类型
     */
    func setupImagePicker(_ sourceType: UIImagePickerControllerSourceType) {
        imagePickerC.view.backgroundColor = BACKGROUND_COLOR
        imagePickerC.delegate = self
        imagePickerC.sourceType = sourceType
        imagePickerC.allowsEditing = true
        imagePickerC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
    }
    
    /**
     准备数据
     */
    fileprivate func prepareData() {
        //        let group1CellModel1 = JFProfileCellArrowModel(title: "离线阅读", icon: "setting_star_icon")
        //        group1CellModel1.operation = { () -> Void in
        //            print("离线阅读")
        //        }
        //        let group1 = JFProfileCellGroupModel(cells: [group1CellModel1])
        
        let group2CellModel1 = JFProfileCellLabelModel(title: "清除缓存", icon: "setting_clear_icon", text: "0.0M")
        group2CellModel1.operation = { () -> Void in
            JFProgressHUD.showWithStatus("正在清理")
            YYImageCache.shared().diskCache.removeAllObjects({
                JFProgressHUD.showSuccessWithStatus("清理成功")
                group2CellModel1.text = "0.00M"
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            })
        }
        let group2CellModel2 = JFProfileCellArrowModel(title: "正文字体", icon: "setting_star_icon")
        group2CellModel2.operation = { () -> Void in
            let setFontSizeView = Bundle.main.loadNibNamed("JFSetFontView", owner: nil, options: nil)?.last as! JFSetFontView
            setFontSizeView.delegate = self
            setFontSizeView.show()
        }
//        let group2CellModel3 = JFProfileCellSwitchModel(title: "夜间模式", icon: "setting_duty_icon")
        let group2 = JFProfileCellGroupModel(cells: [group2CellModel1, group2CellModel2])
        
        let group3CellModel1 = JFProfileCellArrowModel(title: "意见反馈", icon: "setting_feedback_icon", destinationVc: JFProfileFeedbackViewController.classForCoder())
        let group3CellModel2 = JFProfileCellArrowModel(title: "关于我们", icon: "setting_help_icon", destinationVc: JFAboutMeViewController.classForCoder())
        let group3CellModel3 = JFProfileCellArrowModel(title: "推荐给好友", icon: "setting_share_icon")
        group3CellModel3.operation = { () -> Void in
            if JFShareItemModel.loadShareItems().count == 0 {
                JFProgressHUD.showInfoWithStatus("没有可分享内容")
                return
            }
            
            // 弹出分享视图
            self.shareView.showShareView()
        }

        let group3CellModel4 = JFProfileCellLabelModel(title: "当前版本", icon: "setting_upload_icon", text: (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String))
        let group3 = JFProfileCellGroupModel(cells: [group3CellModel1, group3CellModel2, group3CellModel3, group3CellModel4])
        
        groupModels = [group2, group3]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! JFProfileCell
        
        // 更新缓存数据
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.settingRightLabel.text = "\(String(format: "%.2f", CGFloat(YYImageCache.shared().diskCache.totalCost()) / 1024 / 1024))M"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    /**
     更新头部数据
     */
    fileprivate func updateHeaderData() {
        if JFAccountModel.isLogin() {
            headerView.avatarButton.yy_setBackgroundImage(with: URL(string: JFAccountModel.shareAccount()!.avatarUrl!), for: UIControlState(), options: YYWebImageOptions.allowBackgroundTask)
            headerView.nameLabel.text = JFAccountModel.shareAccount()!.nickname
        } else {
            headerView.avatarButton.setBackgroundImage(UIImage(named: "default－portrait"), for: .normal)
            headerView.nameLabel.text = "登录账号"
        }
    }
    
    lazy var headerView: JFProfileHeaderView = {
        let headerView = Bundle.main.loadNibNamed("JFProfileHeaderView", owner: nil, options: nil)?.last as! JFProfileHeaderView
        headerView.delegate = self
        headerView.frame = CGRect(x: 0, y: -(SCREEN_HEIGHT * 2 - 265), width: SCREEN_WIDTH, height: SCREEN_HEIGHT * 2)
        return headerView
    }()
    
    /// 分享视图
    fileprivate lazy var shareView: JFShareView = {
        let shareView = JFShareView()
        shareView.delegate = self
        return shareView
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
            let takeAction = UIAlertAction(title: "拍照上传", style: UIAlertActionStyle.default, handler: { (action) in
                self.setupImagePicker(.camera)
                self.present(self.imagePickerC, animated: true, completion: {})
            })
            let photoLibraryAction = UIAlertAction(title: "图库选择", style: UIAlertActionStyle.default, handler: { (action) in
                self.setupImagePicker(.photoLibrary)
                self.present(self.imagePickerC, animated: true, completion: {})
            })
            let albumAction = UIAlertAction(title: "相册选择", style: UIAlertActionStyle.default, handler: { (action) in
                self.setupImagePicker(.savedPhotosAlbum)
                self.present(self.imagePickerC, animated: true, completion: {})
            })
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: { (action) in
                
            })
            alertC.addAction(takeAction)
            alertC.addAction(photoLibraryAction)
            alertC.addAction(albumAction)
            alertC.addAction(cancelAction)
            self.present(alertC, animated: true, completion: {})
        } else {
            present(JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil)), animated: true, completion: {
            })
        }
    }
    
    /**
     收藏列表
     */
    func didTappedCollectionButton() {
        if JFAccountModel.isLogin() {
            navigationController?.pushViewController(JFCollectionTableViewController(style: UITableViewStyle.plain), animated: true)
        } else {
            present(JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil)), animated: true, completion: {
            })
        }
    }
    
    /**
     评论列表
     */
    func didTappedCommentButton() {
        if JFAccountModel.isLogin() {
            navigationController?.pushViewController(JFCommentListTableViewController(style: UITableViewStyle.plain), animated: true)
        } else {
            present(JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil)), animated: true, completion: {
            })
        }
    }
    
    /**
     修改个人信息
     */
    func didTappedInfoButton() {
        if JFAccountModel.isLogin() {
            navigationController?.pushViewController(JFEditProfileViewController(style: UITableViewStyle.grouped), animated: true)
        } else {
            present(JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil)), animated: true, completion: {
            })
        }
    }
}

// MARK: - JFSetFontViewDelegate
extension JFProfileViewController: JFSetFontViewDelegate {
    
    func didChangeFontSize(_ fontSize: Int) {
        
    }
    
    func didChangedFontName(_ fontName: String) {
        
    }
    
    func didChangedNightMode(_ on: Bool) {
        
    }
}

// MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension JFProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        let newImage = image.resizeImageWithNewSize(CGSize(width: 108, height: 108))
        uploadUserAvatar(newImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    /**
     上传用户头像
     
     - parameter image: 头像图片
     */
    func uploadUserAvatar(_ image: UIImage) {
        
        let imagePath = saveImageAndGetURL(image, imageName: "avatar.png")
        
        let parameters: [String : AnyObject] = [
            "username" : JFAccountModel.shareAccount()!.username! as AnyObject,
            "userid" : "\(JFAccountModel.shareAccount()!.id)" as AnyObject,
            "token" : JFAccountModel.shareAccount()!.token! as AnyObject,
            "action" : "UploadAvatar" as AnyObject,
            ]
        
        JFProgressHUD.showWithStatus("正在上传")
        JFNetworkTool.shareNetworkTool.uploadUserAvatar("\(MODIFY_ACCOUNT_INFO)", imagePath: imagePath, parameters: parameters) { (status, result, tipString) in
            print(result ?? "")
            if status == .success {
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
    func saveImageAndGetURL(_ image: UIImage, imageName: NSString) -> URL {
        
        let home = NSHomeDirectory() as NSString
        let docPath = home.appendingPathComponent("Documents") as NSString;
        let fullPath = docPath.appendingPathComponent(imageName as NSString as String);
        let imageData: Data = UIImageJPEGRepresentation(image, 0.5)!
        try? imageData.write(to: URL(fileURLWithPath: fullPath as String), options: [])
        return URL(fileURLWithPath: fullPath)
    }
    
}

// MARK: - JFShareViewDelegate
extension JFProfileViewController: JFShareViewDelegate {
    
    func share(type: JFShareType) {
        
        let platformType: SSDKPlatformType!
        switch type {
        case .qqFriend:
            platformType = SSDKPlatformType.subTypeQZone // 尼玛，这竟然是反的。。ShareSDK bug
        case .qqQzone:
            platformType = SSDKPlatformType.subTypeQQFriend // 尼玛，这竟然是反的。。
        case .weixinFriend:
            platformType = SSDKPlatformType.subTypeWechatSession
        case .friendCircle:
            platformType = SSDKPlatformType.subTypeWechatTimeline
        }
        
        var image = UIImage(named: "launchScreen")!
        if image.size.width > 300 || image.size.height > 300 {
            image = image.resizeImageWithNewSize(CGSize(width: 300, height: 300 * image.size.height / image.size.width))
        }
        
        let shareParames = NSMutableDictionary()
        shareParames.ssdkSetupShareParams(byText: "爆侃网文精心打造网络文学互动平台，专注最新文学市场动态，聚焦第一手网文圈资讯！",
                                          images : image,
                                          url : URL(string:"http://www.baokan.tv/wapapp/index.html"),
                                          title : "爆侃网文让您的网文之路不再孤单！",
                                          type : SSDKContentType.auto)
        
        ShareSDK.share(platformType, parameters: shareParames) { (state, _, entity, error) in
            switch state {
            case SSDKResponseState.success:
                print("分享成功")
            case SSDKResponseState.fail:
                print("授权失败,错误描述:\(error)")
            case SSDKResponseState.cancel:
                print("操作取消")
            default:
                break
            }
        }
        
    }
}
