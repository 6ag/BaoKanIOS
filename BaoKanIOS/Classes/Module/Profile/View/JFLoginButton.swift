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
        isEnabled = false
        buttonPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), cornerRadius: frame.size.width * 0.5)
        circlePath = UIBezierPath(roundedRect: CGRect(x: frame.size.width * 0.5 - frame.size.height * 0.5, y: 0, width: frame.size.height, height: frame.size.height), cornerRadius: frame.size.height * 0.5)
        
        maskLayer.path = buttonPath.cgPath
        layer.mask = maskLayer
        
        isReverse = true
        maskLayer.add(shapePathAnimationWithFromPath(buttonPath, toPath: circlePath), forKey: "pathAnimation")
    }
    
    func endLoginAnimation() -> Void {
        isEnabled = true
        isReverse = false
        maskLayer.add(shapePathAnimationWithFromPath(buttonPath, toPath: circlePath), forKey: "pathAnimation")
    }
    
    func setupRotate() -> Void {
        rotationPath = UIBezierPath(ovalIn:CGRect(x: frame.size.width * 0.5 - frame.size.height * 0.5, y: 0, width: frame.size.height, height: frame.size.height))
        shapeLayer.frame = CGRect(x: frame.size.width * 0.5 - frame.size.height * 0.5, y: 0, width: frame.size.height, height: frame.size.height)
        shapeLayer.position = CGPoint(x: frame.size.height * 0.5, y: frame.size.height * 0.5)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.strokeColor = UIColor.yellow.cgColor
        shapeLayer.lineCap = "round"
        shapeLayer.lineJoin = "round"
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0
        shapeLayer.path = rotationPath.cgPath
        add = 0.005
        layer.addSublayer(shapeLayer)
        displayLink = CADisplayLink(target: self, selector: #selector(updateRotate))
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
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
    
    func shapePathAnimationWithFromPath(_ fromPath: UIBezierPath, toPath: UIBezierPath) -> CAAnimation {
        if isReverse {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                self.setupRotate()
            }
            let toCircleAnimation = animationWithKeyPath("path", duration: 0.5, fromValue: fromPath.cgPath, toValue: toPath.cgPath)
            return toCircleAnimation
        } else {
            removeLink()
            let toButtonAnimation = animationWithKeyPath("path", duration: 0.5, fromValue: toPath.cgPath, toValue: fromPath.cgPath)
            return toButtonAnimation
        }
    }
    
    func animationWithKeyPath(_ keyPath: String, duration: CFTimeInterval, fromValue: AnyObject, toValue: AnyObject) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.duration = duration
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        return animation
    }
    
    func removeLink() -> Void {
        displayLink.remove(from: RunLoop.main, forMode: RunLoopMode.commonModes)
        displayLink.invalidate()
        shapeLayer.removeFromSuperlayer()
    }
    
}
