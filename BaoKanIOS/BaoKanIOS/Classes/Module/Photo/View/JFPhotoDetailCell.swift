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
    
    func didOneTappedPhotoDetailView(scrollView: UIScrollView) -> Void
    func didDoubleTappedPhotoDetailView(scrollView: UIScrollView, touchPoint: CGPoint) -> Void
}

class JFPhotoDetailCell: UICollectionViewCell {
    
    var delegate: JFPhotoDetailCellDelegate?
    
    var model: JFPhotoDetailModel? {
        didSet {
            guard let imageURL = model?.picurl else {
                print("imageURL 为空")
                return
            }
            
            // 将imageView图片设置为nil,防止cell重用
            picImageView.image = nil
            resetProperties()
            
            // 显示下载指示器
            indicator.startAnimating()
            
            picImageView.yy_setImageWithURL(NSURL(string: model!.picurl!), placeholder: nil, options: YYWebImageOptions.ShowNetworkActivity) { (image, url, type, stage, error) in
                self.indicator.stopAnimating()
                
                if error != nil {
                    print("下载大图片出错:error: \(error), url:\(imageURL)")
                    return
                }
                
                // 设置图片的大小
                if let img = image {
                    self.layoutImageView(img)
                }
                
            }
            
        }
    }
    
    /**
     清除属性,防止cell复用
     */
    private func resetProperties() {
        picImageView.transform = CGAffineTransformIdentity
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointZero
        scrollView.contentSize = CGSizeZero
    }
    
    /**
     根据长短图,重新布局图片位置
     */
    private func layoutImageView(image: UIImage) {
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
    
    private func prepareUI() {
        
        // 添加单击双击事件
        let oneTap = UITapGestureRecognizer(target: self, action: #selector(didOneTappedPhotoDetailView(_:)))
        addGestureRecognizer(oneTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTappedPhotoDetailView(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        // 如果监听到双击事件，单击事件则不触发
        oneTap.requireGestureRecognizerToFail(doubleTap)
        
        // 添加控件
        scrollView.addSubview(picImageView)
        contentView.addSubview(scrollView)
        contentView.addSubview(indicator)
        
        scrollView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        indicator.snp_makeConstraints { (make) in
            make.center.equalTo(self)
        }
    }
    
    // MARK: - 懒加载
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.maximumZoomScale = 2
        scrollView.minimumZoomScale = 1
        scrollView.delegate = self
        return scrollView
    }()
    private lazy var indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    private lazy var picImageView = UIImageView()
}

// MARK: - UIScrollViewDelegate
extension JFPhotoDetailCell: UIScrollViewDelegate {
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return picImageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
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
        
        UIView.animateWithDuration(0.25) { () -> Void in
            // 设置scrollView的contentInset来居中图片
            scrollView.contentInset = UIEdgeInsets(top: offestY, left: offestX, bottom: offestY, right: offestX)
        }
    }
    
    /**
     图秀详情界面单击事件，隐藏除去图片外的所有UI
     */
    func didOneTappedPhotoDetailView(tap: UITapGestureRecognizer) -> Void {
        delegate?.didOneTappedPhotoDetailView(scrollView)
    }
    
    /**
     图秀详情界面双击事件，缩放
     */
    func didDoubleTappedPhotoDetailView(tap: UITapGestureRecognizer) -> Void {
        let touchPoint = tap.locationInView(self)
        delegate?.didDoubleTappedPhotoDetailView(scrollView, touchPoint: touchPoint)
    }
    
}
