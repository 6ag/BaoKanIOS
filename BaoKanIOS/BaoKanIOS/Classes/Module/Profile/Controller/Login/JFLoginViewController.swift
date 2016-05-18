//
//  JFLoginViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/13.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFLoginViewController: UIViewController {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: JFLoginButton!
    
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
    
    // bbsbaokan
    @IBAction func didTappedLoginButton(button: JFLoginButton) {
        
        view.endEditing(true)
        
        // 开始登录动画
        button.startLoginAnimation()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            
            let parameters = ["username" : self.usernameField.text!, "password" : self.passwordField.text!]
            
            // 发送登录请求
            JFNetworkTool.shareNetworkTool.post(LOGIN, parameters: parameters) { (success, result, error) in
                if success {
                    self.didTappedBackButton()
                    if let successResult = result {
                        JFAccountModel.shareAccount().setValuesForKeysWithDictionary(successResult["data"]["user"].dictionaryObject!)
                        JFAccountModel.shareAccount().login()
                    }
                } else {
                    print("登录失败")
                }
                
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
        dismissViewControllerAnimated(true) { 
            
        }
    }
    
    @IBAction func didTappedRegisterButton(sender: UIButton) {
        presentViewController(JFRegisterViewController(nibName: "JFRegisterViewController", bundle: nil), animated: true) {}
    }
    
    @IBAction func didTappedForgotButton(sender: UIButton) {
        print("忘记密码")
    }
    
    @IBAction func didTappedQQLoginButton(sender: UIButton) {
        print("QQ登录")
    }
    
    @IBAction func didTappedWeixinLoginButton(sender: UIButton) {
        print("微信登录")
    }
    
    @IBAction func didTappedSinaLoginButton(sender: UIButton) {
        print("微博登录")
    }
    
    
}

