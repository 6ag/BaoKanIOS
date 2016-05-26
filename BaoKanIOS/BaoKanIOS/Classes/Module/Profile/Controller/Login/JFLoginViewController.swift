//
//  JFLoginViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/13.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import pop

class JFLoginViewController: UIViewController, JFRegisterViewControllerDelegate {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: JFLoginButton!
    var avatarString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        effectView.frame = SCREEN_BOUNDS
        bgImageView.addSubview(effectView)
        
        didChangeTextField(usernameField)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - JFRegisterViewControllerDelegate
    func registerSuccess(username: String, password: String) {
        usernameField.text = username
        passwordField.text = password
        didChangeTextField(usernameField)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.didTappedLoginButton(self.loginButton)
        }
    }
    
    // 测试账号密码都是：bbsbaokan
    @IBAction func didTappedLoginButton(button: JFLoginButton) {
        
        view.userInteractionEnabled = false
        view.endEditing(true)
        
        // 开始动画
        button.startLoginAnimation()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            
            let parameters = [
                "username" : self.usernameField.text!,
                "password" : self.passwordField.text!
            ]
            
            // 发送登录请求
            JFNetworkTool.shareNetworkTool.post(LOGIN, parameters: parameters) { (success, result, error) in
                if success {
                    if let successResult = result {
                        JFAccountModel.shareAccount().setValuesForKeysWithDictionary(successResult["data"]["user"].dictionaryObject!)
                        JFAccountModel.shareAccount().login()
                        
                        // 如果有值说明是通过第三方登录的
                        if let avatar = self.avatarString {
                            JFAccountModel.shareAccount().avatarUrl = avatar
                        }
                        
                        self.didTappedBackButton()
                    }
                } else if result != nil {
                    JFProgressHUD.showInfoWithStatus(result!["data"]["info"].string!)
                }
                
                // 结束动画
                button.endLoginAnimation()
                self.view.userInteractionEnabled = true
            }
        }
        
    }
    
    @IBAction func didChangeTextField(sender: UITextField) {
        if usernameField.text?.characters.count > 5 && passwordField.text?.characters.count > 5 {
            loginButton.enabled = true
            loginButton.backgroundColor = UIColor(red: 32/255.0, green: 170/255.0, blue: 238/255.0, alpha: 1)
        } else {
            loginButton.enabled = false
            loginButton.backgroundColor = UIColor.grayColor()
        }
    }
    
    @IBAction func didTappedBackButton() {
        view.endEditing(true)
        dismissViewControllerAnimated(true) {}
    }
    
    @IBAction func didTappedRegisterButton(sender: UIButton) {
        let registerVc = JFRegisterViewController(nibName: "JFRegisterViewController", bundle: nil)
        registerVc.delegate = self
        presentViewController(registerVc, animated: true) {}
    }
    
    @IBAction func didTappedForgotButton(sender: UIButton) {
        print("忘记密码")
    }
    
    @IBAction func didTappedQQLoginButton(sender: UIButton) {
        ShareSDK.getUserInfo(SSDKPlatformType.TypeQQ, conditional: nil) { (state, user, error) in
            if state == SSDKResponseState.Success {
                self.SDKLoginHandle(user.nickname, avatar: user.rawData["figureurl_qq_2"] != nil ? user.rawData["figureurl_qq_2"]! as! String : user.icon, uid: user.uid)
            } else {
                self.didTappedBackButton()
            }
        }
    }
    
    @IBAction func didTappedSinaLoginButton(sender: UIButton) {
        ShareSDK.getUserInfo(SSDKPlatformType.TypeSinaWeibo, conditional: nil) { (state, user, error) in
            if state == SSDKResponseState.Success {
                self.SDKLoginHandle(user.nickname, avatar: user.rawData["avatar_hd"] != nil ? user.rawData["avatar_hd"]! as! String : user.icon, uid: user.uid)
            } else {
                self.didTappedBackButton()
            }
        }
    }
    
    /**
     第三方登录授权处理
     
     - parameter nickname: 昵称
     - parameter avatar:   头像url
     - parameter uid:      唯一标识
     */
    func SDKLoginHandle(nickname: String, avatar: String, uid: String) -> Void {
        
        avatarString = avatar
        let string = uid.characters.count >= 12 ? (uid as NSString).substringToIndex(12) : uid
        let lowerString = string.lowercaseString
        
        let parameters = [
            "username" : lowerString,
            "password" : string,
            "email" : "\(lowerString)@baokan.name"
        ]
        
        JFNetworkTool.shareNetworkTool.post(REGISTER, parameters: parameters) { (success, result, error) in
            print(result)
            if success {
                self.usernameField.text = lowerString
                self.passwordField.text = string
                self.didChangeTextField(self.passwordField)
                self.didTappedLoginButton(self.loginButton)
            } else if result != nil {
                if result!["info"].stringValue == "此用户名已被注册" {
                    self.usernameField.text = lowerString
                    self.passwordField.text = string
                    self.didChangeTextField(self.passwordField)
                    self.didTappedLoginButton(self.loginButton)
                } else {
                    JFProgressHUD.showInfoWithStatus(result!["info"].stringValue)
                }
                
            }
        }
    }
    
}
