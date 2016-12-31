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
                self.bottomToolView.commentButton.setTitle(model!.plnum!, for: UIControlState())
            }
            
            // 更新收藏状态
            self.bottomToolView.collectionButton.isSelected = model?.havefava == "1"
            
        }
    }
    
    /// 当前页显示的文字数据
    fileprivate var currentPageData: (page: Int, text: String)? {
        didSet {
            topTitleLabel.text = "\(currentPageData!.page) / \(photoModels.count)"
            captionLabel.text = "\(currentPageData!.text)"
            updatebottomScrollViewConstraint()
        }
    }
    
    /// 用来做分享的标题连接
    var titleurl: String?
    
    // 导航栏/背景颜色 带透明的
    fileprivate let bgColor = UIColor(red:0.110,  green:0.102,  blue:0.110, alpha:0.7)
    
    fileprivate let photoIdentifier = "photoDetail"
    fileprivate var photoModels = [JFPhotoDetailModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    /**
     滚动停止后调用，判断当然显示的第一张图片
     */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
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
    func loadPhotoDetail(_ classid: Int, id: Int) {
        
        JFArticleDetailModel.loadNewsDetail(classid, id: id) { (articleDetailModel, error) in
            
            guard let model = articleDetailModel, error == nil else {return}
            self.model = model
            
            self.scrollViewDidEndDecelerating(self.collectionView)
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - 各种tap事件
    @objc fileprivate func didTappedRightBarButtonItem(_ item: UIBarButtonItem) -> Void {
        print("didTappedRightBarButtonItem")
        JFProgressHUD.showInfoWithStatus("举报成功，谢谢您的支持")
    }
    
    /**
     准备UI
     */
    @objc fileprivate func prepareUI() {
        
        view.backgroundColor = UIColor(red:0.110,  green:0.102,  blue:0.110, alpha:1)
        automaticallyAdjustsScrollViewInsets = false
        
        view.addSubview(collectionView)
        view.addSubview(navigationBarView)
        view.addSubview(bottomToolView)
        view.addSubview(bottomBgView)
        view.addSubview(bottomScrollView)
        bottomScrollView.addSubview(captionLabel)
        navigationBarView.addSubview(topTitleLabel)
        
        topTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(navigationBarView)
            make.top.equalTo(20)
            make.size.equalTo(CGSize(width: 80, height: 40))
        }
        
        bottomToolView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(45)
        }
        
        bottomBgView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(bottomToolView.snp.top)
            make.height.equalTo(40)
        }
        
        bottomScrollView.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.width.equalTo(SCREEN_WIDTH - 24)
            make.bottom.equalTo(bottomToolView.snp.top).offset(-30)
            make.height.equalTo(40)
        }
        
        captionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.width.equalTo(SCREEN_WIDTH - 30)
            make.top.equalTo(10)
        }
        
        updatebottomScrollViewConstraint()
    }
    
    /**
     更新底部详情视图的高度
     */
    fileprivate func updatebottomScrollViewConstraint() {
        
        view.layoutIfNeeded()
        // 如果文字高度超过50，就可以滑动
        if captionLabel.height > 50 {
            bottomScrollView.snp.updateConstraints { (make) in
                make.height.equalTo(70)
            }
            bottomScrollView.contentSize = CGSize(width: 0, height: captionLabel.height + 20)
            bottomScrollView.isScrollEnabled = true
            
            // 重新约束背景
            bottomBgView.snp.updateConstraints({ (make) in
                make.height.equalTo(110)
            })
        } else {
            bottomScrollView.snp.updateConstraints { (make) in
                make.height.equalTo(captionLabel.height + 20)
            }
            bottomScrollView.isScrollEnabled = false
            
            // 重新约束背景 - 比滚动区域高度顶部高10 底部高30，加起来就是40
            bottomBgView.snp.updateConstraints({ (make) in
                make.height.equalTo(captionLabel.height + 60)
            })
        }
        
    }
    
    // MARK: - 懒加载
    /// 内容视图
    fileprivate lazy var collectionView: UICollectionView = {
        let myLayout = UICollectionViewFlowLayout()
        myLayout.itemSize = CGSize(width: SCREEN_WIDTH + 10, height: SCREEN_HEIGHT)
        myLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        myLayout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH + 10, height: SCREEN_HEIGHT), collectionViewLayout: myLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor(red:0.110,  green:0.102,  blue:0.110, alpha:1)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(JFPhotoDetailCell.self, forCellWithReuseIdentifier: self.photoIdentifier)
        return collectionView
    }()
    
    /// 自定义导航栏
    fileprivate lazy var navigationBarView: UIView = {
        let navigationBarView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 64))
        navigationBarView.backgroundColor = self.bgColor
        
        // 导航栏右边举报按钮
        let rightButton = UIButton(type: UIButtonType.custom)
        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        rightButton.setTitle("举报", for: UIControlState())
        rightButton.setTitleColor(UIColor(red:0.545, green:0.545, blue:0.545, alpha:1), for: UIControlState())
        rightButton.addTarget(self, action: #selector(didTappedRightBarButtonItem(_:)), for: UIControlEvents.touchUpInside)
        rightButton.frame = CGRect(x: SCREEN_WIDTH - 60, y: 20, width: 40, height: 40)
        navigationBarView.addSubview(rightButton)
        return navigationBarView
    }()
    
    /// 底部文字透明滚动视图
    fileprivate lazy var bottomScrollView: UIScrollView = {
        let bottomScrollView = UIScrollView()
        bottomScrollView.indicatorStyle = .white
        bottomScrollView.backgroundColor = UIColor.clear
        return bottomScrollView
    }()
    
    /// 底部背景视图
    fileprivate lazy var bottomBgView: UIView = {
        let bottomBgView = UIView()
        bottomBgView.backgroundColor = self.bgColor
        return bottomBgView
    }()
    
    /// 文字描述
    fileprivate lazy var captionLabel: UILabel = {
        let captionLabel = UILabel()
        captionLabel.textColor = UIColor(red:0.945,  green:0.945,  blue:0.945, alpha:1)
        captionLabel.numberOfLines = 0
        captionLabel.font = UIFont.systemFont(ofSize: 14)
        return captionLabel
    }()
    
    /// 底部工具条
    fileprivate lazy var bottomToolView: JFPhotoBottomBar = {
        let bottomToolView = Bundle.main.loadNibNamed("JFPhotoBottomBar", owner: nil, options: nil)?.last as! JFPhotoBottomBar
        bottomToolView.backgroundColor = self.bgColor
        bottomToolView.delegate = self
        return bottomToolView
    }()
    
    /// 顶部导航栏显示页码
    fileprivate lazy var topTitleLabel: UILabel = {
        let topTitleLabel = UILabel()
        topTitleLabel.textAlignment = .center
        topTitleLabel.textColor = UIColor(red:0.945,  green:0.945,  blue:0.945, alpha:1)
        topTitleLabel.font = UIFont.systemFont(ofSize: 15)
        return topTitleLabel
    }()
    
    /// 分享视图
    fileprivate lazy var shareView: JFShareView = {
        let shareView = JFShareView()
        shareView.delegate = self
        return shareView
    }()
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension JFPhotoDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoIdentifier, for: indexPath) as! JFPhotoDetailCell
        cell.delegate = self
        cell.urlString = photoModels[indexPath.item].bigpic
        return cell
    }
}

// MARK: - JFCommentCommitViewDelegate, JFPhotoBottomBarDelegate
extension JFPhotoDetailViewController: JFCommentCommitViewDelegate, JFPhotoBottomBarDelegate {
    
    /**
     返回
     */
    func didTappedBackButton(_ button: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    /**
     发布评论
     */
    func didTappedEditButton(_ button: UIButton) {
        let commentCommitView = Bundle.main.loadNibNamed("JFCommentCommitView", owner: nil, options: nil)?.last as! JFCommentCommitView
        commentCommitView.delegate = self
        commentCommitView.show()
    }
    
    /**
     评论列表
     */
    func didTappedCommentButton(_ button: UIButton) {
        let commentVc = JFCommentTableViewController(style: UITableViewStyle.plain)
        commentVc.param = photoParam
        navigationController?.pushViewController(commentVc, animated: true)
    }
    
    /**
     收藏
     */
    func didTappedCollectButton(_ button: UIButton) {
        
        if JFAccountModel.isLogin() {
            let parameters: [String : AnyObject] = [
                "username" : JFAccountModel.shareAccount()!.username! as AnyObject,
                "userid" : JFAccountModel.shareAccount()!.id as AnyObject,
                "token" : JFAccountModel.shareAccount()!.token! as AnyObject,
                "classid" : photoParam!.classid as AnyObject,
                "id" : photoParam!.id as AnyObject
            ]
            
            JFNetworkTool.shareNetworkTool.post(ADD_DEL_FAVA, parameters: parameters) { (status, result, tipString) in
                
                if status != .success {
                    return
                }
                
                guard let successResult = result else {return}
                if successResult["result"]["status"].intValue == 1 {
                    // 增加成功
                    JFProgressHUD.showSuccessWithStatus("收藏成功")
                    button.isSelected = true
                    
                } else if successResult["result"]["status"].intValue == 3 {
                    // 删除成功
                    JFProgressHUD.showSuccessWithStatus("取消收藏")
                    button.isSelected = false
                }
                
                jf_setupButtonSpringAnimation(button)
            }
        } else {
            present(JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil)), animated: true, completion: {
            })
        }
    }
    
    /**
     分享
     */
    func didTappedShareButton(_ button: UIButton) {
        
        if JFShareItemModel.loadShareItems().count == 0 {
            JFProgressHUD.showInfoWithStatus("没有可分享内容")
            return
        }
        
        // 弹出分享视图
        shareView.showShareView()
    }
    
    /**
     点击了提交评论视图的发送按钮
     
     - parameter message: 评论信息
     */
    func didTappedSendButtonWithMessage(_ message: String) {
        
        var parameters = [String : AnyObject]()
        
        if JFAccountModel.isLogin() {
            parameters = [
                "classid" : photoParam!.classid as AnyObject,
                "id" : photoParam!.id as AnyObject,
                "userid" : JFAccountModel.shareAccount()!.id as AnyObject,
                "nomember" : "0" as AnyObject,
                "username" : JFAccountModel.shareAccount()!.username! as AnyObject,
                "token" : JFAccountModel.shareAccount()!.token! as AnyObject,
                "saytext" : message as AnyObject
            ]
        } else {
            parameters = [
                "classid" : photoParam!.classid as AnyObject,
                "id" : photoParam!.id as AnyObject,
                "nomember" : "1" as AnyObject,
                "saytext" : message as AnyObject
            ]
        }
        
        JFNetworkTool.shareNetworkTool.get(SUBMIT_COMMENT, parameters: parameters) { (status, result, tipString) in
            if status == .success {
                self.loadPhotoDetail(Int(self.photoParam!.classid)!, id: Int(self.photoParam!.id)!)
            }
        }
    }
}

// MARK: - JFShareViewDelegate
extension JFPhotoDetailViewController: JFShareViewDelegate {
    
    func share(type: JFShareType) {
        
        let platformType: SSDKPlatformType!
        switch type {
        case .qqFriend:
            platformType = SSDKPlatformType.subTypeQZone // 尼玛，这竟然是反的。。ShareSDK bug
        case .qqQzone:
            platformType = SSDKPlatformType.subTypeQQFriend // 尼玛，这竟然是反的。。
        case .weixinFriend:
            platformType = SSDKPlatformType.subTypeWechatSession
        case .friendCircle:
            platformType = SSDKPlatformType.subTypeWechatTimeline
        }
        
        guard let page = currentPageData?.page else {return}
        
        // 从缓存中获取标题图片
        let currentModel = photoModels[page - 1]
        var image = YYImageCache.shared().getImageForKey(currentModel.bigpic!)!
        
        if image.size.width > 300.0 || image.size.height > 300.0 {
            image = image.resizeImageWithNewSize(CGSize(width: 300, height: 300 * image.size.height / image.size.width))
        }
        
        let shareParames = NSMutableDictionary()
        shareParames.ssdkSetupShareParams(byText: currentModel.caption,
                                          images : image,
                                          url : URL(string: self.titleurl!.hasPrefix("http") ? self.titleurl! : "\(BASE_URL)\(self.titleurl!)"),
                                          title : currentModel.title,
                                          type : SSDKContentType.auto)
        
        ShareSDK.share(platformType, parameters: shareParames) { (state, _, entity, error) in
            switch state {
            case SSDKResponseState.success:
                print("分享成功")
            case SSDKResponseState.fail:
                print("授权失败,错误描述:\(error)")
            case SSDKResponseState.cancel:
                print("操作取消")
            default:
                break
            }
        }
        
    }
}

// MARK: - JFPhotoDetailCellDelegate
extension JFPhotoDetailViewController: JFPhotoDetailCellDelegate {
    
    /**
     单击事件
     */
    func didOneTappedPhotoDetailView(_ scrollView: UIScrollView) -> Void {
        
        let alpha: CGFloat = UIApplication.shared.isStatusBarHidden == false ? 0 : 1
        
        UIView.animate(withDuration: 0.25, animations: {
            
            // 状态栏
            UIApplication.shared.setStatusBarHidden(!UIApplication.shared.isStatusBarHidden, with: UIStatusBarAnimation.slide)
            
            // 隐藏和显示的平移效果
            if alpha == 0 {
                self.bottomBgView.transform = self.bottomBgView.transform.translatedBy(x: 0, y: 20)
                self.bottomScrollView.transform = self.bottomScrollView.transform.translatedBy(x: 0, y: 20)
                self.bottomToolView.transform = self.bottomToolView.transform.translatedBy(x: 0, y: 20)
                self.navigationBarView.transform = self.navigationBarView.transform.translatedBy(x: 0, y: -20)
            } else {
                self.bottomBgView.transform = self.bottomBgView.transform.translatedBy(x: 0, y: -20)
                self.bottomScrollView.transform = self.bottomScrollView.transform.translatedBy(x: 0, y: -20)
                self.bottomToolView.transform = self.bottomToolView.transform.translatedBy(x: 0, y: -20)
                self.navigationBarView.transform = self.navigationBarView.transform.translatedBy(x: 0, y: 20)
            }
            
            // 底部视图
            self.bottomBgView.alpha = alpha
            self.bottomScrollView.alpha = alpha
            self.bottomToolView.alpha = alpha
            
            // 顶部导航栏
            self.navigationBarView.alpha = alpha
        }, completion: { (_) in
            
        }) 
    }
    
    /**
     双击事件
     */
    func didDoubleTappedPhotoDetailView(_ scrollView: UIScrollView, touchPoint: CGPoint) -> Void {
        
        if scrollView.zoomScale <= 1.0 {
            let scaleX = touchPoint.x + scrollView.contentOffset.x
            let scaleY = touchPoint.y + scrollView.contentOffset.y
            scrollView.zoom(to: CGRect(x: scaleX, y: scaleY, width: 10, height: 10), animated: true)
        } else {
            scrollView.setZoomScale(1.0, animated: true)
        }
    }
    
    /**
     长按保存图片
     */
    func didLongPressPhotoDetailView(_ scrollView: UIScrollView, currentImage: UIImage?) {
        
        // 如果图片都还没加载出来，保存个毛线
        guard let image = currentImage else {return}
        
        let alertC = UIAlertController(title: "保存图片到相册", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let save = UIAlertAction(title: "保存", style: UIAlertActionStyle.default) { (action) in
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(JFPhotoDetailViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel) { (action) in }
        alertC.addAction(save)
        alertC.addAction(cancel)
        present(alertC, animated: true) {}
    }
    
    /**
     持续滑动中判断偏移量
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x <= -30 {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    /**
     保存图片到相册
     */
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if let _ = error {
            JFProgressHUD.showInfoWithStatus("保存失败")
        } else {
            JFProgressHUD.showInfoWithStatus("保存成功")
        }
    }
}
