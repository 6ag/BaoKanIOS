//
//  JFNewFeatureViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/23.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import SnapKit

class JFNewFeatureViewController: UICollectionViewController {
    
    // MARK: 属性
    private let itemCount = 4
    private var layout = UICollectionViewFlowLayout()
    let reuseIdentifier = "Cell"
    
    init() {
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.showsHorizontalScrollIndicator = false
        self.collectionView!.registerClass(JFNewFeatureCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        prepareLayout()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
    }
    
    // MARK: - 设置layout的参数
    private func prepareLayout() {
        layout.itemSize = UIScreen.mainScreen().bounds.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        collectionView?.pagingEnabled = true
        collectionView?.bounces = false
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! JFNewFeatureCell
        
        cell.imageIndex = indexPath.item
        
        
        return cell
    }
    
    // collectionView显示完毕cell
    // collectionView分页滚动完毕cell看不到的时候调用
    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        // 正在显示的cell的indexPath
        let showIndexPath = collectionView.indexPathsForVisibleItems().first!
        
        // 获取collectionView正在显示的cell
        let cell = collectionView.cellForItemAtIndexPath(showIndexPath) as! JFNewFeatureCell
        
        // 最后一页动画
        if showIndexPath.item == itemCount - 1 {
            // 开始按钮动画
            cell.startButtonAnimation()
        }
    }
    
}

// 自定义cell
class JFNewFeatureCell: UICollectionViewCell {
    
    // MARK: 属性
    var imageIndex: Int = 0 {
        didSet {
            backgroundImageView.image = UIImage(named: "new_feature_\(imageIndex + 1)")
            startButton.hidden = true
        }
    }
    
    // MARK: - 构造方法
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
    }
    
    // MARK: - 开始按钮动画
    func startButtonAnimation() {
        startButton.hidden = false
        // 把按钮的 transform 缩放设置为0
        startButton.transform = CGAffineTransformMakeScale(0, 0)
        
        UIView.animateWithDuration(1, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
            self.startButton.transform = CGAffineTransformIdentity
        }) { (_) -> Void in
            
        }
    }
    
    // MARK: - 准备UI
    private func prepareUI() {
        // 添加子控件
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(startButton)
        
        // 添加约束
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundImageView.snp_makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
        
        startButton.snp_makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.bottom.equalTo(-100)
        }
    }
    
    /**
     开始按钮点击
     */
    func startButtonClick() {
        UIApplication.sharedApplication().keyWindow?.rootViewController = JFTabBarController()
    }
    
    // MARK: - 懒加载
    /// 背景
    private lazy var backgroundImageView = UIImageView()
    
    /// 开始体验按钮
    private lazy var startButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "new_feature_finish_button"), forState: UIControlState.Normal)
        button.setBackgroundImage(UIImage(named: "new_feature_finish_button_highlighted"), forState: UIControlState.Highlighted)
        button.setTitle("开始体验", forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(JFNewFeatureCell.startButtonClick), forControlEvents: UIControlEvents.TouchUpInside)
        return button
    }()
}
