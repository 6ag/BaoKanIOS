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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
        effectView.frame = SCREEN_BOUNDS
        bgImageView.addSubview(effectView)
        
        // 设置保存的账号
        usernameField.text = UserDefaults.standard.object(forKey: "username") as? String
        passwordField.text = UserDefaults.standard.object(forKey: "password") as? String
        
        didChangeTextField(usernameField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - JFRegisterViewControllerDelegate
    func registerSuccess(_ username: String, password: String) {
        usernameField.text = username
        passwordField.text = password
        didChangeTextField(usernameField)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            self.didTappedLoginButton(self.loginButton)
        }
    }
    
    /**
     登录按钮点击事件
     */
    @IBAction func didTappedLoginButton(_ button: JFLoginButton) {
        
        view.isUserInteractionEnabled = false
        view.endEditing(true)
        
        // 开始动画
        button.startLoginAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            
            var parameters: [String : Any]
            parameters = [
                "username" : self.usernameField.text!,
                "password" : self.passwordField.text!
            ]
            
            // 发送登录请求
            JFNetworkTool.shareNetworkTool.post(LOGIN, parameters: parameters) { (status, result, tipString) in
                
                if status == .success {
                    // 保存账号和密码
                    UserDefaults.standard.set(self.usernameField.text, forKey: "username")
                    UserDefaults.standard.set(self.passwordField.text, forKey: "password")
                    
                    if let successResult = result {
                        let account = JFAccountModel(dict: successResult["data"].dictionaryObject! as [String : AnyObject])
                        // 更新用户本地数据
                        account.updateUserInfo()
                        self.didTappedBackButton()
                    }
                } else if result != nil {
                    guard let result = result else {
                        return
                    }
                    JFProgressHUD.showInfoWithStatus(result["data"].dictionaryValue["info"]!.stringValue)
                }
                
                // 结束动画
                button.endLoginAnimation()
                self.view.isUserInteractionEnabled = true
            }
        }
        
    }
    
    @IBAction func didChangeTextField(_ sender: UITextField) {
        if let username = usernameField.text {
            if let password = passwordField.text {
                if username.characters.count > 5 && password.characters.count > 5 {
                    loginButton.isEnabled = true
                    loginButton.backgroundColor = UIColor(red: 32/255.0, green: 170/255.0, blue: 238/255.0, alpha: 1)
                    return
                }
            }
        }
        loginButton.isEnabled = false
        loginButton.backgroundColor = UIColor.gray
        
    }
    
    @IBAction func didTappedBackButton() {
        view.endEditing(true)
        dismiss(animated: true) {}
    }
    
    @IBAction func didTappedRegisterButton(_ sender: UIButton) {
        let registerVc = JFRegisterViewController(nibName: "JFRegisterViewController", bundle: nil)
        registerVc.delegate = self
        navigationController?.pushViewController(registerVc, animated: true)
    }
    
    @IBAction func didTappedForgotButton(_ sender: UIButton) {
        let forgotVc = JFForgotViewController(nibName: "JFForgotViewController", bundle: nil)
        navigationController?.pushViewController(forgotVc, animated: true)
    }
    
    @IBAction func didTappedQQLoginButton(_ sender: UIButton) {
        ShareSDK.getUserInfo(SSDKPlatformType.typeQQ, conditional: nil) { (state, user, error) in
            if state == SSDKResponseState.success {
                self.SDKLoginHandle((user?.nickname)!, avatar: user?.rawData["figureurl_qq_2"] != nil ? user?.rawData["figureurl_qq_2"]! as! String : (user?.icon)!, uid: (user?.uid)!, type: 1)
            } else {
                self.didTappedBackButton()
            }
        }
    }
    
    @IBAction func didTappedSinaLoginButton(_ sender: UIButton) {
        ShareSDK.getUserInfo(SSDKPlatformType.typeSinaWeibo, conditional: nil) { (state, user, error) in
            if state == SSDKResponseState.success {
                self.SDKLoginHandle((user?.nickname)!, avatar: user?.rawData["avatar_hd"] != nil ? user?.rawData["avatar_hd"]! as! String : (user?.icon)!, uid: (user?.uid)!, type: 2)
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
    func SDKLoginHandle(_ nickname: String, avatar: String, uid: String, type: Int) {
        
        print("nickname = \(nickname) avatar = \(avatar) uid = \(uid)")
        
        let string = uid.characters.count >= 12 ? (uid as NSString).substring(to: 12) : uid
        var lowerString = string.lowercased()
        lowerString = type == 1 ? "qq_\(lowerString)" : "wb_\(lowerString)"
        
        let parameters = [
            "username" : lowerString,
            "password" : string,
            "email" : "\(lowerString)@baokan.name",
            "userpic" : avatar,
            "nickname" : nickname,
            ]
        
        JFNetworkTool.shareNetworkTool.post(REGISTER, parameters: parameters as [String : AnyObject]?) { (status, result, tipString) in
            if status == .success {
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
