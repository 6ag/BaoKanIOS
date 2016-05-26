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
    
    class func setupHUD() {
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.Custom)
        SVProgressHUD.setForegroundColor(UIColor.whiteColor())
        SVProgressHUD.setBackgroundColor(UIColor(white: 0.0, alpha: 0.8))
        SVProgressHUD.setFont(UIFont.boldSystemFontOfSize(16))
        SVProgressHUD.setMinimumDismissTimeInterval(2.0)
        
            /*
        + (void)setDefaultStyle:(SVProgressHUDStyle)style;                  // default is SVProgressHUDStyleLight
        + (void)setDefaultMaskType:(SVProgressHUDMaskType)maskType;         // default is SVProgressHUDMaskTypeNone
        + (void)setDefaultAnimationType:(SVProgressHUDAnimationType)type;   // default is SVProgressHUDAnimationTypeFlat
        + (void)setMinimumSize:(CGSize)minimumSize;                         // default is CGSizeZero, can be used to avoid resizing for a larger message
        + (void)setRingThickness:(CGFloat)width;                            // default is 2 pt
        + (void)setRingRadius:(CGFloat)radius;                              // default is 18 pt
        + (void)setRingNoTextRadius:(CGFloat)radius;                        // default is 24 pt
        + (void)setCornerRadius:(CGFloat)cornerRadius;                      // default is 14 pt
        + (void)setFont:(UIFont*)font;                                      // default is [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
        + (void)setForegroundColor:(UIColor*)color;                         // default is [UIColor blackColor], only used for SVProgressHUDStyleCustom
        + (void)setBackgroundColor:(UIColor*)color;                         // default is [UIColor whiteColor], only used for SVProgressHUDStyleCustom
        + (void)setBackgroundLayerColor:(UIColor*)color;                    // default is [UIColor colorWithWhite:0 alpha:0.4], only used for SVProgressHUDMaskTypeCustom
        + (void)setInfoImage:(UIImage*)image;                               // default is the bundled info image provided by Freepik
        + (void)setSuccessImage:(UIImage*)image;                            // default is bundled success image from Freepik
        + (void)setErrorImage:(UIImage*)image;                              // default is bundled error image from Freepik
        + (void)setViewForExtension:(UIView*)view;                          // default is nil, only used if #define SV_APP_EXTENSIONS is set
        + (void)setMinimumDismissTimeInterval:(NSTimeInterval)interval;     // default is 5.0 seconds
        + (void)setFadeInAnimationDuration:(NSTimeInterval)duration;        // default is 0.15 seconds
        + (void)setFadeOutAnimationDuration:(NSTimeInterval)duration;       // default is 0.15 seconds
            */
    }
    
    class func show() {
        SVProgressHUD.show()
    }
    
    class func showWithStatus(status: String) {
        SVProgressHUD.showWithStatus(status)
    }
    
    class func showInfoWithStatus(status: String) {
        SVProgressHUD.showInfoWithStatus(status)
    }
    
    class func showSuccessWithStatus(status: String) {
        SVProgressHUD.showSuccessWithStatus(status)
    }
    
    class func showErrorWithStatus(status: String) {
        SVProgressHUD.showErrorWithStatus(status)
    }
    
    class func dismiss() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.dismiss()
        }
    }
    
}
