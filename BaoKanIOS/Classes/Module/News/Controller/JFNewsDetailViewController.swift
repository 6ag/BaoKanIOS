//
//  JFNewsDetailViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/2/19.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

class JFNewsDetailViewController: UIViewController {
    
    var bridge: WebViewJavascriptBridge?
    
    // MARK: - 属性
    var contentOffsetY: CGFloat = 0.0
    
    /// 文章详情请求参数
    var articleParam: (classid: String, id: String)?
    
    /// 是否是分享文章
    var isShareArticle = true
    
    /// 详情页面模型
    var model: JFArticleDetailModel? {
        didSet {
            if !isLoaded {
                // 没有加载过，才去初始化webView - 保证只初始化一次
                loadWebViewContent(model!)
            }
            
            // 更新收藏状态
            bottomBarView.collectionButton.isSelected = model!.havefava == "1"
            
            // 相关链接
            if let links = model?.otherLinks {
                otherLinks = links
            }
            
        }
    }
    
    // 临时广告图片
    let adImageView = UIImageView(frame: CGRect(x: 12, y: 0, width: SCREEN_WIDTH - 24, height: 160))
    
    /// 是否已经加载过webView
    var isLoaded = false
    
    /// 相关连接模型
    var otherLinks = [JFOtherLinkModel]()
    /// 评论模型
    var commentList = [JFCommentModel]()
    
    // cell标识符
    let detailContentIdentifier = "detailContentIdentifier"
    let detailStarAndShareIdentifier = "detailStarAndShareIdentifier"
    let detailOtherLinkIdentifier = "detailOtherLinkIdentifier"
    let detailOtherLinkNoneIdentifier = "detailOtherLinkNoneIdentifier"
    let detailCommentIdentifier = "detailCommentIdentifier"
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adImageView.isUserInteractionEnabled = true
        adImageView.image = UIImage(named: "temp_ad")?.redrawImage(size: adImageView.bounds.size)
        adImageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(saveAdImage(_:))))
        
        setupWebViewJavascriptBridge()
        prepareUI()
        updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barTintColor = NAVIGATIONBAR_WHITE_COLOR
    }
    
    /**
     长按保存广告图
     */
    func saveAdImage(_ longPress: UILongPressGestureRecognizer) {
        if longPress.state == .began {
            isShareArticle = false
            shareView.showShareView()
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
    
    /**
     配置WebViewJavascriptBridge
     */
    fileprivate func setupWebViewJavascriptBridge() {
        
        bridge = WebViewJavascriptBridge(for: webView, webViewDelegate: self, handler: { (data, responseCallback) in
            responseCallback!("Response for message from ObjC")
            
            guard let dict = data as! [String : AnyObject]! else {return}
            
            let index = Int(dict["index"] as! NSNumber)
            let x = CGFloat(dict["x"] as! NSNumber)
            let y = CGFloat(dict["y"] as! NSNumber) - self.tableView.contentOffset.y
            let width = CGFloat(dict["width"] as! NSNumber)
            let height = CGFloat(dict["height"] as! NSNumber)
            let url = dict["url"] as! String
            
            let bgView = UIView(frame: SCREEN_BOUNDS)
            bgView.backgroundColor = UIColor(red:0.110,  green:0.102,  blue:0.110, alpha:1)
            self.view.addSubview(bgView)
            
            let tempImageView = UIImageView(frame: CGRect(x: x, y: y, width: width, height: height))
            tempImageView.yy_setImage(with: URL(string: url), placeholder: UIImage(contentsOfFile: Bundle.main.path(forResource: "www/images/loading.jpg", ofType: nil)!))
            self.view.addSubview(tempImageView)
            
            // 显示出图片浏览器
            let newsPhotoBrowserVc = JFNewsPhotoBrowserViewController()
            newsPhotoBrowserVc.transitioningDelegate = self
            newsPhotoBrowserVc.modalPresentationStyle = .custom
            newsPhotoBrowserVc.photoParam = (self.model!.allphoto!, index)
            self.present(newsPhotoBrowserVc, animated: true, completion: {})
            
            UIView.animate(withDuration: 0.3, animations: {
                tempImageView.frame = CGRect(x: 0, y: (SCREEN_HEIGHT - height * (SCREEN_WIDTH / width)) * 0.5, width: SCREEN_WIDTH, height: height * (SCREEN_WIDTH / width))
                }, completion: { (_) in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                        bgView.removeFromSuperview()
                        tempImageView.removeFromSuperview()
                    }
            })
            
        })
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        
        // 注册cell
        tableView.register(UINib(nibName: "JFStarAndShareCell", bundle: nil), forCellReuseIdentifier: detailStarAndShareIdentifier)
        tableView.register(UINib(nibName: "JFDetailOtherCell", bundle: nil), forCellReuseIdentifier: detailOtherLinkIdentifier)
        tableView.register(UINib(nibName: "JFDetailOtherNoneCell", bundle: nil), forCellReuseIdentifier: detailOtherLinkNoneIdentifier)
        tableView.register(UINib(nibName: "JFCommentCell", bundle: nil), forCellReuseIdentifier: detailCommentIdentifier)
        tableView.tableHeaderView = webView
        tableView.tableFooterView = closeDetailView
        
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        view.addSubview(topBarView)
        view.addSubview(bottomBarView)
        view.addSubview(activityView)
        
        topBarView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(0)
            make.height.equalTo(20)
        }
        bottomBarView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(45)
        }
    }
    
    /**
     请求页面数据和评论数据
     */
    fileprivate func updateData() {
        
        loadNewsDetail(Int(articleParam!.classid)!, id: Int(articleParam!.id)!)
        loadCommentList(Int(articleParam!.classid)!, id: Int(articleParam!.id)!)
    }
    
    /**
     加载正文数据
     
     - parameter classid: 当前子分类id
     - parameter id:      文章id
     */
    func loadNewsDetail(_ classid: Int, id: Int) {
        
        activityView.startAnimating()
        JFArticleDetailModel.loadNewsDetail(classid, id: id) { (articleDetailModel, error) in
            
            guard let model = articleDetailModel else {return}
            
            self.model = model
            self.tableView.reloadData()
        }
    }
    
    // MARK: - 懒加载
    /// 尾部关闭视图
    fileprivate lazy var closeDetailView: JFCloseDetailView = {
        let closeDetailView = JFCloseDetailView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 26))
        closeDetailView.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        closeDetailView.setTitleColor(UIColor(white: 0.2, alpha: 1), for: UIControlState())
        closeDetailView.setTitleColor(UIColor(white: 0.2, alpha: 1), for: UIControlState.selected)
        closeDetailView.isSelected = false
        closeDetailView.setTitle("上拉关闭当前页", for: UIControlState())
        closeDetailView.setImage(UIImage(named: "newscontent_drag_arrow"), for: UIControlState())
        closeDetailView.setTitle("释放关闭当前页", for: UIControlState.selected)
        closeDetailView.setImage(UIImage(named: "newscontent_drag_return"), for: UIControlState.selected)
        return closeDetailView
    }()
    
    /// tableView - 整个容器
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: UITableViewStyle.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        return tableView
    }()
    
    /// webView - 显示正文的
    fileprivate lazy var webView: UIWebView = {
        let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        webView.dataDetectorTypes = UIDataDetectorTypes()
        webView.delegate = self
        webView.scrollView.isScrollEnabled = false
        return webView
    }()
    
    /// 活动指示器 - 页面正在加载时显示
    fileprivate lazy var activityView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityView.center = self.view.center
        return activityView
    }()
    
    /// 底部工具条
    fileprivate lazy var bottomBarView: JFNewsBottomBar = {
        let bottomBarView = Bundle.main.loadNibNamed("JFNewsBottomBar", owner: nil, options: nil)?.last as! JFNewsBottomBar
        bottomBarView.delegate = self
        return bottomBarView
    }()
    
    /// 顶部透明白条
    fileprivate lazy var topBarView: UIView = {
        let topBarView = UIView()
        topBarView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.8)
        return topBarView
    }()
    
    /// 尾部更多评论按钮
    fileprivate lazy var footerView: UIView = {
        let moreCommentButton = UIButton(frame: CGRect(x: 20, y: 20, width: SCREEN_WIDTH - 40, height: 44))
        moreCommentButton.addTarget(self, action: #selector(didTappedmoreCommentButton(_:)), for: UIControlEvents.touchUpInside)
        moreCommentButton.setTitle("更多评论", for: UIControlState())
        moreCommentButton.backgroundColor = NAVIGATIONBAR_RED_COLOR
        moreCommentButton.layer.cornerRadius = CORNER_RADIUS
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
        footerView.addSubview(moreCommentButton)
        return footerView
    }()
    
    /// 分享视图
    fileprivate lazy var shareView: JFShareView = {
        let shareView = JFShareView()
        shareView.delegate = self
        return shareView
    }()
}

// MARK: - tableView相关
extension JFNewsDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // 这样做是为了防止还没有数据的时候滑动崩溃哦
        return model == nil ? 0 : 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // 分享
            return 1
        case 1: // 广告
            return 1
        case 2: // 相关阅读
            return otherLinks.count
        case 3: // 评论、最多显示10条
            return commentList.count >= 10 ? 10 : commentList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: // 分享
            let cell = self.tableView.dequeueReusableCell(withIdentifier: self.detailStarAndShareIdentifier) as! JFStarAndShareCell
            cell.delegate = self
            cell.befromLabel.text = "文章来源: \(model!.befrom!)"
            cell.selectionStyle = .none
            return cell
        case 1: // 广告
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.contentView.addSubview(adImageView)
            return cell
        case 2: // 相关阅读
            
            let model = otherLinks[indexPath.row]
            
            if model.titlepic == nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: detailOtherLinkNoneIdentifier) as! JFDetailOtherNoneCell
                cell.model = model
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: detailOtherLinkIdentifier) as! JFDetailOtherCell
                cell.model = model
                return cell
            }
            
        case 3: // 评论
            let cell = tableView.dequeueReusableCell(withIdentifier: detailCommentIdentifier) as! JFCommentCell
            cell.delegate = self
            cell.commentModel = commentList[indexPath.row]
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // 组头
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // 相关阅读和最新评论才需要创建组头
        if section == 2 || section == 3 {
            
            // 竖线
            let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 3, height: 30))
            leftView.backgroundColor = NAVIGATIONBAR_RED_COLOR
            
            // 灰色背景
            let bgView = UIView(frame: CGRect(x: 3, y: 0, width: SCREEN_WIDTH - 3, height: 30))
            bgView.backgroundColor = UIColor(red:0.914,  green:0.890,  blue:0.847, alpha:0.3)
            
            // 组头名称
            let titleLabel = UILabel(frame: CGRect(x: 20, y: 0, width: 100, height: 30))
            
            // 组头容器 （因为组头默认是和cell一样宽，高度也是委托方法里返回，所以里面的子控件才需要布局）
            let headerView = UIView()
            headerView.addSubview(leftView)
            headerView.addSubview(bgView)
            headerView.addSubview(titleLabel)
            
            if section == 2 {
                titleLabel.text = "相关阅读"
                return otherLinks.count == 0 ? nil : headerView
            } else {
                titleLabel.text = "最新评论"
                return commentList.count == 0 ? nil : headerView
            }
            
        } else {
            return nil
        }
    }
    
    // 组尾
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 3 {
            // 如果有评论信息就添加更多评论按钮 超过10条才显示更多评论
            return commentList.count >= 10 ? footerView : nil // 如果有评论才显示更多评论按钮
        } else {
            return nil
        }
    }
    
    // cell高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: // 分享
            return 160
        case 1: // 广告
            return 160
        case 2: // 相关阅读
            var rowHeight = otherLinks[indexPath.row].rowHeight
            let model = otherLinks[indexPath.row]
            if model.titlepic == nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: detailOtherLinkNoneIdentifier) as! JFDetailOtherNoneCell
                // 缓存评论cell高度
                otherLinks[indexPath.row].rowHeight = cell.getRowHeight(model)
                rowHeight = otherLinks[indexPath.row].rowHeight
                return rowHeight
            } else {
                return 100
            }
        case 3: // 评论
            var rowHeight = commentList[indexPath.row].rowHeight
            if rowHeight < 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: detailCommentIdentifier) as! JFCommentCell
                // 缓存评论cell高度
                commentList[indexPath.row].rowHeight = cell.getCellHeight(commentList[indexPath.row])
                rowHeight = commentList[indexPath.row].rowHeight
            }
            return rowHeight
        default:
            return 0
        }
    }
    
    // 组头高度
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.1
        case 1:
            return 10
        case 2:
            return otherLinks.count == 0 ? 0.1 : 30
        case 3:
            return commentList.count == 0 ? 0.1 : 35
        default:
            return 0.1
        }
    }
    
    // 组尾高度
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.1
        case 1:
            return 20
        case 2:
            return otherLinks.count == 0 ? 0.1 : 15
        case 3:
            return commentList.count == 10 ? 100 : (commentList.count > 0 ? 20 : 0.1)
        default:
            return 0.1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 {
            let otherModel = otherLinks[indexPath.row]
            let detailVc = JFNewsDetailViewController()
            detailVc.articleParam = (otherModel.classid!, otherModel.id!)
            self.navigationController?.pushViewController(detailVc, animated: true)
        }
    }
}

// MARK: - 底部浮动工具条相关
extension JFNewsDetailViewController: JFNewsBottomBarDelegate, JFCommentCommitViewDelegate {
    
    // 开始拖拽视图
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        contentOffsetY = scrollView.contentOffset.y
    }
    
    // 松手后触发
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if (scrollView.contentOffset.y + SCREEN_HEIGHT) > scrollView.contentSize.height {
            if (scrollView.contentOffset.y + SCREEN_HEIGHT) - scrollView.contentSize.height >= 50 {
                
                UIGraphicsBeginImageContext(SCREEN_BOUNDS.size)
                UIApplication.shared.keyWindow?.layer.render(in: UIGraphicsGetCurrentContext()!)
                let tempImageView = UIImageView(image: UIGraphicsGetImageFromCurrentImageContext())
                UIApplication.shared.keyWindow?.addSubview(tempImageView)
                
                _ = navigationController?.popViewController(animated: false)
                UIView.animate(withDuration: 0.3, animations: {
                    tempImageView.alpha = 0
                    tempImageView.frame = CGRect(x: 0, y: SCREEN_HEIGHT * 0.5, width: SCREEN_WIDTH, height: 0)
                    }, completion: { (_) in
                        tempImageView.removeFromSuperview()
                })
                
            }
        }
    }
    
    /**
     手指滑动屏幕开始滚动
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (scrollView.isDragging) {
            if scrollView.contentOffset.y - contentOffsetY > 5.0 {
                // 向上拖拽 隐藏
                UIView.animate(withDuration: 0.25, animations: {
                    self.bottomBarView.transform = CGAffineTransform(translationX: 0, y: 44)
                })
            } else if contentOffsetY - scrollView.contentOffset.y > 5.0 {
                UIView.animate(withDuration: 0.25, animations: {
                    self.bottomBarView.transform = CGAffineTransform.identity
                })
            }
            
        }
        
        if (scrollView.contentOffset.y + SCREEN_HEIGHT) > scrollView.contentSize.height {
            if (scrollView.contentOffset.y + SCREEN_HEIGHT) - scrollView.contentSize.height >= 50 {
                closeDetailView.isSelected = true
            } else {
                closeDetailView.isSelected = false
            }
        }
    }
    
    /**
     滚动减速结束
     */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        // 滚动到底部后 显示
        if case let space = scrollView.contentOffset.y + SCREEN_HEIGHT - scrollView.contentSize.height, space > -5 && space < 5 {
            UIView.animate(withDuration: 0.25, animations: {
                self.bottomBarView.transform = CGAffineTransform.identity
            })
        }
    }
    
    /**
     底部返回按钮点击
     */
    func didTappedBackButton(_ button: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    /**
     底部编辑按钮点击
     */
    func didTappedEditButton(_ button: UIButton) {
        let commentCommitView = Bundle.main.loadNibNamed("JFCommentCommitView", owner: nil, options: nil)?.last as! JFCommentCommitView
        commentCommitView.delegate = self
        commentCommitView.show()
    }
    
    /**
     底部字体按钮点击 - 原来是评论
     */
    func didTappedCommentButton(_ button: UIButton) {
        let setFontSizeView = Bundle.main.loadNibNamed("JFSetFontView", owner: nil, options: nil)?.last as! JFSetFontView
        setFontSizeView.delegate = self
        setFontSizeView.show()
    }
    
    /**
     底部收藏按钮点击
     */
    func didTappedCollectButton(_ button: UIButton) {
        
        if JFAccountModel.isLogin() {
            let parameters: [String : Any] = [
                "username" : JFAccountModel.shareAccount()!.username!,
                "userid" : JFAccountModel.shareAccount()!.id,
                "token" : JFAccountModel.shareAccount()!.token!,
                "classid" : articleParam!.classid,
                "id" : articleParam!.id
            ]
            
            JFNetworkTool.shareNetworkTool.post(ADD_DEL_FAVA, parameters: parameters) { (status, result, tipString) in
                
                guard let successResult = result, status == .success else {return}
                
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
            present(JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil)), animated: true, completion: { })
        }
        
    }
    
    /**
     底部分享按钮点击
     */
    func didTappedShareButton(_ button: UIButton) {
        
        if JFShareItemModel.loadShareItems().count == 0 {
            JFProgressHUD.showInfoWithStatus("没有可分享内容")
            return
        }
        
        isShareArticle = true
        // 弹出分享视图
        shareView.showShareView()
        
    }
    
    /**
     点击了提交评论视图的发送按钮
     
     - parameter message: 评论信息
     */
    func didTappedSendButtonWithMessage(_ message: String) {
        
        var parameters = [String : Any]()
        
        // 如果已经登录就使用登录的用户信息发送评论
        if JFAccountModel.isLogin() {
            parameters = [
                "classid" : articleParam!.classid,
                "id" : articleParam!.id,
                "userid" : JFAccountModel.shareAccount()!.id,
                "nomember" : "0",
                "username" : JFAccountModel.shareAccount()!.username!,
                "token" : JFAccountModel.shareAccount()!.token!,
                "saytext" : message
            ]
        } else {
            parameters = [
                "classid" : articleParam!.classid,
                "id" : articleParam!.id,
                "nomember" : "1",
                "saytext" : message
            ]
        }
        
        print("parameters = \(parameters)")
        
        JFNetworkTool.shareNetworkTool.post(SUBMIT_COMMENT, parameters: parameters) { (status, result, tipString) in
            if status == .success {
                // 加载数据
                self.loadCommentList(Int(self.articleParam!.classid)!, id: Int(self.articleParam!.id)!)
            }
        }
    }
    
}

// MARK: - 修改字体相关
extension JFNewsDetailViewController: JFSetFontViewDelegate {
    
    /**
     自动布局webView
     */
    func autolayoutWebView() {
        
        let result = webView.stringByEvaluatingJavaScript(from: "getHtmlHeight();")
        
        if let height = result {
            webView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: CGFloat((height as NSString).floatValue) + 20)
            tableView.tableHeaderView = webView
            self.activityView.stopAnimating()
        }
    }
    
    /**
     修改了正文字体大小，需要重新显示 添加图片缓存后，目前还有问题
     */
    func didChangeFontSize(_ fontSize: Int) {
        
        webView.stringByEvaluatingJavaScript(from: "setFontSize(\"\(fontSize)\");")
        autolayoutWebView()
    }
    
    /**
     修改了正文字体
     
     - parameter fontNumber: 字体编号
     - parameter fontPath:   字体路径
     - parameter fontName:   字体名称
     */
    func didChangedFontName(_ fontName: String) {
        
        webView.stringByEvaluatingJavaScript(from: "setFontName(\"\(fontName)\");")
        autolayoutWebView()
    }
    
    /**
     修改了夜间/白日模式
     
     - parameter on: true则是夜间模式
     */
    func didChangedNightMode(_ on: Bool) {
        
        // 切换代码
        
    }
}

// MARK: - webView相关
extension JFNewsDetailViewController: UIWebViewDelegate {
    
    /**
     webView加载完成后更新webView高度并刷新tableView
     */
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        autolayoutWebView()
        if !webView.isLoading {
            if let allphoto = model?.allphoto {
                // 加载正文图片 - 从缓存中获取图片的本地绝对路径，发送给webView显示
                // 因为需要执行js代码，所以尽量在webView加载完成后调用
                getImageFromDownloaderOrDiskByImageUrlArray(allphoto)
            }
        }
    }
    
    /**
     过滤html，有需要过滤的直接写到这个方法
     
     - parameter string: 过滤前的html
     
     - returns: 过滤后的html
     */
    func filterHTML(_ string: String) -> String {
        var tempHtml = (string as NSString).replacingOccurrences(of: "<p>&nbsp;</p>", with: "")
        tempHtml = (tempHtml as NSString).replacingOccurrences(of: " style=\"text-indent: 2em;\"", with: "")
        return tempHtml
    }
    
    /**
     加载webView内容
     
     - parameter model: 新闻模型
     */
    func loadWebViewContent(_ model: JFArticleDetailModel) {
        
        // 如果不熟悉网页，可以换成GRMutache模板更配哦
        var html = ""
        html += "<div class=\"title\">\(model.title!)</div>"
        html += "<div class=\"time\">\(model.befrom!)&nbsp;&nbsp;&nbsp;&nbsp;\(model.newstime!.timeStampToString())</div>"
        
        // 临时正文 - 这样做的目的是不修改模型
        var tempNewstext = model.newstext!
        
        // 有图片才去拼接图片
        if model.allphoto!.count > 0 {
            
            // 拼接图片标签
            for (index, insetPhoto) in model.allphoto!.enumerated() {
                // 图片占位符范围
                let range = (tempNewstext as NSString).range(of: insetPhoto.ref!)
                
                // 默认宽、高为0
                var width = insetPhoto.widthPixel
                var height = insetPhoto.heightPixel
                
                // 如果图片超过了最大宽度，才等比压缩 这个最大宽度是根据css里的container容器宽度来自适应的
                if width >= SCREEN_WIDTH - 40 {
                    let rate = (SCREEN_WIDTH - 40) / width
                    width = width * rate
                    height = height * rate
                }
                
                // 加载中的占位图
                let loading = Bundle.main.path(forResource: "www/images/loading.jpg", ofType: nil)!
                
                // 图片URL
                let imgUrl = insetPhoto.url!
                print("imgUrl = \(imgUrl)")
                
                // img标签
                let imgTag = "<img onclick='didTappedImage(\(index), \"\(imgUrl)\");' src='\(loading)' id='\(imgUrl)' width='\(width)' height='\(height)' />"
                tempNewstext = (tempNewstext as NSString).replacingOccurrences(of: insetPhoto.ref!, with: imgTag, options: NSString.CompareOptions.caseInsensitive, range: range)
            }
            
        }
        
        tempNewstext = (tempNewstext as NSString).replacingOccurrences(of: " style=\"text-indent: 2em;\"", with: "")
        
        let fontSize = UserDefaults.standard.integer(forKey: CONTENT_FONT_SIZE_KEY)
        let fontName = UserDefaults.standard.string(forKey: CONTENT_FONT_TYPE_KEY)!
        
        html += "<div id=\"content\" style=\"font-size: \(fontSize)px; font-family: '\(fontName)';\">\(tempNewstext)</div>"
        
        // 从本地加载网页模板，替换新闻主页
        let templatePath = Bundle.main.path(forResource: "www/html/article.html", ofType: nil)!
        let template = (try! String(contentsOfFile: templatePath, encoding: String.Encoding.utf8)) as NSString
        html = template.replacingOccurrences(of: "<p>mainnews</p>", with: html, options: NSString.CompareOptions.caseInsensitive, range: template.range(of: "<p>mainnews</p>"))
        let baseURL = URL(fileURLWithPath: templatePath)
        webView.loadHTMLString(filterHTML(html), baseURL: baseURL)
        
        // 已经加载过就修改标记
        isLoaded = true
    }
    
    /**
     下载或从缓存中获取图片，发送给webView
     */
    func getImageFromDownloaderOrDiskByImageUrlArray(_ imageArray: [JFInsetPhotoModel]) {
        
        // 循环加载图片
        for insetPhoto in imageArray {
            
            // 图片url
            let imageString = insetPhoto.url!
            
            // 判断本地磁盘是否已经缓存
            if JFArticleStorage.getArticleImageCache().containsImage(forKey: imageString, with: YYImageCacheType.disk) {
                
                let imagePath = JFArticleStorage.getFilePathForKey(imageString)
                // 发送图片占位标识和本地绝对路径给webView
                bridge?.send("replaceimage\(imageString)~\(imagePath)")
                print("图片已有缓存，发送给js \(imagePath)")
            } else {
                YYWebImageManager(cache: JFArticleStorage.getArticleImageCache(), queue: OperationQueue()).requestImage(with: URL(string: imageString)!, options: YYWebImageOptions.useNSURLCache, progress: { (_, _) in
                    }, transform: { (image, url) -> UIImage? in
                        return image
                    }, completion: { (image, url, type, stage, error) in
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.15 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                            // 确保已经下载完成并没有出错
                            // 这样做其实已经修改了YYWebImage的磁盘缓存策略。默认YYWebImage缓存文件时超过20kb的文件才会存储为文件，所以需要在 YYDiskCache.m的171行修改
                            guard let _ = image, error == nil else {return}
                            let imagePath = JFArticleStorage.getFilePathForKey(imageString)
                            // 发送图片占位标识和本地绝对路径给webView
                            self.bridge?.send("replaceimage\(imageString)~\(imagePath)")
                            print("图片缓存完成，发送给js \(imagePath)")
                        }
                        
                })
            }
            
        }
        
    }
    
}

// MARK: - 分享相关 - 这是正文中心的三个按钮和底部分享视图的分享事件
extension JFNewsDetailViewController: JFStarAndShareCellDelegate, JFShareViewDelegate {
    
    /**
     获取文章分享参数
     
     - returns: 获取文章分享参数
     */
    func getShareParameters() -> NSMutableDictionary? {
        
        guard let currentModel = model, let picUrl = model?.titlepic, var titleurl = model?.titleurl else {return nil}
        
        let shareParames = NSMutableDictionary()
        if isShareArticle {
            var image = YYImageCache.shared().getImageForKey(picUrl)
            if image != nil && (image!.size.width > 300.0 || image!.size.height > 300.0) {
                image = image?.resizeImageWithNewSize(CGSize(width: 300, height: 300 * image!.size.height / image!.size.width))
            }
            
            // 判断标题url是否带baseurl
            titleurl = currentModel.titleurl!.hasPrefix("http") ? titleurl : "\(BASE_URL)\(titleurl)"
            
            shareParames.ssdkSetupShareParams(byText: currentModel.smalltext,
                                              images : image,
                                              url : URL(string: titleurl),
                                              title : currentModel.title,
                                              type : SSDKContentType.auto)
        } else {
            var image = UIImage(named: "launchScreen")!
            if image.size.width > 300 || image.size.height > 300 {
                image = image.resizeImageWithNewSize(CGSize(width: 300, height: 300 * image.size.height / image.size.width))
            }
            
            shareParames.ssdkSetupShareParams(byText: "爆侃网文精心打造网络文学互动平台，专注最新文学市场动态，聚焦第一手网文圈资讯！",
                                              images : image,
                                              url : URL(string:"http://www.baokan.tv/wapapp/index.html"),
                                              title : "爆侃网文让您的网文之路不再孤单！",
                                              type : SSDKContentType.auto)
        }
        
        return shareParames
    }
    
    /**
     根据类型分享
     */
    fileprivate func shareWithType(_ platformType: SSDKPlatformType) {
        
        guard let shareParames = getShareParameters() else {
            return
        }
        
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
    
    /**
     点击QQ分享
     */
    func didTappedQQButton(_ button: UIButton) {
        isShareArticle = true
        shareWithType(SSDKPlatformType.subTypeQQFriend)
    }
    
    /**
     点击了微信分享
     */
    func didTappedWeixinButton(_ button: UIButton) {
        isShareArticle = true
        shareWithType(SSDKPlatformType.subTypeWechatSession)
    }
    
    /**
     点击了朋友圈分享
     */
    func didTappedFriendCircleButton(_ button: UIButton) {
        isShareArticle = true
        shareWithType(SSDKPlatformType.subTypeWechatTimeline)
    }
    
    /// 底部弹出的分享视图的分享按钮点击事件
    ///
    /// - Parameter type: 需要分享的类型
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
        
        // 立即分享
        shareWithType(platformType)
        
    }
    
}

// MARK: - 评论相关
extension JFNewsDetailViewController: JFCommentCellDelegate {
    
    /**
     加载评论信息 - 只加载最新的10条
     */
    func loadCommentList(_ classid: Int, id: Int) {
        
        JFCommentModel.loadCommentList(classid, id: id, pageIndex: 1, pageSize: 10) { (commentModels, error) in
            
            guard let models = commentModels, error == nil else {return}
            
            self.commentList = models
            self.tableView.reloadData()
        }
    }
    
    /**
     点击了评论cell上的赞按钮
     */
    func didTappedStarButton(_ button: UIButton, commentModel: JFCommentModel) {
        
        let parameters = [
            "classid" : commentModel.classid,
            "id" : commentModel.id,
            "plid" : commentModel.plid,
            "dopl" : "1",
            "action" : "DoForPl"
        ] as [String : Any]
        
        JFNetworkTool.shareNetworkTool.get(TOP_DOWN, parameters: parameters) { (status, result, tipString) in
            
            if status == .success {
                JFProgressHUD.showInfoWithStatus("谢谢支持")
                // 只要顶成功才选中
                button.isSelected = true
                
                commentModel.zcnum += 1
                commentModel.isStar = true
                
                // 刷新单行
                let indexPath = IndexPath(row: self.commentList.index(of: commentModel)!, section: 3)
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            } else {
                JFProgressHUD.showInfoWithStatus("不能重复顶哦")
            }
            
            jf_setupButtonSpringAnimation(button)
        }
    }
    
    /**
     点击更多评论按钮
     */
    func didTappedmoreCommentButton(_ button: UIButton) -> Void {
        let commentVc = JFCommentTableViewController(style: UITableViewStyle.plain)
        commentVc.param = articleParam
        navigationController?.pushViewController(commentVc, animated: true)
    }
}

// MARK: - 正文图片浏览器转场动画
extension JFNewsDetailViewController: UIViewControllerTransitioningDelegate {
    
    /**
     返回一个控制modal视图大小的对象
     */
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return JFNewsPhotoPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    /**
     返回一个控制器modal动画效果的对象
     */
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return JFNewsPhotoModalAnimation()
    }
    
    /**
     返回一个控制dismiss动画效果的对象
     */
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return JFNewsPhotoDismissAnimation()
    }
    
}


