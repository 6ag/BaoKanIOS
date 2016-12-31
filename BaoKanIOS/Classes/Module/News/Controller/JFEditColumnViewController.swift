//
//  JFEditColumnViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/31.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFEditColumnViewController: UIViewController, JFEditColumnViewCellDelegate {
    
    // 栏目数组
    var selectedArray: [[String : String]]?
    var optionalArray: [[String : String]]?
    
    let cellIdentifier = "CoclumnCollectionViewCell"
    let headOne = "ColumnReusableViewOne"
    let headTwo = "ColumnReusableViewTwo"
    
    // 间隔
    let SPACE: CGFloat = 10
    
    var cellAttributesArray = [UICollectionViewLayoutAttributes]()
    
    var isSort = false
    var lastIsHidden = false

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = NAVIGATIONBAR_RED_COLOR
    }
    
    fileprivate func prepareUI() {
        
        view.addSubview(collectionView)
        collectionView.register(JFEditColumnViewCell.classForCoder(), forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(JFColumnReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headOne)
        collectionView.register(JFColumnReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headTwo)
        collectionView.reloadData()
    }

    // MARK: - 各种排序处理方法
    func sortItem(_ pan: UIPanGestureRecognizer) -> Void {
        let cell = pan.view as! JFEditColumnViewCell
        let cellIndexPath = collectionView.indexPath(for: cell)!
        
        // 开始 获取所以cell的attributes
        if pan.state == UIGestureRecognizerState.began {
            cellAttributesArray.removeAll()
            
            for (index, _) in selectedArray!.enumerated() {
                cellAttributesArray.append(collectionView.layoutAttributesForItem(at: IndexPath(item: index, section: 0))!)
            }
        }
        
        let point = pan.translation(in: collectionView)
        cell.center = CGPoint(x: cell.center.x + point.x, y: cell.center.y + point.y)
        pan.setTranslation(CGPoint(x: 0, y: 0), in: collectionView)
        
        // 是否进行排序操作
        var isChange = false
        
        for attributes in cellAttributesArray {
            
            let rect = CGRect(x: attributes.center.x - 6, y: attributes.center.y - 6, width: 12, height: 12)
            
            if rect.contains(CGPoint(x: pan.view!.center.x, y: pan.view!.center.y)) && cellIndexPath != attributes.indexPath {
                if cellIndexPath.row > attributes.indexPath.row {
                    //后面跟前面交换
                    //交替操作0 1 2 3 变成（3<->2 3<->1 3<->0）
                    for index in ((attributes.indexPath.row + 1)...cellIndexPath.row).reversed() {
                        let temp = selectedArray![index]
                        selectedArray![index] = selectedArray![index - 1]
                        selectedArray![index - 1] = temp
                    }
                } else {
                    //前面跟后面交换
                    //交替操作0 1 2 3 变成（0<->1 0<->2 0<->3）
                    for index in cellIndexPath.row ..< attributes.indexPath.row {
                        let temp = selectedArray![index]
                        selectedArray![index] = selectedArray![index + 1]
                        selectedArray![index + 1] = temp
                    }
                }
                
                isChange = true
                collectionView.moveItem(at: cellIndexPath, to: attributes.indexPath)
            } else {
                isChange = false
            }
            
        }
        
        if pan.state == UIGestureRecognizerState.ended {
            if !isChange {
                cell.center = collectionView.layoutAttributesForItem(at: cellIndexPath)!.center
            }
        }

        
    }
    
    func deleteItemWithIndexPath(_ indexPath: IndexPath) -> Void {
        optionalArray?.insert(selectedArray![indexPath.row], at: 0)
        selectedArray?.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        
        // 删除之后更新collectionView上对应的indexPath
        for index in 0 ..< selectedArray!.count {
            let newIndexPath = IndexPath(item: index, section: 0)
            let cell = collectionView.cellForItem(at: newIndexPath) as! JFEditColumnViewCell
            cell.indexPath = newIndexPath
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            // 点击已经选择的，就进行跳转
            dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "columnViewWillDismiss"), object: nil, userInfo: ["index" : indexPath.item])
        } else if indexPath.section == 1 {
            lastIsHidden = true
            
            let endCell = collectionView.cellForItem(at: indexPath) as! JFEditColumnViewCell
            endCell.contentLabel.isHidden = true
            
            selectedArray?.append(optionalArray![indexPath.row])
            collectionView.reloadSections(IndexSet(integer: 0))
            
            let startAttributes = collectionView.layoutAttributesForItem(at: indexPath)
            
            animationLabel.frame = CGRect(x: startAttributes!.frame.origin.x, y: startAttributes!.frame.origin.y, width: startAttributes!.frame.size.width, height: startAttributes!.frame.size.height)
            animationLabel.layer.cornerRadius = animationLabel.bounds.height * 0.5
            animationLabel.text = optionalArray![indexPath.row]["classname"]
            collectionView.addSubview(animationLabel)
            let toIndexPath = IndexPath(item: selectedArray!.count-1, section: 0)
            
            let endAttributes = collectionView.layoutAttributesForItem(at: toIndexPath)
            
            UIView.animate(withDuration: 0.7, animations: { 
                self.animationLabel.center = endAttributes!.center
                }, completion: { (_) in
                    let endCell = collectionView.cellForItem(at: toIndexPath) as! JFEditColumnViewCell
                    endCell.contentLabel.isHidden = false
                    self.lastIsHidden = false
                    self.animationLabel.removeFromSuperview()
                    self.optionalArray?.remove(at: indexPath.row)
                    self.collectionView.deleteItems(at: [indexPath])
            })
            
        }
        
    }
    
    
    // MARK: - 懒加载
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    fileprivate lazy var animationLabel: UILabel = {
        let animationLabel = UILabel()
        animationLabel.textAlignment = NSTextAlignment.center
        animationLabel.font = UIFont.systemFont(ofSize: 15)
        animationLabel.numberOfLines = 1;
        animationLabel.adjustsFontSizeToFitWidth = true
        animationLabel.minimumScaleFactor = 0.1
        animationLabel.textColor = UIColor.colorWithRGB(101, g: 101, b: 101)
        animationLabel.layer.masksToBounds = true
        animationLabel.layer.borderColor = UIColor.colorWithRGB(211, g: 211, b: 211).cgColor
        animationLabel.layer.borderWidth = 0.45
        return animationLabel
    }()
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension JFEditColumnViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (SCREEN_WIDTH - (5 * SPACE)) / 4.0, height: 30)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: SPACE, left: SPACE, bottom: SPACE, right: SPACE)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return SPACE
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return SPACE
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: SCREEN_WIDTH, height: 40.0)
        } else {
            return CGSize(width: SCREEN_WIDTH, height: 30.0)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: SCREEN_WIDTH, height: 0.0)
    }
    
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isSort {
            return 1
        } else {
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return selectedArray?.count ?? 0
        } else {
            return optionalArray?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView: JFColumnReusableView?
        
        if kind == UICollectionElementKindSectionHeader {
            if indexPath.section == 0 {
                reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headOne, for: indexPath) as? JFColumnReusableView
                reusableView?.buttonHidden = false
                reusableView?.clickButton.isSelected = isSort
                reusableView?.backgroundColor = UIColor.white
                
                reusableView?.clickWithBlock({ (state) in
                    //排序删除
                    if (state == ButtonState.stateSortDelete) {
                        self.isSort = true
                    } else {
                        // 完成
                        self.isSort = false
                        if self.cellAttributesArray.count > 0 {
                            
                            for attributes in self.cellAttributesArray {
                                let cell = collectionView.cellForItem(at: attributes.indexPath)
                                if let gestures  = cell?.gestureRecognizers {
                                    for pan in gestures {
                                        cell?.removeGestureRecognizer(pan)
                                    }
                                }
                                
                            }
                        }
                    }
                    self.collectionView.reloadData()
                })
                
                reusableView?.titleLabel.text = "已选栏目"
            } else {
                reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headTwo, for: indexPath) as? JFColumnReusableView
                reusableView?.buttonHidden = true
                reusableView?.backgroundColor = UIColor.colorWithRGB(240, g: 240, b: 240)
                reusableView?.titleLabel.text = "点击添加更多栏目"
            }
        }
        return reusableView!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! JFEditColumnViewCell
        
        if indexPath.section == 0 {
            cell.configCell(selectedArray!, withIndexPath: indexPath)
            
            if indexPath.row == 0 {
                cell.deleteButton.isHidden = true
            } else {
                cell.delegate = self
                cell.deleteButton.isHidden = !isSort
                if isSort {
                    let pan = UIPanGestureRecognizer(target: self, action: #selector(sortItem(_:)))
                    cell.addGestureRecognizer(pan)
                }
                
                //最后一位是否影藏(为了动画效果)
                if indexPath.row == selectedArray!.count - 1 {
                    cell.contentLabel.isHidden = lastIsHidden
                }
            }
            
        } else {
            cell.configCell(optionalArray!, withIndexPath: indexPath)
            cell.deleteButton.isHidden = true
        }
        
        return cell
    }
}
