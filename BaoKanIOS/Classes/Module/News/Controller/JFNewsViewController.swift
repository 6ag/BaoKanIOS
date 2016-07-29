//
//  JFNewsViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit
import SnapKit

class JFNewsViewController: UIViewController {
    
    /// 顶部标签按钮区域
    @IBOutlet weak var topScrollView: UIScrollView!
    /// 内容区域
    @IBOutlet weak var contentScrollView: UIScrollView!
    /// 标签按钮旁的加号按钮
    @IBOutlet weak var addButton: UIButton!
    
    var contentOffsetX: CGFloat = 0.0
    
    // 栏目数组
    private var selectedArray: [[String : String]]?
    private var optionalArray: [[String : String]]?
    
    /// 栏目管理控制器
    private lazy var editColumnVc: JFEditColumnViewController = {
        let editColumnVc = JFEditColumnViewController()
        editColumnVc.transitioningDelegate = self
        editColumnVc.modalPresentationStyle = .Custom
        return editColumnVc
    }()
    
    // MARK: - 视图生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 准备视图
        prepareUI()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didReceiveRemoteNotificationOfJPush(_:)), name: "didReceiveRemoteNotificationOfJPush", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(columnViewWillDismiss(_:)), name: "columnViewWillDismiss", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
     处理接收到的远程通知，跳转到指定的文章
     */
    func didReceiveRemoteNotificationOfJPush(notification: NSNotification) -> Void {
        
        if let userInfo = notification.userInfo {
            guard let classid = userInfo["classid"] as? String, let id = userInfo["id"] as? String, let type = userInfo["type"] as? String else {return}
            
            if type == "photo" {
                let detailVc = JFPhotoDetailViewController()
                detailVc.photoParam = (classid, id)
                navigationController?.pushViewController(detailVc, animated: true)
            } else {
                let detailVc = JFNewsDetailViewController()
                detailVc.articleParam = (classid, id)
                navigationController?.pushViewController(detailVc, animated: true)
            }
            
        }
        
    }
    
    /**
     栏目管理控制器即将消失
     */
    func columnViewWillDismiss(notification: NSNotification) {
        
        UIView.animateWithDuration(0.5, animations: {
            self.addButton.imageView!.transform = CGAffineTransformIdentity
            }, completion: { (_) in
                // 赋值重新排序后的栏目数据
                self.selectedArray = self.editColumnVc.selectedArray
                self.optionalArray = self.editColumnVc.optionalArray
                NSUserDefaults.standardUserDefaults().setObject(self.selectedArray, forKey: "selectedArray")
                NSUserDefaults.standardUserDefaults().setObject(self.optionalArray, forKey: "optionalArray")
                
                self.prepareUI()
                
                // 如果是直接点击的分类，则跳转到指定分类
                if let userInfo = notification.userInfo as? [String : Int] {
                    self.contentScrollView.setContentOffset(CGPoint(x: CGFloat(userInfo["index"]!) * self.contentScrollView.frame.size.width, y: self.contentScrollView.contentOffset.y), animated: true)
                }
        })
    }
    
    // MARK: - 各种自定义方法
    /**
     准备视图
     */
    private func prepareUI() {
        
        // 移除原有数据
        for subView in topScrollView.subviews {
            if subView.isKindOfClass(JFTopLabel.classForCoder()) {
                subView.removeFromSuperview()
            }
        }
        for subView in contentScrollView.subviews {
            subView.removeFromSuperview()
        }
        for vc in childViewControllers {
            vc.removeFromParentViewController()
        }
        
        // 添加内容
        addContent()
    }
    
    /**
     编辑分类按钮点击
     */
    @IBAction func didTappedEditColumnButton(sender: UIButton) {
        
        editColumnVc.selectedArray = selectedArray
        editColumnVc.optionalArray = optionalArray
        presentViewController(editColumnVc, animated: true, completion: {
            
        })
        
        UIView.animateWithDuration(0.5, animations: {
            self.addButton.imageView!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) - 0.01)
        })
    }
    
    /**
     配置栏目
     */
    private func setupColumn() {
        
        let tempSelectedArray = NSUserDefaults.standardUserDefaults().objectForKey("selectedArray") as? [[String : String]]
        let tempOptionalArray = NSUserDefaults.standardUserDefaults().objectForKey("optionalArray") as? [[String : String]]
        
        if tempSelectedArray != nil || tempOptionalArray != nil {
            selectedArray = tempSelectedArray != nil ? tempSelectedArray : [[String : String]]()
            optionalArray = tempOptionalArray != nil ? tempOptionalArray : [[String : String]]()
        } else {
            selectedArray = [
                [
                    "classid" : "0",
                    "classname" : "今日头条"
                ],
                [
                    "classid" : "2",
                    "classname": "网文快讯"
                ],
                [
                    "classid" : "21",
                    "classname": "媒体视角"
                ],
                [
                    "classid" : "12",
                    "classname": "网文IP"
                ],
                [
                    "classid" : "264",
                    "classname": "企业资讯"
                ],
                [
                    "classid" : "33",
                    "classname": "作家风采"
                ],
                [
                    "classid" : "34",
                    "classname": "维权在线"
                ],
                [
                    "classid" : "212",
                    "classname": "业者动态"
                ],
                [
                    "classid" : "132",
                    "classname": "风花雪月"
                ],
                [
                    "classid" : "396",
                    "classname": "独家报道"
                ],
                [
                    "classid" : "119",
                    "classname": "求职招聘"
                ],
            ]
            
            optionalArray = [
                [
                    "classid" : "32",
                    "classname": "高端访谈"
                ],
                [
                    "classid" : "102",
                    "classname": "政策解读"
                ],
                [
                    "classid" : "111",
                    "classname": "写作指导"
                ],
                [
                    "classid" : "115",
                    "classname": "征稿信息"
                ],
                [
                    "classid" : "51",
                    "classname": "精彩活动"
                ],
                [
                    "classid" : "440",
                    "classname": "写作常识"
                ],
                [
                    "classid" : "209",
                    "classname": "数据分析"
                ],
                [
                    "classid" : "208",
                    "classname": "统计图表"
                ],
                [
                    "classid" : "405",
                    "classname": "名家专栏"
                ],
                [
                    "classid" : "394",
                    "classname": "传统文学"
                ],
                [
                    "classid" : "414",
                    "classname": "写作素材"
                ],
                [
                    "classid" : "281",
                    "classname": "游戏世界"
                ],
                [
                    "classid" : "57",
                    "classname": "娱乐八卦"
                ],
                [
                    "classid" : "58",
                    "classname": "社会杂谈"
                ],
                [
                    "classid" : "56",
                    "classname": "影视动画"
                ]
            ]
            
            // 默认栏目保存
            NSUserDefaults.standardUserDefaults().setObject(selectedArray, forKey: "selectedArray")
            NSUserDefaults.standardUserDefaults().setObject(optionalArray, forKey: "optionalArray")
        }
        
    }
    
    /**
     添加顶部标题栏和控制器
     */
    private func addContent() {
        
        // 初始化栏目
        setupColumn()
        
        // 布局用的左边距
        var leftMargin: CGFloat = 0
        
        for i in 0..<selectedArray!.count {
            
            let label = JFTopLabel()
            label.text = selectedArray![i]["classname"]
            label.tag = i
            label.scale = i == 0 ? 1.0 : 0.0
            label.userInteractionEnabled = true
            topScrollView.addSubview(label)
            
            // 利用layout来自适应各种长度的label
            label.snp_makeConstraints(closure: { (make) -> Void in
                make.left.equalTo(leftMargin + 15)
                make.centerY.equalTo(topScrollView)
            })
            
            // 更新布局和左边距
            topScrollView.layoutIfNeeded()
            leftMargin = CGRectGetMaxX(label.frame)
            
            // 添加标签点击手势
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedTopLabel(_:))))
            
            // 添加控制器
            let newsVc = JFNewsTableViewController()
            addChildViewController(newsVc)
            
            // 默认控制器
            if i <= 1 {
                addContentViewController(i)
            }
        }
        
        // 内容区域滚动范围
        contentScrollView.contentSize = CGSize(width: CGFloat(childViewControllers.count) * SCREEN_WIDTH, height: 0)
        contentScrollView.pagingEnabled = true
        
        let lastLabel = topScrollView.subviews.last as! JFTopLabel
        // 设置顶部标签区域滚动范围
        topScrollView.contentSize = CGSize(width: leftMargin + lastLabel.frame.width, height: 0)
        
        // 视图滚动到第一个位置
        contentScrollView.setContentOffset(CGPoint(x: 0, y: contentScrollView.contentOffset.y), animated: true)
    }
    
    /**
     添加内容控制器
     
     - parameter index: 控制器角标
     */
    private func addContentViewController(index: Int) {
        
        // 获取需要展示的控制器
        let newsVc = childViewControllers[index] as! JFNewsTableViewController
        
        // 如果已经展示则直接返回
        if newsVc.view.superview != nil {
            return
        }
        
        newsVc.view.frame = CGRect(x: CGFloat(index) * SCREEN_WIDTH, y: 0, width: contentScrollView.bounds.width, height: contentScrollView.bounds.height)
        contentScrollView.addSubview(newsVc.view)
        newsVc.classid = Int(selectedArray![index]["classid"]!)
    }
    
    /**
     顶部标签的点击事件
     */
    @objc private func didTappedTopLabel(gesture: UITapGestureRecognizer) {
        let titleLabel = gesture.view as! JFTopLabel
        contentScrollView.setContentOffset(CGPoint(x: CGFloat(titleLabel.tag) * contentScrollView.frame.size.width, y: contentScrollView.contentOffset.y), animated: true)
    }
    
}

// MARK: - scrollView代理方法
extension JFNewsViewController: UIScrollViewDelegate {
    
    // 滚动结束后触发 代码导致
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        
        // 滚动标题栏
        let titleLabel = topScrollView.subviews[index]
        var offsetX = titleLabel.center.x - topScrollView.frame.size.width * 0.5
        let offsetMax = topScrollView.contentSize.width - topScrollView.frame.size.width
        
        if offsetX < 0 {
            offsetX = 0
        } else if (offsetX > offsetMax) {
            offsetX = offsetMax
        }
        
        // 滚动顶部标题
        topScrollView.setContentOffset(CGPoint(x: offsetX, y: topScrollView.contentOffset.y), animated: true)
        
        // 恢复其他label缩放
        for i in 0..<selectedArray!.count {
            if i != index {
                let topLabel = topScrollView.subviews[i] as! JFTopLabel
                topLabel.scale = 0.0
            }
        }
        
        // 添加控制器 - 并预加载控制器  左滑预加载下下个 右滑预加载上上个 保证滑动流畅
        let value = (scrollView.contentOffset.x / scrollView.frame.width)
        
        var index1 = Int(value)
        var index2 = Int(value)
        
        // 根据滑动方向计算下标
        if scrollView.contentOffset.x - contentOffsetX > 2.0 {
            index1 = (value - CGFloat(Int(value))) > 0 ? Int(value) + 1 : Int(value)
            index2 = index1 + 1
        } else if contentOffsetX - scrollView.contentOffset.x > 2.0 {
            index1 = (value - CGFloat(Int(value))) < 0 ? Int(value) - 1 : Int(value)
            index2 = index1 - 1
        }
        
        // 控制器角标范围
        if index1 > childViewControllers.count - 1 {
            index1 = childViewControllers.count - 1
        } else if index1 < 0 {
            index1 = 0
        }
        if index2 > childViewControllers.count - 1 {
            index2 = childViewControllers.count - 1
        } else if index2 < 0 {
            index2 = 0
        }
        
        addContentViewController(index1)
        addContentViewController(index2)
    }
    
    // 滚动结束 手势导致
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    // 开始拖拽视图
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        contentOffsetX = scrollView.contentOffset.x
    }
    
    // 正在滚动
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let value = (scrollView.contentOffset.x / scrollView.frame.width)
        
        let leftIndex = Int(value)
        let rightIndex = leftIndex + 1
        let scaleRight = value - CGFloat(leftIndex)
        let scaleLeft = 1 - scaleRight
        
        let labelLeft = topScrollView.subviews[leftIndex] as! JFTopLabel
        labelLeft.scale = scaleLeft
        
        if rightIndex < topScrollView.subviews.count {
            let labelRight = topScrollView.subviews[rightIndex] as! JFTopLabel
            labelRight.scale = scaleRight
        }
    }

}

// MARK: - 栏目管理自定义转场动画事件
extension JFNewsViewController: UIViewControllerTransitioningDelegate {
    
    /**
     返回一个控制modal视图大小的对象
     */
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return JFPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    /**
     返回一个控制器modal动画效果的对象
     */
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return JFPopoverModalAnimation()
    }
    
    /**
     返回一个控制dismiss动画效果的对象
     */
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return JFPopoverDismissAnimation()
    }
    
}