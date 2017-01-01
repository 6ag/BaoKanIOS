//
//  JFForgotViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/13.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFForgotViewController: UIViewController {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var retrieveButton: JFLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
        effectView.frame = SCREEN_BOUNDS
        bgImageView.addSubview(effectView)
        
        didChangeTextField(usernameField)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func didChangeTextField(_ sender: UITextField) {
        if let username = usernameField.text {
            if let email = emailField.text {
                if username.characters.count > 5 && email.characters.count > 5 {
                    retrieveButton.isEnabled = true
                    retrieveButton.backgroundColor = UIColor(red: 32/255.0, green: 170/255.0, blue: 238/255.0, alpha: 1)
                    return
                }
            }
        }
        retrieveButton.isEnabled = false
        retrieveButton.backgroundColor = UIColor.gray
    }
    
    @IBAction func didTappedBackButton() {
        view.endEditing(true)
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTappedRetrieveButton(_ sender: JFLoginButton) {
        
        view.endEditing(true)
        
        // 开始动画
        sender.startLoginAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            
            let parameters = [
                "username" : self.usernameField.text!,
                "action" : "SendPassword",
                "email" : self.emailField.text!
            ]
            
            // 发送登录请求
            JFNetworkTool.shareNetworkTool.post(MODIFY_ACCOUNT_INFO, parameters: parameters as [String : AnyObject]?) { (success, result, error) in
                if result != nil {
                    if result!["data"]["info"].stringValue == "邮件已发送，请登录邮箱认证并取回密码" {
                        self.dismiss(animated: true, completion: {})
                    }
                    JFProgressHUD.showInfoWithStatus(result!["data"]["info"].stringValue)
                } else {
                    JFProgressHUD.showInfoWithStatus("找回失败，请联系管理员！")
                }
                // 结束动画
                sender.endLoginAnimation()
            }
        }
        
    }
    
}
