//
//  JFPhotoDetailViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/4/7.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage
import pop

class JFPhotoDetailViewController: UIViewController {
    
    // MARK: - 属性
    /// 文章详情请求参数
    var photoParam: (classid: String, id: String)? {
        didSet {
            loadPhotoDetail(Int(photoParam!.classid)!, id: Int(photoParam!.id)!)
        }
    }
    
    /// 详情页面模型
    var model: JFArticleDetailModel? {
        didSet {
            
            // 图片模型数组
            photoModels = model!.morepics!
            
            // 标题url
            self.titleurl = model?.titleurl
            
            // 更新评论数量
            if model?.plnum != "0" {
                self.bottomToolView.commentButton.setTitle(model!.plnum!, forState: UIControlState.Normal)
            }
            
            // 更新收藏状态
            self.bottomToolView.collectionButton.selected = model?.havefava == "1"
            
        }
    }
    
    /// 当前页显示的文字数据
    private var currentPageData: (page: Int, text: String)? {
        didSet {
            topTitleLabel.text = "\(currentPageData!.page) / \(photoModels.count)"
            captionLabel.text = "\(currentPageData!.text)"
            updatebottomScrollViewConstraint()
        }
    }
    
    /// 用来做分享的标题连接
    var titleurl: String?
    
    // 导航栏/背景颜色 带透明的
    private let bgColor = UIColor(red:0.110,  green:0.102,  blue:0.110, alpha:0.7)
    
    private let photoIdentifier = "photoDetail"
    private var photoModels = [JFPhotoDetailModel]()
    
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
     滚动停止后调用，判断当然显示的第一张图片
     */
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let page = Int(scrollView.contentOffset.x / SCREEN_WIDTH)
        let model = photoModels[page]
        
        currentPageData = (page + 1, model.caption!)
        
        // 每次滚动，文字区域都滑动到最顶部
        bottomScrollView.setContentOffset(CGPoint(x: bottomScrollView.contentOffset.x, y: 0), animated: false)
    }
    
    /**
     加载正文数据
     
     - parameter classid: 当前子分类id
     - parameter id:      文章id
     */
    func loadPhotoDetail(classid: Int, id: Int) {
        
        activityView.startAnimating()
        JFArticleDetailModel.loadNewsDetail(classid, id: id) { (articleDetailModel, error) in
            self.activityView.stopAnimating()
            
            guard let model = articleDetailModel where error == nil else {return}
            self.model = model
            
            self.scrollViewDidEndDecelerating(self.collectionView)
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - 各种tap事件
    @objc private func didTappedRightBarButtonItem(item: UIBarButtonItem) -> Void {
        print("didTappedRightBarButtonItem")
        JFProgressHUD.showInfoWithStatus("举报成功，谢谢您的支持")
    }
    
    /**
     准备UI
     */
    @objc private func prepareUI() {
        
        view.backgroundColor = UIColor(red:0.110,  green:0.102,  blue:0.110, alpha:1)
        automaticallyAdjustsScrollViewInsets = false
        
        view.addSubview(collectionView)
        view.addSubview(navigationBarView)
        view.addSubview(bottomToolView)
        view.addSubview(bottomBgView)
        view.addSubview(bottomScrollView)
        bottomScrollView.addSubview(captionLabel)
        navigationBarView.addSubview(topTitleLabel)
        view.addSubview(activityView)
        
        topTitleLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(navigationBarView)
            make.top.equalTo(20)
            make.size.equalTo(CGSize(width: 80, height: 40))
        }
        
        bottomToolView.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(45)
        }
        
        bottomBgView.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(bottomToolView.snp_top)
            make.height.equalTo(40)
        }
        
        bottomScrollView.snp_makeConstraints { (make) in
            make.left.equalTo(12)
            make.width.equalTo(SCREEN_WIDTH - 24)
            make.bottom.equalTo(bottomToolView.snp_top).offset(-30)
            make.height.equalTo(40)
        }
        
        captionLabel.snp_makeConstraints { (make) in
            make.left.equalTo(0)
            make.width.equalTo(SCREEN_WIDTH - 30)
            make.top.equalTo(10)
        }
        
        updatebottomScrollViewConstraint()
    }
    
    /**
     更新底部详情视图的高度
     */
    private func updatebottomScrollViewConstraint() {
        
        view.layoutIfNeeded()
        // 如果文字高度超过50，就可以滑动
        if captionLabel.height > 50 {
            bottomScrollView.snp_updateConstraints { (make) in
                make.height.equalTo(70)
            }
            bottomScrollView.contentSize = CGSize(width: 0, height: captionLabel.height + 20)
            bottomScrollView.scrollEnabled = true
            
            // 重新约束背景
            bottomBgView.snp_updateConstraints(closure: { (make) in
                make.height.equalTo(110)
            })
        } else {
            bottomScrollView.snp_updateConstraints { (make) in
                make.height.equalTo(captionLabel.height + 20)
            }
            bottomScrollView.scrollEnabled = false
            
            // 重新约束背景 - 比滚动区域高度顶部高10 底部高30，加起来就是40
            bottomBgView.snp_updateConstraints(closure: { (make) in
                make.height.equalTo(captionLabel.height + 60)
            })
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
    
    /// 活动指示器
    private lazy var activityView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityView.center = self.view.center
        return activityView
    }()
    
    /// 底部文字透明滚动视图
    private lazy var bottomScrollView: UIScrollView = {
        let bottomScrollView = UIScrollView()
        bottomScrollView.indicatorStyle = .White
        bottomScrollView.backgroundColor = UIColor.clearColor()
        return bottomScrollView
    }()
    
    /// 底部背景视图
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
        captionLabel.font = UIFont.systemFontOfSize(14)
        return captionLabel
    }()
    
    /// 底部工具条
    private lazy var bottomToolView: JFPhotoBottomBar = {
        let bottomToolView = NSBundle.mainBundle().loadNibNamed("JFPhotoBottomBar", owner: nil, options: nil).last as! JFPhotoBottomBar
        bottomToolView.backgroundColor = self.bgColor
        bottomToolView.delegate = self
        return bottomToolView
    }()
    
    /// 顶部导航栏显示页码
    private lazy var topTitleLabel: UILabel = {
        let topTitleLabel = UILabel()
        topTitleLabel.textAlignment = .Center
        topTitleLabel.textColor = UIColor(red:0.945,  green:0.945,  blue:0.945, alpha:1)
        topTitleLabel.font = UIFont.systemFontOfSize(15)
        return topTitleLabel
    }()
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension JFPhotoDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModels.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoIdentifier, forIndexPath: indexPath) as! JFPhotoDetailCell
        cell.delegate = self
        cell.model = photoModels[indexPath.item]
        return cell
    }
}

// MARK: - JFCommentCommitViewDelegate, JFPhotoBottomBarDelegate
extension JFPhotoDetailViewController: JFCommentCommitViewDelegate, JFPhotoBottomBarDelegate {
    
    /**
     返回
     */
    func didTappedBackButton(button: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    /**
     发布评论
     */
    func didTappedEditButton(button: UIButton) {
        let commentCommitView = NSBundle.mainBundle().loadNibNamed("JFCommentCommitView", owner: nil, options: nil).last as! JFCommentCommitView
        commentCommitView.delegate = self
        commentCommitView.show()
    }
    
    /**
     评论列表
     */
    func didTappedCommentButton(button: UIButton) {
        let commentVc = JFCommentTableViewController(style: UITableViewStyle.Plain)
        commentVc.param = photoParam
        navigationController?.pushViewController(commentVc, animated: true)
    }
    
    /**
     收藏
     */
    func didTappedCollectButton(button: UIButton) {
        
        if JFAccountModel.isLogin() {
            let parameters: [String : AnyObject] = [
                "username" : JFAccountModel.shareAccount()!.username!,
                "userid" : JFAccountModel.shareAccount()!.id,
                "token" : JFAccountModel.shareAccount()!.token!,
                "classid" : photoParam!.classid,
                "id" : photoParam!.id
            ]
            
            JFNetworkTool.shareNetworkTool.post(ADD_DEL_FAVA, parameters: parameters) { (success, result, error) in
                
                guard let successResult = result where success == true else {return}
                if successResult["result"]["status"].intValue == 1 {
                    // 增加成功
                    JFProgressHUD.showSuccessWithStatus("收藏成功")
                    button.selected = true
                    
                } else if successResult["result"]["status"].intValue == 3 {
                    // 删除成功
                    JFProgressHUD.showSuccessWithStatus("取消收藏")
                    button.selected = false
                }
                
                jf_setupButtonSpringAnimation(button)
            }
        } else {
            presentViewController(JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil)), animated: true, completion: {
            })
        }
    }
    
    /**
     分享
     */
    func didTappedShareButton(button: UIButton) {
        
        guard let page = currentPageData?.page else {return}
        
        // 从缓存中获取标题图片
        let currentModel = photoModels[page - 1]
        var image = YYImageCache.sharedCache().getImageForKey(currentModel.bigpic!)
        
        if image != nil && (image?.size.width > 300 || image?.size.height > 300) {
            image = image?.resizeImageWithNewSize(CGSize(width: 300, height: 300 * image!.size.height / image!.size.width))
        }
        
        let shareParames = NSMutableDictionary()
        shareParames.SSDKSetupShareParamsByText(currentModel.caption,
                                                images : image,
                                                url : NSURL(string: self.titleurl!.hasPrefix("http") ? self.titleurl! : "\(BASE_URL)\(self.titleurl!)"),
                                                title : currentModel.title,
                                                type : SSDKContentType.Auto)
        
        let items = [
            SSDKPlatformType.TypeQQ.rawValue,
            SSDKPlatformType.TypeWechat.rawValue,
            SSDKPlatformType.TypeSinaWeibo.rawValue
        ]
        
        ShareSDK.showShareActionSheet(nil, items: items, shareParams: shareParames) { (state : SSDKResponseState, platform: SSDKPlatformType, userData : [NSObject : AnyObject]!, contentEntity :SSDKContentEntity!, error : NSError!, end: Bool) in
            switch state {
                
            case SSDKResponseState.Success:
                print("分享成功")
            case SSDKResponseState.Fail:
                print("分享失败,错误描述:\(error)")
            case SSDKResponseState.Cancel:
                print("取消分享")
            default:
                break
            }
        }
    }
    
    /**
     点击了提交评论视图的发送按钮
     
     - parameter message: 评论信息
     */
    func didTappedSendButtonWithMessage(message: String) {
        
        var parameters = [String : AnyObject]()
        
        if JFAccountModel.isLogin() {
            parameters = [
                "classid" : photoParam!.classid,
                "id" : photoParam!.id,
                "userid" : JFAccountModel.shareAccount()!.id,
                "nomember" : "0",
                "username" : JFAccountModel.shareAccount()!.username!,
                "token" : JFAccountModel.shareAccount()!.token!,
                "saytext" : message
            ]
        } else {
            parameters = [
                "classid" : photoParam!.classid,
                "id" : photoParam!.id,
                "nomember" : "1",
                "saytext" : message
            ]
        }
        
        JFNetworkTool.shareNetworkTool.get(SUBMIT_COMMENT, parameters: parameters) { (success, result, error) in
            if success {
                self.loadPhotoDetail(Int(self.photoParam!.classid)!, id: Int(self.photoParam!.id)!)
            }
        }
    }
}

// MARK: - JFPhotoDetailCellDelegate
extension JFPhotoDetailViewController: JFPhotoDetailCellDelegate {
    
    /**
     单击事件
     */
    func didOneTappedPhotoDetailView(scrollView: UIScrollView) -> Void {
        
        let alpha: CGFloat = UIApplication.sharedApplication().statusBarHidden == false ? 0 : 1
        
        UIView.animateWithDuration(0.25, animations: {
            
            // 状态栏
            UIApplication.sharedApplication().setStatusBarHidden(!UIApplication.sharedApplication().statusBarHidden, withAnimation: UIStatusBarAnimation.Slide)
            
            // 隐藏和显示的平移效果
            if alpha == 0 {
                self.bottomBgView.transform = CGAffineTransformTranslate(self.bottomBgView.transform, 0, 20)
                self.bottomScrollView.transform = CGAffineTransformTranslate(self.bottomScrollView.transform, 0, 20)
                self.bottomToolView.transform = CGAffineTransformTranslate(self.bottomToolView.transform, 0, 20)
                self.navigationBarView.transform = CGAffineTransformTranslate(self.navigationBarView.transform, 0, -20)
            } else {
                self.bottomBgView.transform = CGAffineTransformTranslate(self.bottomBgView.transform, 0, -20)
                self.bottomScrollView.transform = CGAffineTransformTranslate(self.bottomScrollView.transform, 0, -20)
                self.bottomToolView.transform = CGAffineTransformTranslate(self.bottomToolView.transform, 0, -20)
                self.navigationBarView.transform = CGAffineTransformTranslate(self.navigationBarView.transform, 0, 20)
            }
            
            // 底部视图
            self.bottomBgView.alpha = alpha
            self.bottomScrollView.alpha = alpha
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
     长按保存图片
     */
    func didLongPressPhotoDetailView(scrollView: UIScrollView, currentImage: UIImage?) {
        
        // 如果图片都还没加载出来，保存个毛线
        guard let image = currentImage else {return}
        
        let alertC = UIAlertController(title: "保存图片到相册", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        let save = UIAlertAction(title: "保存", style: UIAlertActionStyle.Default) { (action) in
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(JFPhotoDetailViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel) { (action) in }
        alertC.addAction(save)
        alertC.addAction(cancel)
        presentViewController(alertC, animated: true) {}
    }
    
    /**
     持续滑动中判断偏移量
     */
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x <= -30 {
            navigationController?.popViewControllerAnimated(true)
        }
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
}
