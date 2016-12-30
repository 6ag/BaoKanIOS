//
//  JFShareView.swift
//  WindSpeedVPN
//
//  Created by zhoujianfeng on 2016/11/29.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit

protocol JFShareViewDelegate: NSObjectProtocol {
    func share(type: JFShareType)
}

class JFShareView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: SCREEN_BOUNDS)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate: JFShareViewDelegate?
    
    /// 分享items
    var shareItems = JFShareItemModel.loadShareItems()
    
    let SHARE_ITEM_IDENTIFIER = "SHARE_ITEM_IDENTIFIER"
    
    /// 取消
    @objc private func didTapped(cancelButton: UIButton) {
        dismissShareView()
    }
    
    /// 准备UI
    private func prepareUI() {
        
        backgroundColor = UIColor(white: 0, alpha: 0.0)
        addSubview(tapBgView)
        addSubview(containerView)
        containerView.addSubview(lineView)
        containerView.addSubview(collectionView)
        containerView.addSubview(cancelButton)
        
        tapBgView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        containerView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(layoutVertical(iPhone6: 226)) // 高226 但只会漏出206高度
            make.height.equalTo(layoutVertical(iPhone6: 226))
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.height.equalTo(0.5)
            make.bottom.equalTo(layoutVertical(iPhone6: -64))
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.bottom.equalTo(lineView.snp.top)
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.height.equalTo(layoutVertical(iPhone6: 44))
            make.top.equalTo(lineView.snp.bottom)
        }
        
        // 更新布局
        layoutIfNeeded()
        
    }
    
    /// 显示分享视图
    func showShareView() {
        
        UIApplication.shared.keyWindow?.addSubview(self)
        
        containerView.snp.updateConstraints { (make) in
            make.bottom.equalTo(layoutVertical(iPhone6: 20))
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.layoutIfNeeded()
            self.backgroundColor = UIColor(white: 0, alpha: 0.5)
        }) { (_) in
            
        }
        
    }
    
    /// 隐藏分享视图
    func dismissShareView() {
        containerView.snp.updateConstraints { (make) in
            make.bottom.equalTo(layoutVertical(iPhone6: 226))
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.layoutIfNeeded()
            self.backgroundColor = UIColor(white: 0, alpha: 0.0)
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    // MARK: - 懒加载
    /// tag视图，最底层的用来dismiss的
    private lazy var tapBgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.01)
        let tag = UITapGestureRecognizer(target: self, action: #selector(dismissShareView))
        view.addGestureRecognizer(tag)
        return view
    }()
    
    /// 背景视图
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.colorWithHexString("FFFFFF")
        view.layer.cornerRadius = layoutVertical(iPhone6: 20)
        view.layer.masksToBounds = true
        return view
    }()
    
    /// 分割线
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.colorWithHexString("CECECE", alpha: 0.72)
        return view
    }()
    
    /// 分享按钮们
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: SCREEN_WIDTH / 4.0, height: layoutVertical(iPhone6: 160))
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(JFShareItemCell.classForCoder(), forCellWithReuseIdentifier: self.SHARE_ITEM_IDENTIFIER)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    /// 取消
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor.colorWithHexString("0D0D0D"), for: .normal)
        button.setTitle("取消", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: layoutFont(iPhone6: 17))
        button.addTarget(self, action: #selector(didTapped(cancelButton:)), for: .touchUpInside)
        return button
    }()
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension JFShareView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shareItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SHARE_ITEM_IDENTIFIER, for: indexPath) as! JFShareItemCell
        cell.shareItem = shareItems[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let shareItem = shareItems[indexPath.item]
        delegate?.share(type: shareItem.type)
        dismissShareView()
        
    }
}
