//
//  JFPhotoDetailViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/4/7.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFPhotoDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, JFPhotoDetailCellDelegate, JFCommentCommitViewDelegate, JFPhotoBottomBarDelegate {
    
    // MARK: - 属性
    /// 文章详情请求参数
    var photoParam: (classid: String, id: String)? {
        didSet {
            loadPhotoDetail(photoParam!.classid, id: photoParam!.id)
        }
    }
    
    private let photoIdentifier = "photoDetail"
    private var photoModels = [JFPhotoDetailModel]()
    
    // 导航栏/背景颜色
    private let bgColor = UIColor(red:0.110,  green:0.102,  blue:0.110, alpha:0.9)
    
    /// 当前页显示的文字数据
    private var currentPageData: (page: Int, text: String)? {
        didSet {
            topTitleLabel.text = "\(currentPageData!.page) / \(photoModels.count)"
            captionLabel.text = "    \(currentPageData!.text)"
            updateBottomBgViewConstraint()
        }
    }
    
    /// 内容视图
    private lazy var collectionView: UICollectionView = {
        let myLayout = UICollectionViewFlowLayout()
        myLayout.itemSize = CGSize(width: SCREEN_WIDTH + 10, height: SCREEN_HEIGHT)
        myLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        myLayout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH + 10, height: SCREEN_HEIGHT), collectionViewLayout: myLayout)
        collectionView.pagingEnabled = true
        collectionView.backgroundColor = UIColor(red:0.110,  green:0.102,  blue:0.110, alpha:1)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(JFPhotoDetailCell.self, forCellWithReuseIdentifier: self.photoIdentifier)
        return collectionView
    }()
    
    /// 自定义导航栏
    private lazy var navigationBarView: UIView = {
        let navigationBarView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 64))
        navigationBarView.backgroundColor = self.bgColor
        
        // 导航栏右边举报按钮
        let rightButton = UIButton(type: UIButtonType.Custom)
        rightButton.titleLabel?.font = UIFont.systemFontOfSize(16)
        rightButton.setTitle("举报", forState: UIControlState.Normal)
        rightButton.setTitleColor(UIColor(red:0.545, green:0.545, blue:0.545, alpha:1), forState: UIControlState.Normal)
        rightButton.addTarget(self, action: #selector(didTappedRightBarButtonItem(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        rightButton.frame = CGRect(x: SCREEN_WIDTH - 60, y: 20, width: 40, height: 40)
        navigationBarView.addSubview(rightButton)
        return navigationBarView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    // 滚动停止后调用，判断当然显示的第一张图片
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let page = Int(scrollView.contentOffset.x / SCREEN_WIDTH)
        let model = photoModels[page]
        
        currentPageData = (page + 1, model.text!)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModels.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoIdentifier, forIndexPath: indexPath) as! JFPhotoDetailCell
        cell.delegate = self
        cell.model = photoModels[indexPath.item]
        return cell
    }
    
    /**
     加载
     
     - parameter classid: 当前子分类id
     - parameter id:      文章id
     */
    @objc private func loadPhotoDetail(classid: String, id: String) {
        
        let parameters = [
            "table" : "news",
            "classid" : classid,
            "id" : id
        ]
        
        JFNetworkTool.shareNetworkTool.get(ARTICLE_DETAIL, parameters: parameters) { (success, result, error) -> () in
            if success == true {
                if let successResult = result {
                    let morepic = successResult["data"]["content"]["morepic"].arrayValue
                    for picJSON in morepic {
                        let dict = [
                            "title" : picJSON.dictionaryValue["title"]!.stringValue, // 图片标题
                            "picurl" : picJSON.dictionaryValue["url"]!.stringValue,  // 图片url
                            "text" : picJSON.dictionaryValue["caption"]!.stringValue // 图片文字描述
                        ]
                        
                        let model = JFPhotoDetailModel(dict: dict)
                        self.photoModels.append(model)
                    }
                    
                    self.scrollViewDidEndDecelerating(self.collectionView)
                    // 刷新视图
                    self.collectionView.reloadData()
                }
            } else {
                print("error:\(error)")
            }
        }
    }
    
    // MARK: - JFPhotoDetailCellDelegate
    /**
     单击事件
     */
    func didOneTappedPhotoDetailView(scrollView: UIScrollView) -> Void {
        let alpha: CGFloat = UIApplication.sharedApplication().statusBarHidden == false ? 0 : 1
        
        UIView.animateWithDuration(0.25, animations: {
            // 状态栏
            UIApplication.sharedApplication().statusBarHidden = !UIApplication.sharedApplication().statusBarHidden
            
            // 底部视图
            self.bottomBgView.alpha = alpha
            self.bottomToolView.alpha = alpha
            
            // 顶部导航栏
            self.navigationBarView.alpha = alpha
        }) { (_) in
            
        }
    }
    
    /**
     双击事件
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
     点击了提交评论视图的发送按钮
     
     - parameter message: 评论信息
     */
    func didTappedSendButtonWithMessage(message: String) {
        
        let parameters = [
            "classid" : photoParam!.classid,
            "id" : photoParam!.id,
            "userid" : JFAccountModel.shareAccount().id,
            "username" : JFAccountModel.shareAccount().username!,
            "saytext" : message
        ]
        
        JFNetworkTool.shareNetworkTool.get(SUBMIT_COMMENT, parameters: parameters as? [String : AnyObject]) { (success, result, error) in
            if success {
                JFProgressHUD.showInfoWithStatus("评论成功")
            }
        }
    }
    
    // MARK: - 各种tap事件
    @objc private func didTappedRightBarButtonItem(item: UIBarButtonItem) -> Void {
        print("didTappedRightBarButtonItem")
        JFProgressHUD.showInfoWithStatus("举报成功，谢谢您的支持")
    }
    
    // MARK: - JFPhotoBottomBarDelegate
    func didTappedBackButton(button: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func didTappedEditButton(button: UIButton) {
        if JFAccountModel.shareAccount().isLogin {
            let commentCommitView = NSBundle.mainBundle().loadNibNamed("JFCommentCommitView", owner: nil, options: nil).last as! JFCommentCommitView
            commentCommitView.delegate = self
            commentCommitView.show()
        } else {
            presentViewController(JFLoginViewController(nibName: "JFLoginViewController", bundle: nil), animated: true, completion: {
                
            })
        }
    }
    
    func didTappedCommentButton(button: UIButton) {
        let commentVc = JFCommentTableViewController(style: UITableViewStyle.Plain)
        commentVc.param = photoParam
        navigationController?.pushViewController(commentVc, animated: true)
    }
    
    func didTappedCollectButton(button: UIButton) {
        
    }
    
    func didTappedShareButton(button: UIButton) {
        
    }
    
    /**
     准备UI
     */
    @objc private func prepareUI() {
        
        self.edgesForExtendedLayout = .None
        self.automaticallyAdjustsScrollViewInsets = false
        
        view.addSubview(collectionView)
        view.addSubview(navigationBarView)
        view.addSubview(bottomToolView)
        view.addSubview(bottomBgView)
        bottomBgView.addSubview(captionLabel)
        navigationBarView.addSubview(topTitleLabel)
        
        topTitleLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(navigationBarView)
            make.top.equalTo(20)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        bottomToolView.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(40)
        }
        
        bottomBgView.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(bottomToolView.snp_top)
            make.height.equalTo(20)
        }
        
        captionLabel.snp_makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(10)
            make.width.equalTo(SCREEN_WIDTH - 40)
        }
        
        updateBottomBgViewConstraint()
    }
    
    /**
     更新底部详情视图的高度
     */
    @objc private func updateBottomBgViewConstraint() {
        
        view.layoutIfNeeded()
        bottomBgView.snp_updateConstraints { (make) in
            make.height.equalTo(captionLabel.height + 20)
        }
    }
    
    // MARK: - 懒加载
    /// 底部文字透明背景视图
    private lazy var bottomBgView: UIView = {
        let bottomBgView = UIView()
        bottomBgView.backgroundColor = self.bgColor
        return bottomBgView
    }()
    
    /// 文字描述
    private lazy var captionLabel: UILabel = {
        let captionLabel = UILabel()
        captionLabel.textColor = UIColor(red:0.945,  green:0.945,  blue:0.945, alpha:1)
        captionLabel.numberOfLines = 0
        captionLabel.font = UIFont.systemFontOfSize(15)
        return captionLabel
    }()
    
    /// 底部工具条
    private lazy var bottomToolView: UIView = {
        let bottomToolView = NSBundle.mainBundle().loadNibNamed("JFPhotoBottomBar", owner: nil, options: nil).last as! JFPhotoBottomBar
        bottomToolView.backgroundColor = self.bgColor
        bottomToolView.delegate = self
        return bottomToolView
    }()
    
    /// 顶部导航栏显示页码
    private lazy var topTitleLabel: UILabel = {
        let topTitleLabel = UILabel()
        topTitleLabel.textColor = UIColor(red:0.945,  green:0.945,  blue:0.945, alpha:1)
        topTitleLabel.font = UIFont.systemFontOfSize(15)
        return topTitleLabel
    }()
}

