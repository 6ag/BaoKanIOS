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
    
    let imagePickerC = UIImagePickerController()
    
    override init(style: UITableViewStyle) {
        super.init(style: UITableViewStyle.Grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = footerView
        
        let group1CellModel1 = JFProfileCellModel(title: "头像")
        group1CellModel1.operation = {() -> Void in
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
        }
        let group1CellModel2 = JFProfileCellModel(title: "用户名:")
        let group1CellModel3 = JFProfileCellModel(title: "昵称:")
        let group1CellModel4 = JFProfileCellModel(title: "联系电话:")
        let group1CellModel5 = JFProfileCellModel(title: "QQ号码:")
        let group1CellModel6 = JFProfileCellModel(title: "个性签名:")
        let group1 = JFProfileCellGroupModel(cells: [group1CellModel1, group1CellModel2, group1CellModel3, group1CellModel4, group1CellModel5, group1CellModel6])
        groupModels = [group1]
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
     点击了保存
     */
    func didTappedSaveButton(button: UIButton) {
        
        let parameters: [String : AnyObject] = [
            "username" : JFAccountModel.shareAccount()!.username!,
            "userid" : JFAccountModel.shareAccount()!.id,
            "token" : JFAccountModel.shareAccount()!.token!,
            "action" : "EditInfo",
            "nickname" : nicknameField.text!,
            "qq" : qqField.text!,
            "phone" : phoneNumberField.text!,
            "saytext" : signField.text!
        ]
        
        JFNetworkTool.shareNetworkTool.post(MODIFY_ACCOUNT_INFO, parameters: parameters) { (success, result, error) in
            if success {
                JFProgressHUD.showSuccessWithStatus("修改资料成功")
                self.navigationController?.popViewControllerAnimated(true)
                
                // 修改资料成功需要重新更新资料
                JFAccountModel.checkUserInfo({})
            } else {
                JFProgressHUD.showInfoWithStatus("修改失败，请联系管理员！")
            }
        }
    }
    
    /// 尾部保存视图
    private lazy var footerView: UIView = {
        let logoutButton = UIButton(frame: CGRect(x: 20, y: 0, width: SCREEN_WIDTH - 40, height: 44))
        logoutButton.addTarget(self, action: #selector(didTappedSaveButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        logoutButton.setTitle("保存修改", forState: UIControlState.Normal)
        logoutButton.backgroundColor = NAVIGATIONBAR_RED_COLOR
        logoutButton.layer.cornerRadius = CORNER_RADIUS
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
        footerView.addSubview(logoutButton)
        return footerView
    }()
    
    private lazy var usernameField: UITextField = {
        let field = UITextField(frame: CGRect(x: 100, y: 0, width: SCREEN_WIDTH - 120, height: 44))
        field.enabled = false
        field.font = UIFont.systemFontOfSize(14)
        field.textColor = UIColor.grayColor()
        return field
    }()
    
    private lazy var nicknameField: UITextField = {
        let field = UITextField(frame: CGRect(x: 100, y: 0, width: SCREEN_WIDTH - 120, height: 44))
        field.font = UIFont.systemFontOfSize(14)
        field.placeholder = "昵称"
        field.clearButtonMode = .WhileEditing
        return field
    }()
    
    private lazy var phoneNumberField: UITextField = {
        let field = UITextField(frame: CGRect(x: 100, y: 0, width: SCREEN_WIDTH - 120, height: 44))
        field.font = UIFont.systemFontOfSize(14)
        field.placeholder = "联系电话"
        field.clearButtonMode = .WhileEditing
        return field
    }()
    
    private lazy var qqField: UITextField = {
        let field = UITextField(frame: CGRect(x: 100, y: 0, width: SCREEN_WIDTH - 120, height: 44))
        field.font = UIFont.systemFontOfSize(14)
        field.placeholder = "QQ号"
        field.clearButtonMode = .WhileEditing
        return field
    }()
    
    private lazy var signField: UITextField = {
        let field = UITextField(frame: CGRect(x: 100, y: 0, width: SCREEN_WIDTH - 120, height: 44))
        field.font = UIFont.systemFontOfSize(14)
        field.placeholder = "个性签名"
        field.clearButtonMode = .WhileEditing
        return field
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView(frame: CGRect(x: SCREEN_WIDTH - 70, y: 10, width: 50, height: 50))
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.layer.masksToBounds = true
        return avatarImageView
    }()
}

extension JFModifyInfoTableViewController {
    
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
        cell.selectionStyle = .None
        switch indexPath.row {
        case 0:
            avatarImageView.yy_setImageWithURL(NSURL(string: JFAccountModel.shareAccount()!.avatarUrl!), options: YYWebImageOptions.AllowBackgroundTask)
            cell.contentView.addSubview(avatarImageView)
            return cell
        case 1:
            usernameField.text = JFAccountModel.shareAccount()!.username!
            cell.contentView.addSubview(usernameField)
            return cell
        case 2:
            nicknameField.text = JFAccountModel.shareAccount()!.nickname!
            cell.contentView.addSubview(nicknameField)
            return cell
        case 3:
            phoneNumberField.text = JFAccountModel.shareAccount()!.phone!
            cell.contentView.addSubview(phoneNumberField)
            return cell
        case 4:
            qqField.text = JFAccountModel.shareAccount()!.qq!
            cell.contentView.addSubview(qqField)
            return cell
        case 5:
            signField.text = JFAccountModel.shareAccount()!.saytext!
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
}

// MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension JFModifyInfoTableViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
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
                    self.tableView.reloadData()
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
