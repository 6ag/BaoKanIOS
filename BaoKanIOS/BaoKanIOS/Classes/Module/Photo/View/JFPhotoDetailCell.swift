//
//  JFPhotoDetailCell.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/4/8.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

class JFPhotoDetailCell: UICollectionViewCell {
    
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
                self.layoutImageView(image)
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
        
        // 添加控件
        scrollView.addSubview(picImageView)
        contentView.addSubview(scrollView)
        contentView.addSubview(indicator)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        // 背景scrollView
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[sv]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["sv" : scrollView]))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[sv]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["sv" : scrollView]))
        
        // 进度指示器
        contentView.addConstraint(NSLayoutConstraint(item: indicator, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: indicator, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
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
}
