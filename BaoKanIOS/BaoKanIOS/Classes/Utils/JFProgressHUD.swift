//
//  JFProgressHUD.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit
import SVProgressHUD

class JFProgressHUD: NSObject {
    
    static func setupProgressHUD() {
        SVProgressHUD.setForegroundColor(UIColor.whiteColor())
        SVProgressHUD.setBackgroundColor(UIColor(colorLiteralRed: 0.1, green: 0, blue: 0, alpha: 0.8))
        SVProgressHUD.setFont(UIFont.boldSystemFontOfSize(16))
    }
    
    class func show() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.None)
        }
    }
    
    class func showWithStatus(status: String!) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.showWithStatus(status, maskType: SVProgressHUDMaskType.None)
        }
    }
    
    class func showInfoWithStatus(status: String!) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.showInfoWithStatus(status, maskType: SVProgressHUDMaskType.None)
        }
    }
    
    class func showSuccessWithStatus(status: String!) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.showSuccessWithStatus(status, maskType: SVProgressHUDMaskType.None)
        }
    }
    
    class func showErrorWithStatus(status: String!) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.showErrorWithStatus(status, maskType: SVProgressHUDMaskType.None)
        }
    }
    
    class func dismiss() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.dismiss()
        }
    }
    
}
