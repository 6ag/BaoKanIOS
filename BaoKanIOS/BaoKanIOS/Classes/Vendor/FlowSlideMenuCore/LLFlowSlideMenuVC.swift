//
//  LLFlowSlideMenuVC
//
//  Created by LL on 15/10/31.
//  Copyright © 2015 LL. All rights reserved.
//

import UIKit
import QuartzCore

public class LLFlowSlideMenuVC : UIViewController, UIGestureRecognizerDelegate, LLFlowCurveViewDelegate
{
    public enum SlideAction {
        case Open
        case Close
    }
    
    struct PanInfo {
        var action: SlideAction
        var shouldBounce: Bool
        var velocity: CGFloat
    }
    
    // MARK: -
    // MARK: parms
    public var leftViewController: UIViewController?
    public var mainViewController: UIViewController?
    
    public var opacityView = UIView()
    public var mainContainerView = UIView()
    public var leftContainerView = LLFlowCurveView()
    
    public var leftPanGesture: UIPanGestureRecognizer?
    public var leftTapGetsture: UITapGestureRecognizer?
    
    private var curContext = 0
    
    // MARK: -
    // MARK: lifecycle
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public convenience init(mainViewController: UIViewController,leftViewController: UIViewController) {
        self.init()
        self.mainViewController = mainViewController
        self.leftViewController = leftViewController
        initView()

        self.leftContainerView.addObserver(self, forKeyPath: "frame", options: .New, context: &curContext)
        self.leftContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didTappedLeftContainerView:"))
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &curContext {
            if let newValue : CGRect = change?[NSKeyValueChangeNewKey]?.CGRectValue{
                
                self.leftContainerView.updatePointKVO(self.leftContainerView.frame.size.width + newValue.origin.x, orientation: Orientation.Left)
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    @objc private func didTappedLeftContainerView(gesture: UITapGestureRecognizer) {
        let point = gesture.locationInView(self.leftContainerView)
        if point.x >= FlowSlideMenuOptions.leftViewWidth {
            self.closeLeft()
        }
    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {

        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        mainContainerView.transform = CGAffineTransformMakeScale(1.0, 1.0)
        leftContainerView.hidden = true
        
        coordinator.animateAlongsideTransition(nil, completion: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.closeLeftNonAnimation()

            self.leftContainerView.hidden = false

            if self.leftPanGesture != nil && self.leftPanGesture != nil {
                self.removeLeftGestures()
                self.addLeftGestures()
            }
            
        })
    }
  
    public override func viewWillLayoutSubviews() {
        setUpViewController(mainContainerView, targetViewController: mainViewController)
        setUpViewController(leftContainerView, targetViewController: leftViewController,slideview: true)
        
    }
    
    deinit {
        self.leftContainerView.removeObserver(self, forKeyPath: "frame", context: &curContext)
    }
    
    // MARK: -
    // MARK: private funs
    
    func initView() {
        mainContainerView = UIView(frame: view.bounds)
        mainContainerView.backgroundColor = UIColor.clearColor()
        mainContainerView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        view.insertSubview(mainContainerView, atIndex: 0)
        
        var opacityframe: CGRect = view.bounds
        let opacityOffset: CGFloat = 0
        opacityframe.origin.y = opacityframe.origin.y + opacityOffset
        opacityframe.size.height = opacityframe.size.height - opacityOffset
        opacityView = UIView(frame: opacityframe)
        opacityView.backgroundColor = FlowSlideMenuOptions.opacityViewBackgroundColor
        opacityView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        opacityView.layer.opacity = 0.0
        view.insertSubview(opacityView, atIndex: 1)
        
        var leftFrame: CGRect = view.bounds
        leftFrame.size.width = FlowSlideMenuOptions.leftViewWidth + FlowCurveOptions.waveMargin
        leftFrame.origin.x = leftMinOrigin();
        let leftOffset: CGFloat = 0
        leftFrame.origin.y = leftFrame.origin.y + leftOffset
        leftFrame.size.height = leftFrame.size.height - leftOffset
        leftContainerView = LLFlowCurveView(frame: leftFrame)
        leftContainerView.backgroundColor = UIColor.clearColor()
        leftContainerView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        leftContainerView.delegate = self
        view.insertSubview(leftContainerView, atIndex: 2)
        addLeftGestures()

    }
    
    private func setUpViewController(targetView: UIView, targetViewController: UIViewController?) {
        if let viewController = targetViewController {
            addChildViewController(viewController)
            viewController.view.frame = targetView.bounds
            targetView.addSubview(viewController.view)
            viewController.didMoveToParentViewController(self)
        }
    }
    
    
    private func setUpViewController(targetView: UIView, targetViewController: UIViewController?, slideview:Bool) {
        if let viewController = targetViewController {
            addChildViewController(viewController)
            if(slideview)
            {
                viewController.view.frame = CGRectMake(0,0,slideViewWidth(),targetView.bounds.height)
            }else
            {
                viewController.view.frame = targetView.bounds
            }
            targetView.addSubview(viewController.view)
            viewController.didMoveToParentViewController(self)
        }
    }
    
    private func removeViewController(viewController: UIViewController?) {
        if let _viewController = viewController {
            _viewController.willMoveToParentViewController(nil)
            _viewController.view.removeFromSuperview()
            _viewController.removeFromParentViewController()
        }
    }
    
    private func leftMinOrigin() -> CGFloat {
        return  -FlowSlideMenuOptions.leftViewWidth - FlowCurveOptions.waveMargin
    }
    
    private func slideViewWidth() -> CGFloat {
        return  FlowSlideMenuOptions.leftViewWidth
    }
    
    private func isLeftPointContainedWithinBezelRect(point: CGPoint) -> Bool{
        var leftBezelRect: CGRect = CGRectZero
        var tempRect: CGRect = CGRectZero
        let bezelWidth: CGFloat = FlowSlideMenuOptions.leftBezelWidth
        
        CGRectDivide(view.bounds, &leftBezelRect, &tempRect, bezelWidth, CGRectEdge.MinXEdge)
        return CGRectContainsPoint(leftBezelRect, point)
    }
    
    private func addLeftGestures() {
        
        if (leftViewController != nil) {
            if leftPanGesture == nil {
                leftPanGesture = UIPanGestureRecognizer(target: self, action: "handleLeftPanGesture:")
                leftPanGesture!.delegate = self
                view.addGestureRecognizer(leftPanGesture!)
            }
        }
    }
    
    private func panLeftResultInfoForVelocity(velocity: CGPoint) -> PanInfo {
        
        let thresholdVelocity: CGFloat = 1000.0
        let pointOfNoReturn: CGFloat = CGFloat(floor(leftMinOrigin())) + FlowSlideMenuOptions.pointOfNoReturnWidth
        let leftOrigin: CGFloat = leftContainerView.frame.origin.x
        
        var panInfo: PanInfo = PanInfo(action: .Close, shouldBounce: false, velocity: 0.0)
        
        panInfo.action = leftOrigin <= pointOfNoReturn ? .Close : .Open;
        
        if velocity.x >= thresholdVelocity {
            panInfo.action = .Open
            panInfo.velocity = velocity.x
        } else if velocity.x <= (-1.0 * thresholdVelocity) {
            panInfo.action = .Close
            panInfo.velocity = velocity.x
        }
        
        return panInfo
    }
    
    public func isTagetViewController() -> Bool {
        // Function to determine the target ViewController
        // Please to override it if necessary
        return true
    }
    
    private func slideLeftForGestureRecognizer( gesture: UIGestureRecognizer, point:CGPoint) -> Bool{
        return isLeftOpen() || FlowSlideMenuOptions.panFromBezel && isLeftPointContainedWithinBezelRect(point)
    }
    
    private func isPointContainedWithinLeftRect(point: CGPoint) -> Bool {
        return CGRectContainsPoint(leftContainerView.frame, point)
    }
    
    private func applyLeftTranslation(translation: CGPoint, toFrame:CGRect) -> CGRect {
        
        var newOrigin: CGFloat = toFrame.origin.x
        newOrigin += translation.x
        
        let minOrigin: CGFloat = leftMinOrigin()
        let maxOrigin: CGFloat = 0.0
        var newFrame: CGRect = toFrame
        
        if newOrigin < minOrigin {
            newOrigin = minOrigin
        } else if newOrigin > maxOrigin {
            newOrigin = maxOrigin
        }
        
        newFrame.origin.x = newOrigin
        return newFrame
    }
    
    private func setOpenWindowLevel() {
        if (FlowSlideMenuOptions.hideStatusBar) {
            dispatch_async(dispatch_get_main_queue(), {
                if let window = UIApplication.sharedApplication().keyWindow {
                    window.windowLevel = UIWindowLevelStatusBar + 1
                }
            })
        }
    }
    
    private func setCloseWindowLebel() {
        if (FlowSlideMenuOptions.hideStatusBar) {
            dispatch_async(dispatch_get_main_queue(), {
                if let window = UIApplication.sharedApplication().keyWindow {
                    window.windowLevel = UIWindowLevelNormal
                }
            })
        }
    }
    
    public func isLeftOpen() -> Bool {
        return leftContainerView.frame.origin.x == 0.0
    }
    
    public func isLeftHidden() -> Bool {
        return leftContainerView.frame.origin.x <= leftMinOrigin()
    }
    
    public func closeLeftWithVelocity(velocity: CGFloat) {
        
        leftContainerView.close()
        
        let xOrigin: CGFloat = leftContainerView.frame.origin.x
        let finalXOrigin: CGFloat = leftMinOrigin()
        
        var frame: CGRect = leftContainerView.frame;
        frame.origin.x = finalXOrigin
        
        var duration: NSTimeInterval = Double(FlowSlideMenuOptions.animationDuration)
        if velocity != 0.0 {
            duration = Double(fabs(xOrigin - finalXOrigin) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
        
        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.leftContainerView.frame = frame
                strongSelf.opacityView.layer.opacity = 0.0
                strongSelf.mainContainerView.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }
            }) { [weak self](Bool) -> Void in
                if let strongSelf = self {
                    strongSelf.enableContentInteraction()
                    strongSelf.leftViewController?.endAppearanceTransition()
                    strongSelf.leftViewController?.view.alpha = 0
                }
        }
    }
    
    public override func openLeft (){
        setOpenWindowLevel()
        leftViewController?.beginAppearanceTransition(isLeftHidden(), animated:false)
        openLeftFakeAnimation()
        self.leftContainerView.openAll()
    }
    
    public func updatePointTimer()
    {
        print(self.leftContainerView.frame.origin.x)
    }
    
    public override func closeLeft (){

        leftViewController?.beginAppearanceTransition(isLeftHidden(), animated: true)
        closeLeftWithVelocity(0.0)
        setCloseWindowLebel()
    }
    
    public func openLeftFakeAnimation()
    {
        
        var frame = leftContainerView.frame;
        frame.origin.x = 0;
    
        self.leftContainerView.frame = frame
        self.opacityView.layer.opacity = Float(FlowSlideMenuOptions.contentViewOpacity)
        
        let duration: NSTimeInterval = Double(FlowSlideMenuOptions.animationDuration)
        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.mainContainerView.transform = CGAffineTransformMakeScale(FlowSlideMenuOptions.contentViewScale, FlowSlideMenuOptions.contentViewScale)
            }
            }) { [weak self](Bool) -> Void in
                if let strongSelf = self {
                    strongSelf.disableContentInteraction()
                    strongSelf.leftViewController?.endAppearanceTransition()
                }
        }
    }
    public func openLeftWithVelocity(velocity: CGFloat) {
        let xOrigin: CGFloat = leftContainerView.frame.origin.x
        let finalXOrigin: CGFloat = 0.0
        
        var frame = leftContainerView.frame;
        frame.origin.x = finalXOrigin;
        
        var duration: NSTimeInterval = Double(FlowSlideMenuOptions.animationDuration)
        if velocity != 0.0 {
            duration = Double(fabs(xOrigin - finalXOrigin) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
    
        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.leftContainerView.frame = frame
                strongSelf.opacityView.layer.opacity = Float(FlowSlideMenuOptions.contentViewOpacity)
                strongSelf.mainContainerView.transform = CGAffineTransformMakeScale(FlowSlideMenuOptions.contentViewScale, FlowSlideMenuOptions.contentViewScale)
            }
            }) { [weak self](Bool) -> Void in
                if let strongSelf = self {
                    strongSelf.disableContentInteraction()
                    strongSelf.leftViewController?.endAppearanceTransition()
                }
        }
        
        self.leftContainerView.open()
    }

    private func applyLeftContentViewScale() {
        let openedLeftRatio: CGFloat = getOpenedLeftRatio()
        let scale: CGFloat = 1.0 - ((1.0 - FlowSlideMenuOptions.contentViewScale) * openedLeftRatio);
        mainContainerView.transform = CGAffineTransformMakeScale(scale, scale)
    }
   
    private func getOpenedLeftRatio() -> CGFloat {
        
        let width: CGFloat = leftContainerView.frame.size.width
        let currentPosition: CGFloat = leftContainerView.frame.origin.x - leftMinOrigin()
        return currentPosition / width
    }
    
    // MARK: -
    // MARK: public funs
    public func removeLeftGestures() {
        if leftPanGesture != nil {
            view.removeGestureRecognizer(leftPanGesture!)
            leftPanGesture = nil
        }
    }
    
    public func closeLeftNonAnimation(){
        setCloseWindowLebel()
        let finalXOrigin: CGFloat = leftMinOrigin()
        var frame: CGRect = leftContainerView.frame;
        frame.origin.x = finalXOrigin
        leftContainerView.frame = frame
        opacityView.layer.opacity = 0.0
        mainContainerView.transform = CGAffineTransformMakeScale(1.0, 1.0)
        enableContentInteraction()
        self.leftContainerView.animating = false
    }
    
    private func disableContentInteraction() {
        mainContainerView.userInteractionEnabled = false
    }
    
    private func enableContentInteraction() {
        mainContainerView.userInteractionEnabled = true
    }
    
    // MARK: -
    // MARK: handleLeftPanGesture funs
    struct LeftPanState {
        static var frameAtStartOfPan: CGRect = CGRectZero
        static var startPointOfPan: CGPoint = CGPointZero
        static var wasOpenAtStartOfPan: Bool = false
        static var wasHiddenAtStartOfPan: Bool = false
    }
    
    func handleLeftPanGesture(panGesture: UIPanGestureRecognizer) {
        
        if !isTagetViewController() {
            return
        }
        
        switch panGesture.state {
        case UIGestureRecognizerState.Began:
            
            
            LeftPanState.wasHiddenAtStartOfPan = isLeftHidden()
            LeftPanState.wasOpenAtStartOfPan = isLeftOpen()
            
           
            self.leftContainerView.start()

            LeftPanState.frameAtStartOfPan = leftContainerView.frame
            LeftPanState.startPointOfPan = panGesture.locationInView(self.view)
            
            leftViewController?.beginAppearanceTransition(LeftPanState.wasHiddenAtStartOfPan, animated: true)
            
            setOpenWindowLevel()
            
        case UIGestureRecognizerState.Changed:
            
            
            let translation: CGPoint = panGesture.translationInView(panGesture.view)
            leftContainerView.updatePoint(CGPointMake(translation.x, translation.y +  LeftPanState.startPointOfPan.y), orientation: Orientation.Left)
            leftContainerView.frame = applyLeftTranslation(translation, toFrame: LeftPanState.frameAtStartOfPan)
           applyLeftContentViewScale()

        case UIGestureRecognizerState.Ended:
            
            let velocity:CGPoint = panGesture.velocityInView(panGesture.view)
            let panInfo: PanInfo = panLeftResultInfoForVelocity(velocity)
            
            if panInfo.action == .Open {
                if !LeftPanState.wasHiddenAtStartOfPan {
                    leftViewController?.beginAppearanceTransition(true, animated: true)
                }
                openLeftWithVelocity(panInfo.velocity)
                
            } else {
                if LeftPanState.wasHiddenAtStartOfPan {
                    leftViewController?.beginAppearanceTransition(false, animated: true)
                }
                
                closeLeftWithVelocity(panInfo.velocity)
                setCloseWindowLebel()
                
            }
            
        default:
            break
        }
    }
    
    // MARK:  -
    // MARK: UIGestureRecognizerDelegate
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        let point: CGPoint = touch.locationInView(view)
        
        if gestureRecognizer == leftPanGesture {
            return slideLeftForGestureRecognizer(gestureRecognizer, point: point)
        } else if gestureRecognizer == leftTapGetsture {
            return isLeftOpen() && !isPointContainedWithinLeftRect(point)
        }
    
        return true
    }
    
    // MARK:  -
    // MARK: LLFlowCurveViewDelegate
    public func flowViewStartAnimation(flow:LLFlowCurveView)
    {
        leftViewController?.view.alpha = 0.0
    }
    
    public func flowViewEndAnimation(flow:LLFlowCurveView)
    {
        UIView.animateWithDuration(0.3) { () -> Void in
            self.leftViewController?.view.alpha = 1
        }
    }
}

// MARK:  -
// MARK: UIViewController extension
extension UIViewController {
    
    public func slideMenuController() -> LLFlowSlideMenuVC? {
        var viewController: UIViewController? = self
        while viewController != nil {
            if viewController is LLFlowSlideMenuVC {
                return viewController as? LLFlowSlideMenuVC
            }
            viewController = viewController?.parentViewController
        }
        return nil;
    }
    
    public func addLeftBarButtonWithImage(buttonImage: UIImage) {
        let leftButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.Plain, target: self, action: "toggleLeft")
        navigationItem.leftBarButtonItem = leftButton;
    }
    
    public func openLeft() {
        slideMenuController()?.openLeft()
    }
    
    public func closeLeft() {
        slideMenuController()?.closeLeft()
    }
    
    // Please specify if you want menu gesuture give priority to than targetScrollView
    public func addPriorityToMenuGesuture(targetScrollView: UIScrollView) {
        guard let slideController = slideMenuController(), let recognizers = slideController.view.gestureRecognizers else {
            return
        }
        for recognizer in recognizers where recognizer is UIPanGestureRecognizer {
            targetScrollView.panGestureRecognizer.requireGestureRecognizerToFail(recognizer)
        }
    }
}