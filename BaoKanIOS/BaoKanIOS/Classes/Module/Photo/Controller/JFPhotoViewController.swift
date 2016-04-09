//
//  JFPhotoViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class JFPhotoViewController: UIViewController
{
    /// 顶部标签按钮区域
    @IBOutlet weak var topScrollView: UIScrollView!
    /// 内容区域
    @IBOutlet weak var contentScrollView: UIScrollView!
    /// 标签按钮旁的加号按钮
    @IBOutlet weak var addButton: UIButton!
    // 顶部标签数组
    private var topTitles: [[String : String]]?
    /// 顶部条
    var topBarView: UIView!
    
    // MARK: - 视图生命周期
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // 准备视图
        prepareUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        topBarView = UIView()
        topBarView.backgroundColor = NAVIGATIONBAR_RED_COLOR
        view.addSubview(topBarView)
        topBarView.snp_makeConstraints { (make) in
            make.left.right.top.equalTo(0)
            make.height.equalTo(20)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        topBarView.removeFromSuperview()
    }
    
    // MARK: - 各种自定义方法
    /**
     准备视图
     */
    private func prepareUI()
    {
        navigationItem.titleView = UIImageView(image: UIImage(named: "navigation_logo"))
        
        // 添加内容
        addContent()
        
    }
    
    /**
     添加顶部标题栏和控制器
     */
    private func addContent()
    {
        // 初始化标签数组
        if let topTitles = NSUserDefaults.standardUserDefaults().objectForKey("photoTopTitles") as? [[String : String]] {
            self.topTitles = topTitles;
        } else {
            // 如果本地没有数据则初始化并保存到本地
            let topTitles = [
                [
                    "classid" : "322",
                    "classname": "图话网文"
                ],
                [
                    "classid" : "338",
                    "classname": "娱乐八卦"
                ],
                [
                    "classid" : "345",
                    "classname": "封面素材"
                ],
                [
                    "classid" : "350",
                    "classname": "美女模特"
                ],
                [
                    "classid" : "354",
                    "classname": "社会百态"
                ],
                [
                    "classid" : "357",
                    "classname": "旅游视野"
                ],
                [
                    "classid" : "366",
                    "classname": "游戏图库"
                ],
                [
                    "classid" : "433",
                    "classname": "军事图秀"
                ],
                [
                    "classid" : "434",
                    "classname": "封面展示"
                ]
            ]
            NSUserDefaults.standardUserDefaults().setObject(topTitles, forKey: "photoTopTitles")
            self.topTitles = topTitles
        }
        
        // 布局用的左边距
        var leftMargin: CGFloat = 0
        
        for var i = 0; i < topTitles?.count; i += 1 {
            
            let label = JFTopLabel()
            label.text = topTitles![i]["classname"]
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
            let photoVc = JFPhotoTableViewController()
            addChildViewController(photoVc)
            
            // 默认控制器
            if i == 0 {
                photoVc.classid = Int(topTitles![0]["classid"]!)
                photoVc.view.frame = contentScrollView.bounds
                contentScrollView.addSubview(photoVc.view)
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
    @objc private func didTappedTopLabel(gesture: UITapGestureRecognizer)
    {
        let titleLabel = gesture.view as! JFTopLabel
        contentScrollView.setContentOffset(CGPoint(x: CGFloat(titleLabel.tag) * contentScrollView.frame.size.width, y: contentScrollView.contentOffset.y), animated: true)
    }
    
    /**
     左边导航栏按钮点击事件
     */
    @IBAction func didTappedTopLeftButton()
    {
        
    }
}

// MARK: - scrollView代理方法
extension JFPhotoViewController: UIScrollViewDelegate
{
    // 滚动结束后触发 代码导致
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView)
    {
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
        for var i = 0; i < topTitles?.count; i += 1 {
            if i != index {
                let topLabel = topScrollView.subviews[i] as! JFTopLabel
                topLabel.scale = 0.0
            }
        }
        
        // 获取需要展示的控制器
        let photoVc = childViewControllers[index] as! JFPhotoTableViewController
        
        // 如果已经展示则直接返回
        if photoVc.view.superview != nil {
            return
        }
        
        contentScrollView.addSubview(photoVc.view)
        photoVc.view.frame = CGRect(x: CGFloat(index) * SCREEN_WIDTH, y: 0, width: SCREEN_WIDTH, height: contentScrollView.frame.height)
        
        // 传递分类数据
        photoVc.classid = Int(topTitles![0]["classid"]!)
    }
    
    // 滚动结束 手势导致
    func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    // 正在滚动
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
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
