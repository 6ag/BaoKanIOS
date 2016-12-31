//
//  JFProfileFeedbackViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/26.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFProfileFeedbackViewController: JFBaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        
        let headerView = UIView()
        headerView.frame = view.bounds
        headerView.backgroundColor = BACKGROUND_COLOR
        headerView.addSubview(contentTextView)
        headerView.addSubview(contactTextField)
        headerView.addSubview(commitButton)
        tableView.tableHeaderView = headerView
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeValueForContentTextView(_:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    
    /**
     内容文本改变事件
     */
    @objc fileprivate func didChangeValueForContentTextView(_ notification: Notification) {
        changeCommitState()
    }
    
    /**
     联系人文本改变事件
     */
    @objc fileprivate func didChangeValueForContactTextField(_ field: UITextField) {
        changeCommitState()
    }
    
    /**
     提交按钮点击事件
     */
    @objc fileprivate func didTappedCommitButton(_ commitButton: UIButton) {
        
        tableView.isUserInteractionEnabled = false
        
        JFProgressHUD.showWithStatus("正在提交")
        
        let parameters = [
            "content" : contentTextView.text,
            "contact" : contactTextField.text!
        ] as [String : Any]
        
        JFNetworkTool.shareNetworkTool.post("http://120.24.79.174/jiansan/feedback.php", parameters: parameters as [String : AnyObject]?) { (success, result, error) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                
                self.tableView.isUserInteractionEnabled = true
                
                JFProgressHUD.showSuccessWithStatus("谢谢支持")
                
                // 返回上一级控制器
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
                    _ = self.navigationController?.popViewController(animated: true)
                    
                }
                
            }
        }
    }
    
    /**
     改变提交按钮状态
     */
    fileprivate func changeCommitState() {
        
        if contentTextView.text.characters.count >= 10 && (contactTextField.text?.characters.count)! >= 5 {
            commitButton.isEnabled = true
            commitButton.backgroundColor = UIColor(red:0.871,  green:0.259,  blue:0.294, alpha:1)
        } else {
            commitButton.isEnabled = false
            commitButton.backgroundColor = UIColor(red:0.733,  green:0.733,  blue:0.733, alpha:1)
        }
        
    }
    
    /// 内容文本框
    lazy var contentTextView: UITextView = {
        let contentTextView = UITextView(frame: CGRect(x: MARGIN, y: 10, width: SCREEN_WIDTH - MARGIN * 2, height: 200))
        contentTextView.layer.cornerRadius = CORNER_RADIUS
        
        return contentTextView
    }()
    
    /// 联系方式文本框
    lazy var contactTextField: UITextField = {
        let contactTextField = UITextField(frame: CGRect(x: MARGIN, y: self.contentTextView.frame.maxY + MARGIN, width: SCREEN_WIDTH - MARGIN * 2, height: 40))
        contactTextField.layer.cornerRadius = CORNER_RADIUS
        contactTextField.backgroundColor = UIColor.white
        contactTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: MARGIN, height: 0))
        contactTextField.attributedPlaceholder = NSAttributedString(string: "请输入您的联系方式 QQ/Email/手机", attributes: [
            NSForegroundColorAttributeName : UIColor(red:0.833,  green:0.833,  blue:0.833, alpha:1),
            NSFontAttributeName : UIFont.systemFont(ofSize: 14)
            ])
        contactTextField.leftViewMode = .always
        contactTextField.addTarget(self, action: #selector(didChangeValueForContactTextField(_:)), for: UIControlEvents.editingChanged)
        return contactTextField
    }()
    
    /// 提交按钮
    lazy var commitButton: UIButton = {
        let commitButton = UIButton(type: UIButtonType.system)
        commitButton.frame = CGRect(x: MARGIN, y: self.contactTextField.frame.maxY + MARGIN, width: SCREEN_WIDTH - MARGIN * 2, height: 40)
        commitButton.setTitle("提交", for: UIControlState())
        commitButton.setTitleColor(UIColor.white, for: UIControlState())
        commitButton.layer.cornerRadius = CORNER_RADIUS
        commitButton.isEnabled = false
        commitButton.backgroundColor = UIColor(red:0.733,  green:0.733,  blue:0.733, alpha:1)
        commitButton.addTarget(self, action: #selector(didTappedCommitButton(_:)), for: UIControlEvents.touchUpInside)
        return commitButton
    }()

}
