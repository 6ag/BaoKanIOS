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
    fileprivate let itemCount = 4
    fileprivate var layout = UICollectionViewFlowLayout()
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
        self.collectionView!.register(JFNewFeatureCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        prepareLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.slide)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.slide)
    }
    
    // MARK: - 设置layout的参数
    fileprivate func prepareLayout() {
        layout.itemSize = UIScreen.main.bounds.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        collectionView?.isPagingEnabled = true
        collectionView?.bounces = false
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! JFNewFeatureCell
        
        cell.imageIndex = indexPath.item
        
        
        return cell
    }
    
    // collectionView显示完毕cell
    // collectionView分页滚动完毕cell看不到的时候调用
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // 正在显示的cell的indexPath
        let showIndexPath = collectionView.indexPathsForVisibleItems.first!
        
        // 获取collectionView正在显示的cell
        let cell = collectionView.cellForItem(at: showIndexPath) as! JFNewFeatureCell
        
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
            startButton.isHidden = true
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
        startButton.isHidden = false
        // 把按钮的 transform 缩放设置为0
        startButton.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 1, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
            self.startButton.transform = CGAffineTransform.identity
        }) { (_) -> Void in
            
        }
    }
    
    // MARK: - 准备UI
    fileprivate func prepareUI() {
        // 添加子控件
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(startButton)
        
        // 添加约束
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
        
        startButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.bottom.equalTo(-100)
            make.size.equalTo(CGSize(width: 140, height: 40))
        }
    }
    
    /**
     开始按钮点击
     */
    func startButtonClick() {
        UIApplication.shared.keyWindow?.rootViewController = JFTabBarController()
    }
    
    // MARK: - 懒加载
    /// 背景
    fileprivate lazy var backgroundImageView = UIImageView()
    
    /// 开始体验按钮
    fileprivate lazy var startButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.setBackgroundImage(UIImage(named: "new_feature_finish_button"), for: UIControlState())
        button.setBackgroundImage(UIImage(named: "new_feature_finish_button_highlighted"), for: UIControlState.highlighted)
        button.setTitle("开始体验", for: UIControlState())
        button.addTarget(self, action: #selector(JFNewFeatureCell.startButtonClick), for: UIControlEvents.touchUpInside)
        return button
    }()
}
