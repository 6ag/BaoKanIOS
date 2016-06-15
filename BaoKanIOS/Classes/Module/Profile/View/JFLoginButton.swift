//
//  JFLoginButton.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/17.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFLoginButton: UIButton {
    
    var isReverse = false
    var maskLayer = CAShapeLayer()
    var buttonPath = UIBezierPath()
    var circlePath = UIBezierPath()
    
    var rotationPath = UIBezierPath()
    var shapeLayer = CAShapeLayer()
    var add: CGFloat = 0.005
    var displayLink = CADisplayLink()
    
    /**
     开始登录动画
     */
    func startLoginAnimation() -> Void {
        enabled = false
        buttonPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), cornerRadius: frame.size.width * 0.5)
        circlePath = UIBezierPath(roundedRect: CGRect(x: frame.size.width * 0.5 - frame.size.height * 0.5, y: 0, width: frame.size.height, height: frame.size.height), cornerRadius: frame.size.height * 0.5)
        
        maskLayer.path = buttonPath.CGPath
        layer.mask = maskLayer
        
        isReverse = true
        maskLayer.addAnimation(shapePathAnimationWithFromPath(buttonPath, toPath: circlePath), forKey: "pathAnimation")
    }
    
    func endLoginAnimation() -> Void {
        enabled = true
        isReverse = false
        maskLayer.addAnimation(shapePathAnimationWithFromPath(buttonPath, toPath: circlePath), forKey: "pathAnimation")
    }
    
    func setupRotate() -> Void {
        rotationPath = UIBezierPath(ovalInRect:CGRect(x: frame.size.width * 0.5 - frame.size.height * 0.5, y: 0, width: frame.size.height, height: frame.size.height))
        shapeLayer.frame = CGRect(x: frame.size.width * 0.5 - frame.size.height * 0.5, y: 0, width: frame.size.height, height: frame.size.height)
        shapeLayer.position = CGPoint(x: frame.size.height * 0.5, y: frame.size.height * 0.5)
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.lineWidth = 3
        shapeLayer.strokeColor = UIColor.yellowColor().CGColor
        shapeLayer.lineCap = "round"
        shapeLayer.lineJoin = "round"
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0
        shapeLayer.path = rotationPath.CGPath
        add = 0.005
        layer.addSublayer(shapeLayer)
        displayLink = CADisplayLink(target: self, selector: #selector(updateRotate))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    func updateRotate() -> Void {
        
        if (shapeLayer.strokeEnd > 1 && shapeLayer.strokeStart < 1) {
            shapeLayer.strokeStart += add
        } else if(shapeLayer.strokeStart == 0) {
            shapeLayer.strokeEnd += add
        } else {
            shapeLayer.strokeStart = 0
            shapeLayer.strokeEnd = 0
        }
    }
    
    func shapePathAnimationWithFromPath(fromPath: UIBezierPath, toPath: UIBezierPath) -> CAAnimation {
        if isReverse {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.setupRotate()
            }
            let toCircleAnimation = animationWithKeyPath("path", duration: 0.5, fromValue: fromPath.CGPath, toValue: toPath.CGPath)
            return toCircleAnimation
        } else {
            removeLink()
            let toButtonAnimation = animationWithKeyPath("path", duration: 0.5, fromValue: toPath.CGPath, toValue: fromPath.CGPath)
            return toButtonAnimation
        }
    }
    
    func animationWithKeyPath(keyPath: String, duration: CFTimeInterval, fromValue: AnyObject, toValue: AnyObject) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.duration = duration
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        return animation
    }
    
    func removeLink() -> Void {
        displayLink.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        displayLink.invalidate()
        shapeLayer.removeFromSuperlayer()
    }
    
}
