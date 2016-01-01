//
//  LLFlowSlideMenuConfig.swift
//  FlowSlideMenu
//
//  Created by LL on 15/11/5.
//  Copyright © 2015 LL. All rights reserved.
//

import UIKit

public struct FlowSlideMenuOptions {
    public static var leftViewWidth: CGFloat = 300.0
    public static var leftBezelWidth: CGFloat = 100.0
    public static var contentViewScale: CGFloat = 1.0
    public static var contentViewOpacity: CGFloat = 0.5
    public static var shadowOpacity: CGFloat = 0.0
    public static var shadowRadius: CGFloat = 0.0
    public static var shadowOffset: CGSize = CGSizeMake(0,0)
    public static var panFromBezel: Bool = true
    public static var animationDuration: CGFloat = 0.5
    public static var hideStatusBar: Bool = false
    public static var pointOfNoReturnWidth: CGFloat = 150.0
    public static var opacityViewBackgroundColor: UIColor = UIColor.blackColor()
}

public struct FlowCurveOptions {
    public static var bgColor : UIColor = UIColor.whiteColor()
    public static var waveMargin : CGFloat = 100
    public static var startRevealY : CGFloat = 300
    public static var animation_reveal:Double = 0.3
    public static var animation_open:Double = 0.1
    public static var animation_damping:CGFloat = 10
    public static var animation_stiffness:CGFloat = 100
    public static var animation_mass:CGFloat = 1
    public static var animation_initialVelocity:CGFloat = 10
}


