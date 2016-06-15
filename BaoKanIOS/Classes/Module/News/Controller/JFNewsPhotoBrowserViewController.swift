//
//  JFPhotoDetailViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/4/7.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

class JFNewsPhotoBrowserViewController: UIViewController {
    
    // MARK: - 属性
    /// 文章详情请求参数
    var photoParam : (allphoto: [AnyObject], index: Int)? {
        didSet {
            // 处理文章图片数据
            for dict in photoParam!.allphoto {
                let photoModel = JFArticleImageModel(dict: dict as! [String : AnyObject])
                photoModels.append(photoModel)
            }
            
            self.scrollViewDidEndDecelerating(self.collectionView)
            self.collectionView.reloadData()
            
            // 滚动到指定的index
            collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: photoParam!.index, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
            
            let model = photoModels[photoParam!.index]
            bottomTitleLabel.text = "\(photoParam!.index + 1)/\(photoModels.count) \(model.caption!)"
            currentIndex = photoParam!.index
        }
    }
    
    private var photoModels = [JFArticleImageModel]()
    
    /// 当前图片脚标
    var currentIndex = 0
    
    // 导航栏/背景颜色
    private let bgColor = UIColor(red:0.110,  green:0.102,  blue:0.110, alpha:0.9)
    
    private let photoIdentifier = "photoDetail"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    /**
     滚动停止后调用，更新底部工具条文字
     */
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let page = Int(scrollView.contentOffset.x / SCREEN_WIDTH)
        let model = photoModels[page]
        bottomTitleLabel.text = "\(page + 1)/\(photoModels.count) \(model.caption!)"
    }
    
    /**
     保存图片到相册
     */
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if let _ = error {
            JFProgressHUD.showInfoWithStatus("保存失败")
        } else {
            JFProgressHUD.showInfoWithStatus("保存成功")
        }
    }
    
    /**
     点击了保存按钮
     */
    @objc private func didTappedSaveButton(button: UIButton) {
        
        let imageURL = photoModels[currentIndex].url!
        
        let imagePath = JFArticleStorage.getFilePathForKey(imageURL)
        let image = UIImage(contentsOfFile: imagePath)
        if let img = image {
            UIImageWriteToSavedPhotosAlbum(img, self, #selector(JFPhotoDetailViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            JFProgressHUD.showInfoWithStatus("保存失败")
        }
        
    }
    
    /**
     准备UI
     */
    @objc private func prepareUI() {
        
        view.backgroundColor = UIColor(red:0.110,  green:0.102,  blue:0.110, alpha:1)
        automaticallyAdjustsScrollViewInsets = false
        
        view.addSubview(collectionView)
        view.addSubview(bottomToolView)
        bottomToolView.addSubview(bottomTitleLabel)
        bottomToolView.addSubview(bottomSaveButton)
        
        bottomToolView.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(45)
        }
        
        bottomTitleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(10)
            make.width.equalTo(SCREEN_WIDTH - 50)
        }
        
        bottomSaveButton.snp_makeConstraints { (make) in
            make.top.equalTo(7.5)
            make.right.equalTo(-10)
            make.size.equalTo(CGSize(width: 25, height: 25))
        }
        
        // 更新底部工具条高度
        view.layoutIfNeeded()
        bottomToolView.snp_updateConstraints { (make) in
            make.height.equalTo(bottomTitleLabel.height + 20)
        }
        
    }
    
    // MARK: - 懒加载
    /// 内容视图
    private lazy var collectionView: UICollectionView = {
        let myLayout = UICollectionViewFlowLayout()
        myLayout.itemSize = CGSize(width: SCREEN_WIDTH + 10, height: SCREEN_HEIGHT)
        myLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        myLayout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH + 10, height: SCREEN_HEIGHT), collectionViewLayout: myLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.pagingEnabled = true
        collectionView.backgroundColor = UIColor(red:0.110,  green:0.102,  blue:0.110, alpha:1)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(JFPhotoDetailCell.self, forCellWithReuseIdentifier: self.photoIdentifier)
        return collectionView
    }()
    
    /// 底部工具条
    private lazy var bottomToolView: UIView = {
        let bottomToolView = UIView()
        bottomToolView.backgroundColor = self.bgColor
        return bottomToolView
    }()
    
    /// 底部工具栏显示页码
    private lazy var bottomTitleLabel: UILabel = {
        let bottomTitleLabel = UILabel()
        bottomTitleLabel.numberOfLines = 0
        bottomTitleLabel.textColor = UIColor(red:0.945,  green:0.945,  blue:0.945, alpha:1)
        bottomTitleLabel.font = UIFont.systemFontOfSize(15)
        return bottomTitleLabel
    }()
    
    private lazy var bottomSaveButton: UIButton = {
        let bottomSaveButton = UIButton()
        bottomSaveButton.setImage(UIImage(named: "bottom_bar_save_normal"), forState: UIControlState.Normal)
        bottomSaveButton.addTarget(self, action: #selector(didTappedSaveButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return bottomSaveButton
    }()
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension JFNewsPhotoBrowserViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModels.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoIdentifier, forIndexPath: indexPath) as! JFPhotoDetailCell
        cell.delegate = self
        cell.articleModel = photoModels[indexPath.item]
        return cell
    }
}

// MARK: - JFPhotoDetailCellDelegate
extension JFNewsPhotoBrowserViewController: JFPhotoDetailCellDelegate {
    
    /**
     单击事件退出
     */
    func didOneTappedPhotoDetailView(scrollView: UIScrollView) -> Void {
        dismissViewControllerAnimated(true) {}
    }
    
    /**
     双击事件放大
     */
    func didDoubleTappedPhotoDetailView(scrollView: UIScrollView, touchPoint: CGPoint) -> Void {
        if scrollView.zoomScale <= 1.0 {
            let scaleX = touchPoint.x + scrollView.contentOffset.x
            let scaleY = touchPoint.y + scrollView.contentOffset.y
            scrollView.zoomToRect(CGRect(x: scaleX, y: scaleY, width: 10, height: 10), animated: true)
        } else {
            scrollView.setZoomScale(1.0, animated: true)
        }
    }
    
    /**
     长按保存图片
     */
    func didLongPressPhotoDetailView(scrollView: UIScrollView, currentImage: UIImage?) {
    }
}
