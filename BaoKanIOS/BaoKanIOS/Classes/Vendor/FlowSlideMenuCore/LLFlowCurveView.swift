//
//  LLFakeCurveView.swift
//
//  Created by LL on 15/11/1.
//  Copyright © 2015 LL. All rights reserved.
//

import UIKit
import QuartzCore

public class LLFlowCurveView : UIView
{
    weak public var delegate: LLFlowCurveViewDelegate?
    
    public var animating : Bool = false
    
    public enum Status {
        case OPEN_MANUAL
        case OPEN_ANI_ALL
        case OPEN_ANI_TO_HALF
        case OPEN_ANI_TO_BOUNCE
        case OPEN_BOUNCE
        case OPEN_FINISH
        case CLOSE
    }
    
    var bgColor : UIColor = UIColor.blueColor()
    
    var startpoint : CGPoint = CGPoint.zero
    var endPoint : CGPoint = CGPoint.zero
    
    var controlPoint1 : CGPoint = CGPoint.zero
    var controlPoint2 : CGPoint = CGPoint.zero
    var controlPoint3 : CGPoint = CGPoint.zero
    var orientation : Orientation = .Left
    
    var revealPoint : CGPoint = CGPoint.zero
    
    var status : Status = .CLOSE

    var maxRate : CGFloat = 0.3
    
    
    let ANIMATION_KEY_OPENALL : String = "openall"
    let ANIMATION_KEY_OPEN2HALF : String = "open2half"
    let ANIMATION_KEY_OPEN2BOUNCE : String = "open2bounce"
    let ANIMATION_KEY_BOUNCE : String = "bounce"
    
    // MARK: -
    // MARK: lifecycle
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        layer.opaque = false
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func updatePoint(revealPoint:CGPoint,
        orientation:Orientation
        )
    {
        self.revealPoint = revealPoint
        self.setNeedsDisplay()
    }

    public func updatePointKVO(x:CGFloat,
        orientation:Orientation
        )
    {
        if(self.status == Status.OPEN_ANI_ALL)
        {
            self.revealPoint = CGPointMake(x, FlowCurveOptions.startRevealY)
            self.setNeedsDisplay()
        }
    }
    
    public func updatePointTimer()
    {
        if(self.status == Status.OPEN_ANI_ALL)
        {
            let offset : CGFloat = self.getWidth() + self.frame.origin.x
            self.revealPoint = CGPointMake(offset, FlowCurveOptions.startRevealY)
            self.setNeedsDisplay()
//            if(offset > self.getWidth()/2)
//            {
//                stopTimer()
//                open()
//                return
//            }
        }
    }
    
    public override func drawRect(rect: CGRect)
    {
        if(self.status == .CLOSE)
        {
            return
        }
        computePointsForStatus(self.status)
        
        let context : CGContext = UIGraphicsGetCurrentContext()!
        
        CGContextSetStrokeColorWithColor(context, FlowCurveOptions.bgColor.CGColor)
        CGContextSetLineWidth(context, 10)
        CGContextSetFillColorWithColor(context, FlowCurveOptions.bgColor.CGColor)

        let path : UIBezierPath = UIBezierPath()
        
        path.moveToPoint(CGPointZero)
        path.addLineToPoint(self.startpoint)
            
        path.moveToPoint(self.startpoint)
            
        path.addCurveToPoint(self.controlPoint2, controlPoint1:self.controlPoint1, controlPoint2:CGPointMake(self.controlPoint2.x, self.controlPoint1.y))
        path.addLineToPoint(CGPointMake(0, self.controlPoint2.y))
        path.addLineToPoint(CGPointZero)

        path.moveToPoint(self.controlPoint2)
        path.addCurveToPoint(self.endPoint, controlPoint1:CGPointMake(self.controlPoint2.x, self.controlPoint3.y), controlPoint2:self.controlPoint3)
            
        path.moveToPoint(self.endPoint)
        path.addLineToPoint(CGPointMake(0, self.getHeight()))
        path.addLineToPoint(CGPointMake(0, self.controlPoint2.y))
        path.addLineToPoint(self.controlPoint2)
        
        path.stroke()
        path.fill()
    }

    public override class func layerClass() -> AnyClass
    {
        return LLFlowLayer.classForCoder()
    }
    
    // MARK: -
    // MARK: private funs
    
    // MARK: compute points funs
    
    private func computePointsForStatus(_status:Status)
    {
        
        switch(_status)
        {
            case .OPEN_MANUAL :
                computePoints()
            case .OPEN_ANI_ALL :
                let layer :LLFlowLayer = self.layer.presentationLayer() as! LLFlowLayer
                self.revealPoint = CGPointMake(layer.reveal, self.revealPoint.y)
                computePoints()
            case .OPEN_ANI_TO_HALF :
                let layer :LLFlowLayer = self.layer.presentationLayer() as! LLFlowLayer
                self.revealPoint = CGPointMake(layer.reveal, self.revealPoint.y)
                computePoints()
            case .OPEN_ANI_TO_BOUNCE :
                let layer :LLFlowLayer = self.layer.presentationLayer() as! LLFlowLayer
                self.startpoint = CGPointMake(layer.start, self.startpoint.y)
                self.endPoint = CGPointMake(layer.start, self.endPoint.y)
                self.controlPoint1 = CGPointMake(layer.control, self.controlPoint1.y)
                self.controlPoint3 = CGPointMake(layer.control, self.controlPoint3.y)
            case .OPEN_BOUNCE :
                let layer :LLFlowLayer = self.layer.presentationLayer() as! LLFlowLayer
                self.controlPoint2 = CGPointMake(layer.reveal, self.controlPoint2.y)
                self.startpoint = CGPointMake(layer.start, self.startpoint.y)
                self.endPoint = CGPointMake(layer.start, self.endPoint.y)
                self.controlPoint1 = CGPointMake(layer.control, self.controlPoint1.y)
                self.controlPoint3 = CGPointMake(layer.control, self.controlPoint3.y)
            default:
                break
        }
        /*if (animating){
            let layer :LLFlowLayer = self.layer.presentationLayer() as! LLFlowLayer
            
            self.revealPoint = CGPointMake(layer.reveal, self.revealPoint.y)
            
            if(self.status == .OPEN_ANI_TO_BOUNCE)
            {
                self.controlPoint1 = CGPointMake(layer.control, self.controlPoint1.y)
                self.controlPoint3 =  CGPointMake(layer.control, self.controlPoint3.y)
                self.startpoint = CGPointMake(layer.start, self.startpoint.y)
                self.endPoint =  CGPointMake(layer.start, self.endPoint.y)
                
            }
            if(self.status == .OPEN_ALL)
            {
                computePoints()
            }
        }else
        {
            computePoints()
        }
        */
    }
    /*

    private func computeControlPoint(point : CGPoint , bottom : Bool) -> CGPoint
    {
        if(self.status == .OPEN_FINISH)
        {
            return CGPointMake(self.getWidth(), point.y)
        }
        if(bottom)
        {
            if(isSticky())
            {
                if(status == .OPEN_ANI_TO_BOUNCE)
                {
                    return CGPointMake(self.startpoint.x, point.y)
                }
                var a : CGFloat =  revealPoint.x/self.getWidth()*2
                a = 1 - a
                if(a < maxRate)
                {
                    a = maxRate
                }
                return CGPointMake((getMidPointX()-self.revealPoint.x*a), point.y)
            }
            let a : CGFloat =  revealPoint.x/self.controlPoint1.x
            let maxRatio :CGFloat = 0.7
            if(a > maxRatio && status != .OPEN_ANI_TO_BOUNCE )
            {
                return CGPointMake(getMidPointX() * maxRatio, point.y)
            }
            return CGPointMake(getMidPointX()*a , point.y)
        }
        if(isSticky() && status == .OPEN_ANI_TO_BOUNCE)
        {
            return CGPointMake(self.controlPoint2.x, point.y)
        }
       return CGPointMake(self.getMidPointX(), point.y)
    }
    */
    
    private func getWaveWidth() -> CGFloat
    {
        return getHeight()
    }
    
    public func getWidth() -> CGFloat
    {
        return self.frame.size.width - FlowCurveOptions.waveMargin
    }
    
    private func getHeight() -> CGFloat
    {
        return self.frame.size.height
    }
    
    private func getStartPoint() -> CGPoint
    {
        var x :CGFloat = self.getWidth() - self.revealPoint.x
        let y :CGFloat = 0
        
        if(x < 0)
        {
            x = 0
        }
        if(self.status == .OPEN_ANI_ALL)
        {
            return CGPointZero
        }
        if(self.status == .OPEN_FINISH)
        {
            return CGPointMake(getWidth(), y)
        }
        return CGPointMake(x,y)
    }
    
    private func getEndPoint() -> CGPoint
    {
    
        var x = self.getWidth() - self.revealPoint.x
        let y = self.getHeight()
        
        if(self.status == .OPEN_ANI_ALL)
        {
            return CGPointMake(0, self.getHeight())
        }
        
        if(x < 0)
        {
            x = 0
        }
        
        if(self.status == .OPEN_FINISH)
        {
            return CGPointMake(getWidth(), y)
        }
        return CGPointMake(x,y)
    }
    
    private func getControlPoint1InOpenAllWithRevealPoint(revealPoint:CGPoint) -> CGPoint
    {
        let y = revealPoint.y - (getWaveWidth()/5 * revealPoint.x/self.getWidth()) - getWaveWidth()/20
        return CGPointMake(revealPoint.x/2, y)
    }
    
    private func getControlPoint3InOpenAllWithRevealPoint(revealPoint:CGPoint) -> CGPoint
    {
        let y = revealPoint.y + (getWaveWidth()/5 * revealPoint.x/self.getWidth()) + getWaveWidth()/20
        return CGPointMake(revealPoint.x/2, y)
    }
    
    private func getControlPoint1() -> CGPoint
    {
        var x = getMidPointX() - (self.revealPoint.x/1.5)
        var y = getMidPointY() - (getWaveWidth()/10 * self.revealPoint.x/self.getWidth()) - getWaveWidth()/20
        
        if(self.status == .OPEN_ANI_ALL)
        {
            y = getMidPointY() - (getWaveWidth()/5 * self.revealPoint.x/self.getWidth()) - getWaveWidth()/20
            return CGPointMake(self.revealPoint.x/2, y)
        }
        if(x < getStartPoint().x)
        {
            x = getStartPoint().x
        }
        if(self.status == .OPEN_FINISH)
        {
            return CGPointMake(getWidth(), y)
        }
        return CGPointMake(x,y)
    }
    
    public func getControlPoint2() -> CGPoint
    {
        let x : CGFloat = self.getMidPointX()
        let y : CGFloat = self.revealPoint.y
        
        if(self.status == .OPEN_FINISH)
        {
            return CGPointMake(getWidth(), y)
        }
        return CGPointMake(x,y)
    }
    
    private func getControlPoint3() -> CGPoint
    {
        var x : CGFloat = getMidPointX() - (self.revealPoint.x/1.5)
        var y : CGFloat = getMidPointY() + (getWaveWidth()/10 * self.revealPoint.x/self.getWidth()) + getWaveWidth()/20
        
        if(self.status == .OPEN_ANI_ALL)
        {
            y = getMidPointY() + (getWaveWidth()/5 * self.revealPoint.x/self.getWidth()) + getWaveWidth()/20
            return CGPointMake(self.revealPoint.x/2, y)
        }
        
        if(x < getStartPoint().x)
        {
            x = getStartPoint().x
        }
        
        if(self.status == .OPEN_FINISH)
        {
            return CGPointMake(getWidth(), y)
        }
        return CGPointMake(x,y)
    }
    
    //start point
    private func getMidPointY() -> CGFloat
    {
        return self.revealPoint.y
    }
    
    //start point
    private func getMidPointX() -> CGFloat
    {
        if(self.status == .OPEN_ANI_ALL)
        {
            return self.revealPoint.x
        }
        return getWidth() - (self.revealPoint.x * 0.3)
    }

    private func computePoints()
    {
        self.startpoint = self.getStartPoint()
        self.endPoint = self.getEndPoint()
        self.controlPoint1 = self.getControlPoint1()
        self.controlPoint2 = self.getControlPoint2()
        self.controlPoint3 = self.getControlPoint3()
    }

    private func getTo1(float:CGFloat) -> CGFloat
    {
        let to : CGFloat = getWidth() - float
        return to
    }
    
    private func getTo1() -> CGFloat
    {
        let to : CGFloat = getWidth()
        return to
    }
    
    private func getAnimationToHalf() -> CGFloat
    {
        let to : CGFloat = getWidth()*1/2
        return to
    }
    
    private func getAnimationToHalfPoint() -> CGPoint
    {
        let to : CGFloat = getWidth()*1/2
        return CGPointMake(to, FlowCurveOptions.startRevealY)
    }
    
    private func reset()
    {
        self.revealPoint = CGPointZero
        self.animating = false
    }
    
    // MARK: get animation
    private func getSpringAnimationWithTo(to:Float,from:Float,name:String) ->CASpringAnimation
    {
        let animation:CASpringAnimation = CASpringAnimation(keyPath: name)
        animation.toValue = Float(to)
        animation.fromValue = Float(from)
        animation.damping = FlowCurveOptions.animation_damping
        animation.duration = 0.5
        animation.stiffness = FlowCurveOptions.animation_stiffness
        animation.mass = FlowCurveOptions.animation_mass
        animation.initialVelocity = FlowCurveOptions.animation_initialVelocity
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        animation.removedOnCompletion = false
        return animation
    }
    
    private func getAnimationWithTo(to:Float,from:Float,duration:Float,name:String) ->CABasicAnimation
    {
        let animation:CABasicAnimation = CABasicAnimation(keyPath: name)
        animation.toValue = Float(to)
        animation.fromValue = Float(from)
        animation.duration = Double(duration)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        return animation
    }

    // MARK: animations
    private func openAll(delay:Double)
    {
        let ani_reveal : CABasicAnimation = getAnimationWithTo(Float(self.getAnimationToHalf()
            ),from: Float(0),duration:Float(FlowCurveOptions.animation_reveal),name: LLFlowLayer.KEY_REVEAL)
        
        self.revealPoint = CGPointMake(0,FlowCurveOptions.startRevealY)
        
        ani_reveal.delegate = self
        
        ani_reveal.beginTime = CACurrentMediaTime() + delay
        
        self.layer.addAnimation(ani_reveal, forKey:ANIMATION_KEY_OPENALL)
    }
    
    private func openToHalf(delay:Double)
    {
        let ani_reveal : CABasicAnimation = getAnimationWithTo(Float(self.getWidth()/2
            ),from: Float(0),duration:Float(FlowCurveOptions.animation_reveal),name: LLFlowLayer.KEY_REVEAL)
        
        self.revealPoint = CGPointMake(0,FlowCurveOptions.startRevealY)
        
        ani_reveal.delegate = self
        
        ani_reveal.beginTime = CACurrentMediaTime() + delay
        
        self.layer.addAnimation(ani_reveal, forKey: ANIMATION_KEY_OPEN2HALF)
    }
    
    private func openToBounce(delay:Double)
    {
        let ani_controlpoint : CASpringAnimation = getSpringAnimationWithTo(Float(getTo1()),from: Float(self.controlPoint1.x),name:LLFlowLayer.KEY_CONTROL)
        let ani_startpoint : CASpringAnimation = getSpringAnimationWithTo(Float(getTo1()),from: Float(self.startpoint.x),name: LLFlowLayer.KEY_START)
        
        ani_controlpoint.beginTime = CACurrentMediaTime() + delay
        
        ani_controlpoint.delegate = self
        
        self.layer.addAnimation(ani_controlpoint, forKey: ANIMATION_KEY_OPEN2BOUNCE)
        self.layer.addAnimation(ani_startpoint, forKey: ANIMATION_KEY_OPEN2BOUNCE + "1")
    }
    
    private func openToBounce(delay:Double,from:CGFloat)
    {
        let ani_controlpoint : CASpringAnimation = getSpringAnimationWithTo(Float(getTo1()),from: Float(self.getControlPoint1InOpenAllWithRevealPoint(self.getAnimationToHalfPoint()).x),name:LLFlowLayer.KEY_CONTROL)
        let ani_startpoint : CASpringAnimation = getSpringAnimationWithTo(Float(getTo1()),
            from: Float(0),
            name: LLFlowLayer.KEY_START)
        
        ani_controlpoint.beginTime = CACurrentMediaTime() + delay
        
        ani_controlpoint.delegate = self
        
        self.layer.addAnimation(ani_controlpoint, forKey: ANIMATION_KEY_OPEN2BOUNCE)
        self.layer.addAnimation(ani_startpoint, forKey: ANIMATION_KEY_OPEN2BOUNCE + "1")
    }
    
    private func bounce(delay:Double,from:CGFloat) {
        
        let ani_reveal  : CASpringAnimation = getSpringAnimationWithTo(Float(getTo1()),from:Float(from),name:LLFlowLayer.KEY_REVEAL)
        
        ani_reveal.delegate = self
        
        ani_reveal.beginTime = CACurrentMediaTime() + delay
        
        self.layer.addAnimation(ani_reveal, forKey: ANIMATION_KEY_BOUNCE)
    }
    
    private func bounce(delay:Double) {
        
        let ani_reveal  : CASpringAnimation = getSpringAnimationWithTo(Float(getTo1()),from:Float(revealPoint.x),name:LLFlowLayer.KEY_REVEAL)
        
        ani_reveal.delegate = self
        
        ani_reveal.beginTime = CACurrentMediaTime() + delay
        
        self.layer.addAnimation(ani_reveal, forKey: ANIMATION_KEY_BOUNCE)
    }
    
    private func finish()
    {
        if (self.layer.animationKeys() != nil && (self.layer.animationKeys()!.count > 0))
        {
            layer.removeAllAnimations()
            self.animating = false
            reset()
            self.status = .OPEN_FINISH
            notifyDelegateAnimationEnd()
        }
    }
    
    
    private func notifyDelegateAnimationStart()
    {
        if(self.delegate != nil)
        {
            self.delegate?.flowViewStartAnimation(self)
        }
    }
    
    private func notifyDelegateAnimationEnd()
    {
        if(self.delegate != nil)
        {
            self.delegate?.flowViewEndAnimation(self)
        }
    }
    
    // MARK: -
    // MARK: public funs
    public func openAll()
    {
        if(self.animating == true)
        {
            return
        }
        
        notifyDelegateAnimationStart()
        
        self.animating = true
        
        self.status = .OPEN_ANI_ALL
      
        self.layer.removeAllAnimations()
        
        openAll(0.0)
        
        openToBounce(FlowCurveOptions.animation_reveal,from:self.getAnimationToHalf())
        
        bounce(FlowCurveOptions.animation_open + FlowCurveOptions.animation_reveal,from:self.getAnimationToHalf())
    }
    
    public func open() {
    
        if(self.status != .OPEN_MANUAL)
        {
            return
        }
        self.layer.removeAllAnimations()
        
        notifyDelegateAnimationStart()
        
        self.animating = true
        
        openToBounce(0)
        
        bounce(FlowCurveOptions.animation_open)
    }
    
    public func start()
    {
        if(self.status == .CLOSE)
        {
            self.status = .OPEN_MANUAL
            self.frame.origin.x = self.frame.origin.x + FlowCurveOptions.waveMargin
        }
    }
    
    public func close()
    {
        self.layer.removeAllAnimations()
        self.status = .CLOSE
        self.reset()
    }
    
    // MARK: -
    // MARK: caanimation delegate
    
    public override func animationDidStop(anim: CAAnimation, finished flag: Bool)
    {
        if(anim == self.layer.animationForKey(ANIMATION_KEY_BOUNCE))
        {
            finish()
        }
    }
    
    public override func animationDidStart(anim: CAAnimation) {

        if(anim == self.layer.animationForKey(ANIMATION_KEY_OPEN2HALF))
        {
            self.status = .OPEN_ANI_TO_HALF
        }else if(anim == self.layer.animationForKey(ANIMATION_KEY_BOUNCE))
        {
            self.status = .OPEN_BOUNCE
        }else if(anim == self.layer.animationForKey(ANIMATION_KEY_OPEN2BOUNCE))
        {
            self.status = .OPEN_ANI_TO_BOUNCE
        }
    }
    
}
