//
//  JFNewsViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class JFNewsViewController: UIViewController {
    
    /// 顶部标签按钮区域
    @IBOutlet weak var topScrollView: UIScrollView!
    /// 内容区域
    @IBOutlet weak var contentScrollView: UIScrollView!
    /// 标签按钮旁的加号按钮
    @IBOutlet weak var addButton: UIButton!
    // 顶部标签数组
    private var topTitles: [String]?
    
    // MARK: - 视图生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 准备视图
        prepareUI()
    }
    
    // MARK: - 各种自定义方法
    /**
    准备视图
    */
    private func prepareUI() {
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "navigation_logo"))
        
        // 添加内容
        addContent()
        
    }
    
    /**
     添加顶部标题栏和控制器
     */
    private func addContent() {
        
        // 初始化标签数组
        if let topTitles = NSUserDefaults.standardUserDefaults().objectForKey("topTitles") as? [String] {
            self.topTitles = topTitles;
        } else {
            // 如果本地没有数据则初始化并保存到本地
            let topTitles = ["头条", "业界", "行情", "专题", "独家", "传统文学", "企业", "作家风采", "访谈", "维权", "业者动态", "活动", "风月", "八卦", "社会", "图文", "游戏", "影视动画", "政策", "写作指导", "求职招聘", "征稿", "写作素材", "软件", "数据", "专栏"]
            NSUserDefaults.standardUserDefaults().setObject(topTitles, forKey: "topTitles")
            self.topTitles = topTitles
        }
        
        // 布局用的左边距
        var leftMargin: CGFloat = 0
        
        for var i = 0; i < topTitles?.count; i++ {
            
            let label = JFTopLabel()
            label.text = topTitles![i]
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
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didTappedTopLabel:"))
            
            // 添加控制器
            let newsVc = JFNewsTableViewController()
            addChildViewController(newsVc)
            
            // 默认控制器
            if i == 0 {
                newsVc.id = i
                newsVc.view.frame = contentScrollView.bounds
                contentScrollView.addSubview(newsVc.view)
            }
        }
        
        // 内容区域滚动范围
        contentScrollView.contentSize = CGSize(width: CGFloat(childViewControllers.count) * SCREEN_WIDTH, height: 0)
        contentScrollView.pagingEnabled = true
        
        let lastLabel = topScrollView.subviews.last as! JFTopLabel
        // 设置顶部标签区域滚动范围
        topScrollView.contentSize = CGSize(width: leftMargin + lastLabel.frame.width, height: 0)
        
    }
    
    /**
     顶部标签的点击事件
     */
    @objc private func didTappedTopLabel(gesture: UITapGestureRecognizer) {
        
        let titleLabel = gesture.view as! JFTopLabel
        contentScrollView.setContentOffset(CGPoint(x: CGFloat(titleLabel.tag) * contentScrollView.frame.size.width, y: contentScrollView.contentOffset.y), animated: true)
    }
    
    /**
     左边导航栏按钮点击事件
     */
    @IBAction func didTappedTopLeftButton() {
        // 打开侧栏
        openLeft()
    }
}

// MARK: - scrollView代理方法
extension JFNewsViewController: UIScrollViewDelegate {
    
    // 滚动结束后触发 代码导致
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        
        let index = scrollView.contentOffset.x / scrollView.frame.size.width
        
        // 滚动标题栏
        let titleLabel = topScrollView.subviews[Int(index)]
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
        for var i = 0; i < topTitles?.count; i++ {
            if i != Int(index) {
                let topLabel = topScrollView.subviews[i] as! JFTopLabel
                topLabel.scale = 0.0
            }
        }
        
        // 获取需要展示的控制器
        let newsVc = childViewControllers[Int(index)] as! JFNewsTableViewController
        
        // 如果已经展示则直接返回
        if newsVc.view.superview != nil {
            return
        }
        
        contentScrollView.addSubview(newsVc.view)
        newsVc.view.frame = CGRect(x: CGFloat(Int(index)) * SCREEN_WIDTH, y: 0, width: SCREEN_WIDTH, height: contentScrollView.frame.height)
        
        // 这里传递数据  分类id
        newsVc.id = Int(index)
        
    }
    
    // 滚动结束 手势导致
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    // 正在滚动
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let value = abs(scrollView.contentOffset.x / scrollView.frame.width)
        
        let leftIndex = Int(value)
        let rightIndex = leftIndex + 1
        let scaleRight = value - CGFloat(leftIndex)
        let scaleLeft = 1 - scaleRight
        
        let labelLeft = topScrollView.subviews[leftIndex] as! JFTopLabel
        labelLeft.scale = Float(scaleLeft)
        
        if rightIndex < topScrollView.subviews.count {
            let labelRight = topScrollView.subviews[rightIndex] as! JFTopLabel
            labelRight.scale = Float(scaleRight)
        }
        
    }
    
}