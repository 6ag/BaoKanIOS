//
//  JFRegisterViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/13.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

protocol JFRegisterViewControllerDelegate {
    func registerSuccess(username: String, password: String)
}

class JFRegisterViewController: UIViewController {
    
    @IBOutlet weak var bgImageView: UIImageView!
    
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordView1: UIView!
    @IBOutlet weak var passwordField1: UITextField!
    
    @IBOutlet weak var passwordView2: UIView!
    @IBOutlet weak var passwordField2: UITextField!
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var registerButton: JFLoginButton!
    
    var delegate: JFRegisterViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        effectView.frame = SCREEN_BOUNDS
        bgImageView.addSubview(effectView)
        
        didChangeTextField(usernameField)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func didChangeTextField(sender: UITextField) {
        if usernameField.text?.characters.count > 5 && passwordField1.text?.characters.count > 5 && passwordField2.text?.characters.count > 5 && emailField.text?.characters.count > 5 {
            registerButton.enabled = true
            registerButton.backgroundColor = UIColor(red: 32/255.0, green: 170/255.0, blue: 238/255.0, alpha: 1)
        } else {
            registerButton.enabled = false
            registerButton.backgroundColor = UIColor.grayColor()
        }
    }
    
    @IBAction func didTappedBackButton() {
        view.endEditing(true)
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func didTappedLoginButton(sender: JFLoginButton) {
        
        view.endEditing(true)
        
        if passwordField1.text != passwordField2.text {
            JFProgressHUD.showInfoWithStatus("两次输入的密码不一致")
            return
        }
        
        // 开始动画
        sender.startLoginAnimation()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            
            let parameters = [
                "username" : self.usernameField.text!,
                "password" : self.passwordField1.text!,
                "email" : self.emailField.text!
            ]
            
            // 发送登录请求
            JFNetworkTool.shareNetworkTool.post(REGISTER, parameters: parameters) { (success, result, error) in
                if success {
                    JFProgressHUD.showInfoWithStatus("注册成功，自动登录")
                    self.didTappedBackButton()
                    // 注册成功后回调成功
                    self.delegate?.registerSuccess(self.usernameField.text!, password: self.passwordField1.text!)
                } else if result != nil {
                    JFProgressHUD.showInfoWithStatus(result!["info"].stringValue)
                }
                // 结束动画
                sender.endLoginAnimation()
            }
        }
        
    }
    
}
