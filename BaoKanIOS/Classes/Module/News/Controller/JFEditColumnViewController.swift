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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = NAVIGATIONBAR_RED_COLOR
    }
    
    private func prepareUI() {
        
        view.addSubview(collectionView)
        collectionView.registerClass(JFEditColumnViewCell.classForCoder(), forCellWithReuseIdentifier: cellIdentifier)
        collectionView.registerClass(JFColumnReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headOne)
        collectionView.registerClass(JFColumnReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headTwo)
        collectionView.reloadData()
    }

    // MARK: - 各种排序处理方法
    func sortItem(pan: UIPanGestureRecognizer) -> Void {
        let cell = pan.view as! JFEditColumnViewCell
        let cellIndexPath = collectionView.indexPathForCell(cell)
        
        // 开始 获取所以cell的attributes
        if pan.state == UIGestureRecognizerState.Began {
            cellAttributesArray.removeAll()
            
            for (index, _) in selectedArray!.enumerate() {
                cellAttributesArray.append(collectionView.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0))!)
            }
        }
        
        let point = pan.translationInView(collectionView)
        cell.center = CGPoint(x: cell.center.x + point.x, y: cell.center.y + point.y)
        pan.setTranslation(CGPoint(x: 0, y: 0), inView: collectionView)
        
        // 是否进行排序操作
        var isChange = false
        
        for attributes in cellAttributesArray {
            
            let rect = CGRect(x: attributes.center.x - 6, y: attributes.center.y - 6, width: 12, height: 12)
            
            if CGRectContainsPoint(rect, CGPoint(x: pan.view!.center.x, y: pan.view!.center.y)) && cellIndexPath != attributes.indexPath {
                if cellIndexPath?.row > attributes.indexPath.row {
                    //后面跟前面交换
                    //交替操作0 1 2 3 变成（3<->2 3<->1 3<->0）
                    for var index = cellIndexPath!.row; index > attributes.indexPath.row; index -= 1 {
                        let temp = selectedArray![index]
                        selectedArray![index] = selectedArray![index - 1]
                        selectedArray![index - 1] = temp
                    }
                } else {
                    //前面跟后面交换
                    //交替操作0 1 2 3 变成（0<->1 0<->2 0<->3）
                    for index in cellIndexPath!.row ..< attributes.indexPath.row {
                        let temp = selectedArray![index]
                        selectedArray![index] = selectedArray![index + 1]
                        selectedArray![index + 1] = temp
                    }
                }
                
                isChange = true
                collectionView.moveItemAtIndexPath(cellIndexPath!, toIndexPath: attributes.indexPath)
            } else {
                isChange = false
            }
            
        }
        
        if pan.state == UIGestureRecognizerState.Ended {
            if !isChange {
                cell.center = collectionView.layoutAttributesForItemAtIndexPath(cellIndexPath!)!.center
            }
        }
        
        
    }
    
    func deleteItemWithIndexPath(indexPath: NSIndexPath) -> Void {
        optionalArray?.insert(selectedArray![indexPath.row], atIndex: 0)
        selectedArray?.removeAtIndex(indexPath.row)
        collectionView.deleteItemsAtIndexPaths([indexPath])
        
        // 删除之后更新collectionView上对应的indexPath
        for index in 0 ..< selectedArray!.count {
            let newIndexPath = NSIndexPath(forItem: index, inSection: 0)
            let cell = collectionView.cellForItemAtIndexPath(newIndexPath) as! JFEditColumnViewCell
            cell.indexPath = newIndexPath
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            // 点击已经选择的，就进行跳转
            dismissViewControllerAnimated(true, completion: nil)
            NSNotificationCenter.defaultCenter().postNotificationName("columnViewWillDismiss", object: nil, userInfo: ["index" : indexPath.item])
        } else if indexPath.section == 1 {
            lastIsHidden = true
            
            let endCell = collectionView.cellForItemAtIndexPath(indexPath) as! JFEditColumnViewCell
            endCell.contentLabel.hidden = true
            
            selectedArray?.append(optionalArray![indexPath.row])
            collectionView.reloadSections(NSIndexSet(index: 0))
            
            let startAttributes = collectionView.layoutAttributesForItemAtIndexPath(indexPath)
            
            animationLabel.frame = CGRect(x: startAttributes!.frame.origin.x, y: startAttributes!.frame.origin.y, width: startAttributes!.frame.size.width, height: startAttributes!.frame.size.height)
            animationLabel.layer.cornerRadius = CGRectGetHeight(animationLabel.bounds) * 0.5
            animationLabel.text = optionalArray![indexPath.row]["classname"]
            collectionView.addSubview(animationLabel)
            let toIndexPath = NSIndexPath(forItem: selectedArray!.count-1, inSection: 0)
            
            let endAttributes = collectionView.layoutAttributesForItemAtIndexPath(toIndexPath)
            
            UIView.animateWithDuration(0.7, animations: { 
                self.animationLabel.center = endAttributes!.center
                }, completion: { (_) in
                    let endCell = collectionView.cellForItemAtIndexPath(toIndexPath) as! JFEditColumnViewCell
                    endCell.contentLabel.hidden = false
                    self.lastIsHidden = false
                    self.animationLabel.removeFromSuperview()
                    self.optionalArray?.removeAtIndex(indexPath.row)
                    self.collectionView.deleteItemsAtIndexPaths([indexPath])
            })
            
        }
        
    }
    
    
    // MARK: - 懒加载
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Vertical
        
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private lazy var animationLabel: UILabel = {
        let animationLabel = UILabel()
        animationLabel.textAlignment = NSTextAlignment.Center
        animationLabel.font = UIFont.systemFontOfSize(15)
        animationLabel.numberOfLines = 1;
        animationLabel.adjustsFontSizeToFitWidth = true
        animationLabel.minimumScaleFactor = 0.1
        animationLabel.textColor = UIColor.colorWithRGB(101, g: 101, b: 101)
        animationLabel.layer.masksToBounds = true
        animationLabel.layer.borderColor = UIColor.colorWithRGB(211, g: 211, b: 211).CGColor
        animationLabel.layer.borderWidth = 0.45
        return animationLabel
    }()
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension JFEditColumnViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (SCREEN_WIDTH - (5 * SPACE)) / 4.0, height: 30)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: SPACE, left: SPACE, bottom: SPACE, right: SPACE)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return SPACE
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return SPACE
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: SCREEN_WIDTH, height: 40.0)
        } else {
            return CGSize(width: SCREEN_WIDTH, height: 30.0)
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: SCREEN_WIDTH, height: 0.0)
    }
    
    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if isSort {
            return 1
        } else {
            return 2
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return selectedArray?.count ?? 0
        } else {
            return optionalArray?.count ?? 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView: JFColumnReusableView?
        
        if kind == UICollectionElementKindSectionHeader {
            if indexPath.section == 0 {
                reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: headOne, forIndexPath: indexPath) as? JFColumnReusableView
                reusableView?.buttonHidden = false
                reusableView?.clickButton.selected = isSort
                reusableView?.backgroundColor = UIColor.whiteColor()
                
                reusableView?.clickWithBlock({ (state) in
                    //排序删除
                    if (state == ButtonState.StateSortDelete) {
                        self.isSort = true
                    } else {
                        // 完成
                        self.isSort = false
                        if self.cellAttributesArray.count > 0 {
                            
                            for attributes in self.cellAttributesArray {
                                let cell = collectionView.cellForItemAtIndexPath(attributes.indexPath)
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
                reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: headTwo, forIndexPath: indexPath) as? JFColumnReusableView
                reusableView?.buttonHidden = true
                reusableView?.backgroundColor = UIColor.colorWithRGB(240, g: 240, b: 240)
                reusableView?.titleLabel.text = "点击添加更多栏目"
            }
        }
        return reusableView!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! JFEditColumnViewCell
        
        if indexPath.section == 0 {
            cell.configCell(selectedArray!, withIndexPath: indexPath)
            
            if indexPath.row == 0 {
                cell.deleteButton.hidden = true
            } else {
                cell.delegate = self
                cell.deleteButton.hidden = !isSort
                if isSort {
                    let pan = UIPanGestureRecognizer(target: self, action: #selector(sortItem(_:)))
                    cell.addGestureRecognizer(pan)
                }
                
                //最后一位是否影藏(为了动画效果)
                if indexPath.row == selectedArray!.count - 1 {
                    cell.contentLabel.hidden = lastIsHidden
                }
            }
            
        } else {
            cell.configCell(optionalArray!, withIndexPath: indexPath)
            cell.deleteButton.hidden = true
        }
        
        return cell
    }
}
