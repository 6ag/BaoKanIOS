//
//  JFPhotoDetailCell.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/4/8.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage
import SnapKit

protocol JFPhotoDetailCellDelegate {
    func didOneTappedPhotoDetailView(_ scrollView: UIScrollView)
    func didDoubleTappedPhotoDetailView(_ scrollView: UIScrollView, touchPoint: CGPoint)
    func didLongPressPhotoDetailView(_ scrollView: UIScrollView, currentImage: UIImage?)
}

class JFPhotoDetailCell: UICollectionViewCell {
    
    var delegate: JFPhotoDetailCellDelegate?
    
    /// 图片URL字符串
    var urlString: String? {
        didSet {
            guard let imageURL = urlString else {
                print("imageURL 为空")
                return
            }
            
            // 将imageView图片设置为nil,防止cell重用
            picImageView.image = nil
            resetProperties()
            indicator.startAnimating()
            
            // 判断本地磁盘是否已经缓存
            if JFArticleStorage.getArticleImageCache().containsImage(forKey: imageURL, with: YYImageCacheType.disk) {
                
                let image = UIImage(contentsOfFile: JFArticleStorage.getFilePathForKey(imageURL))!
                self.picImageView.yy_imageURL = URL(string: imageURL)
                self.layoutImageView(image)
                self.indicator.stopAnimating()
                
            } else {
                
                YYWebImageManager(cache: JFArticleStorage.getArticleImageCache(), queue: OperationQueue()).requestImage(with: URL(string: imageURL)!, options: YYWebImageOptions.useNSURLCache, progress: { (_, _) in
                    }, transform: { (image, url) -> UIImage? in
                        return image
                    }, completion: { (image, url, type, stage, error) in
                        DispatchQueue.main.sync(execute: {
                            self.indicator.stopAnimating()
                            
                            guard let _ = image, error == nil else {return}
                            
                            // 刚缓存的图片会有一点处理时间保存到本地
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                                let image = UIImage(contentsOfFile: JFArticleStorage.getFilePathForKey(imageURL))!
                                self.layoutImageView(image)
                                self.picImageView.yy_imageURL = URL(string: imageURL)
                            }
                            
                        })
                })
            }
        }
    }
    
    /**
     清除属性,防止cell复用
     */
    fileprivate func resetProperties() {
        picImageView.transform = CGAffineTransform.identity
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.contentOffset = CGPoint.zero
        scrollView.contentSize = CGSize.zero
    }
    
    /**
     根据长短图,重新布局图片位置
     */
    fileprivate func layoutImageView(_ image: UIImage) {
        // 获取等比例缩放后的图片大小
        let size = image.displaySize()
        
        // 判断长短图
        if size.height < (SCREEN_HEIGHT) {
            // 短图, 居中显示
            let offestY = (SCREEN_HEIGHT - size.height) * 0.5
            
            // 不能通过frame来确定Y值,否则在放大的时候底部可会有看不到
            picImageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            // 设置scrollView.contentInset.top是可以滚动的
            scrollView.contentInset = UIEdgeInsets(top: offestY, left: 0, bottom: offestY, right: 0)
        } else {
            // 长图, 顶部显示
            picImageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
            
            // 设置滚动
            scrollView.contentSize = size
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        
        // 添加单击双击事件
        let oneTap = UITapGestureRecognizer(target: self, action: #selector(didOneTappedPhotoDetailView(_:)))
        addGestureRecognizer(oneTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTappedPhotoDetailView(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressPhotoDetailView(_:)))
        addGestureRecognizer(longPress)
        
        // 如果监听到双击事件，单击事件则不触发
        oneTap.require(toFail: doubleTap)
        
        // 添加控件
        scrollView.addSubview(picImageView)
        contentView.addSubview(scrollView)
        contentView.addSubview(indicator)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        indicator.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }
    }
    
    // MARK: - 各种手势
    /**
     图秀详情界面单击事件，隐藏除去图片外的所有UI
     */
    func didOneTappedPhotoDetailView(_ tap: UITapGestureRecognizer) {
        delegate?.didOneTappedPhotoDetailView(scrollView)
    }
    
    /**
     图秀详情界面双击事件，缩放
     */
    func didDoubleTappedPhotoDetailView(_ tap: UITapGestureRecognizer) {
        let touchPoint = tap.location(in: self)
        delegate?.didDoubleTappedPhotoDetailView(scrollView, touchPoint: touchPoint)
    }
    
    /**
     图秀详情长按事件
     */
    func didLongPressPhotoDetailView(_ longPress: UILongPressGestureRecognizer) {
        if longPress.state == .began {
            // 长按手势会触发2次 所以，你懂得
            delegate?.didLongPressPhotoDetailView(scrollView, currentImage: picImageView.image)
        }
    }
    
    // MARK: - 懒加载
    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.maximumZoomScale = 2
        scrollView.minimumZoomScale = 1
        scrollView.delegate = self
        return scrollView
    }()
    fileprivate lazy var indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    fileprivate lazy var picImageView = UIImageView()
}

// MARK: - UIScrollViewDelegate
extension JFPhotoDetailCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return picImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // 往中间移动
        // Y偏移
        var offestY = (scrollView.bounds.height - picImageView.frame.height) * 0.5
        
        // X偏移
        var offestX = (scrollView.bounds.width - picImageView.frame.width) * 0.5
        
        // 当 offest 时,让 offest = 0,否则会托不动
        if offestY < 0 {
            offestY = 0
        }
        
        if offestX < 0 {
            offestX = 0
        }
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            // 设置scrollView的contentInset来居中图片
            scrollView.contentInset = UIEdgeInsets(top: offestY, left: offestX, bottom: offestY, right: offestX)
        }) 
    }
    
}
