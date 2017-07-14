//
//  JJCommonCollectionViewLayout.swift
//  JJFrameWork_Swift
//
//  Created by 房俊杰 on 2015/4/28.
//  Copyright © 2015年 房俊杰. All rights reserved.
//

import UIKit

@objc protocol JJCommonCollectionViewLayoutDataSource {
    // MARK: - 必须实现的代理
    
    /// 返回每一个item的高度 高度不同则按瀑布流方式排布
    ///
    /// - Parameters:
    ///   - layout: JJCommonCollectionViewLayout
    ///   - indexPath: indexPath
    ///   - itemWith: item的宽度
    ///   - rowMargin: 行间距
    /// - Returns: 每一个item的高度
    func commonCollectionViewLayout(_ layout: JJCommonCollectionViewLayout, heightForItemAtIndexPath indexPath: IndexPath, itemWith: Float, rowMargin: Float) -> Float
    
    // MARK: - 选择实现的代理 设置布局的属性
    
    /// 每一个分区有多少列
    @objc optional func commonCollectionViewLayout(_ layout: JJCommonCollectionViewLayout, numberOfColumnsInSection section: Int) -> Int
    /// 整体的内边距
    @objc optional func commonEdgeInsetsOfOverallInCollectionViewLayout(_ layout: JJCommonCollectionViewLayout) -> UIEdgeInsets
    /// 每一分区的内边距
    @objc optional func commonCollectionViewLayout(_ layout: JJCommonCollectionViewLayout, edgeInsetsInSection section: Int) -> UIEdgeInsets
    /// 每一列的间距
    @objc optional func commonCollectionViewLayout(_ layout: JJCommonCollectionViewLayout, marginOfColumnInSection section: Int) -> Float
    /// 每一行的间距
    @objc optional func commonCollectionViewLayout(_ layout: JJCommonCollectionViewLayout, marginOfRowInSection section: Int) -> Float
    /// 区头，区尾的高度
    @objc optional func commonCollectionViewLayout(_ layout: JJCommonCollectionViewLayout, heightForSupplementaryViewInSection section: Int, supplementaryViewOfKind kind: String) -> Float
    /// 区头，区尾的内边距
    @objc optional func commonCollectionViewLayout(_ layout: JJCommonCollectionViewLayout, edgeInsetsForSupplementaryViewInSection section: Int, supplementaryViewOfKind kind: String) -> UIEdgeInsets
}


class JJCommonCollectionViewLayout: UICollectionViewLayout {
    
    /// 代理
    fileprivate weak var dataSource: JJCommonCollectionViewLayoutDataSource?
    
    /// 初始化方法
    ///
    /// - Parameter dataSource: 代理
    init(dataSource: JJCommonCollectionViewLayoutDataSource) {
        super.init()
        self.dataSource = dataSource
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 常量(默认属性)
    /// 每一个分区的列数
    fileprivate let defaultColumnsOfSection = 2
    /// 整体的内边距
    fileprivate let defaultEdgeInsetsOfOverall = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    /// 每一分区的内边距
    fileprivate let defaultEdgeInsetsOfSection = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    /// 每一列的间距
    fileprivate let defaultMarginOfColumn: Float = 5
    /// 每一行的间距
    fileprivate let defaultMarginOfRow: Float = 5
    /// 区头，区尾的高度
    fileprivate let defaultHeightOfHeaderOrFooter: Float = 0
    /// 区头，区尾的内边距
    fileprivate let defaultEdgeInsetsOfHeaderOrFooter = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    /// collectionView高度
    
    // MARK: - 懒加载
    
    /// 布局元素数组 二维数组
    fileprivate lazy var attributesArray: [[UICollectionViewLayoutAttributes]] = Array()
    /// 每一列的高度
    fileprivate lazy var columnHeightArray: [Float] = Array()
    /// 记录内容高度
    fileprivate lazy var contentHeight: Float = 0
    
    // MARK: - layout基本设置
    override func prepare() {
        super.prepare()
        ///设置每一列的高度
        setupColumnHeight()
        ///设置布局元素
        setupAttributes()
    }
    
    /// 返回indexPat位置的cell对应的布局属性
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesArray[indexPath.section][indexPath.row]
    }
    /// 返回布局元素的数组
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var array: [UICollectionViewLayoutAttributes] = Array()
        for section in 0..<attributesArray.count{
            let rowArray = attributesArray[section]
            for row in 0..<rowArray.count{
                array.append(rowArray[row])
            }
        }
        return array
    }
    /// 返回区头、区尾布局元素
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
    }
    /// 返回装饰布局元素
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return UICollectionViewLayoutAttributes(forDecorationViewOfKind: elementKind, with: indexPath)
    }
    /// 返回内容大小
    override var collectionViewContentSize: CGSize{
        if let collectionViewHeight = collectionView?.frame.size.height{
            let height: CGFloat = CGFloat(contentHeight) + CGFloat(edgeInsetsOfOverall().bottom) > collectionViewHeight ? CGFloat(contentHeight) + CGFloat(edgeInsetsOfOverall().bottom) : collectionViewHeight + 1
            return CGSize(width: 0, height: height)
        }
        return CGSize(width: 0, height: 0)
    }
    
    
}
// MARK: - 布局初始化
extension JJCommonCollectionViewLayout{
    /// 设置每一列的高度
    fileprivate func setupColumnHeight(){
        
        columnHeightArray.removeAll()
        //找出列数做多的分区
        var maxColumnOfSection = 0
        if let availableSections = collectionView?.numberOfSections {
            for section in 0..<availableSections {
                let column = numberOfColumnsInSection(section)
                if column > maxColumnOfSection {
                    maxColumnOfSection = column
                }
            }
        }
        contentHeight = Float(edgeInsetsOfOverall().top)
        //添加默认值，加上整体内边距的top值
        for _ in 0..<maxColumnOfSection {
            columnHeightArray.append(contentHeight)
        }
        
    }
    /// 设置布局元素
    fileprivate func setupAttributes(){
        
        attributesArray.removeAll()
        //获取有几个分区
        if let availableSections = collectionView?.numberOfSections {
            //设置布局元素的属性 - 位置frame
            for section in 0..<availableSections{
                var array: [UICollectionViewLayoutAttributes] = Array()
                //设置区头
                let headerAttribute = setupHeaderInSection(section)
                if headerAttribute.frame.size.height != 0{
                    array.append(headerAttribute)
                }
                //每一分区中的item
                if let availableRows = collectionView?.numberOfItems(inSection: section){
                    for row in 0..<availableRows{
                        let indexPath = IndexPath(item: row, section: section)
                        let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                        //设置每一个分区的item
                        //找出高度最短的那一列
                        var minHeightColumn = 0
                        var minHeight: Float = columnHeightArray[0]
                        for i in 1..<numberOfColumnsInSection(section){
                            
                            let columnHeight: Float = columnHeightArray[i]
                            if columnHeight < minHeight{
                                minHeight = columnHeight
                                minHeightColumn = i
                            }
                        }
                        //1.设置宽度
                        var width: CGFloat = 0
                        if let collectionViewWidth = collectionView?.frame.size.width{
                            width = (collectionViewWidth - edgeInsetsOfOverall().left - edgeInsetsOfOverall().right - (CGFloat(numberOfColumnsInSection(section)-1)) * CGFloat(marginOfColumnInSection(section)) - edgeInsetsInSection(section).left - edgeInsetsInSection(section).right) / CGFloat(numberOfColumnsInSection(section))
                        }
                        //2.设置x
                        let x: CGFloat = edgeInsetsOfOverall().left + CGFloat(minHeightColumn) * (width + CGFloat(marginOfColumnInSection(section))) + edgeInsetsInSection(section).left
                        //3.设置y
                        var y: CGFloat = CGFloat(columnHeightArray[minHeightColumn])
                        //排除第一行多加[self marginOfRowInSection:section]
                        if row / numberOfColumnsInSection(section) != 0{
                            y += CGFloat(marginOfRowInSection(section))
                        }
                        //4.设置高度 通过代理设置
                        let height: CGFloat = CGFloat((dataSource?.commonCollectionViewLayout(self, heightForItemAtIndexPath: indexPath, itemWith: Float(width), rowMargin: marginOfRowInSection(section)))!)
                        attribute.frame = CGRect(x: x, y: y, width: width, height: height)
                        //更新最短那列的高度
                        columnHeightArray[minHeightColumn] = Float(attribute.frame.size.height + attribute.frame.origin.y)
                        //找出最大高度
                        let columnHeight: Float = columnHeightArray[minHeightColumn]
                        if contentHeight < columnHeight{
                            contentHeight = columnHeight
                        }
                        array.append(attribute)
                    }
                }
                //设置区尾
                let footerAttribute = setupFooterInSection(section)
                if footerAttribute.frame.size.height != 0{
                    array.append(footerAttribute)
                }
                attributesArray.append(array)
            }
        }
    }
}
// MARK: - 设置区头区尾
extension JJCommonCollectionViewLayout{
    /// 设置区头
    fileprivate func setupHeaderInSection(_ section: Int) -> UICollectionViewLayoutAttributes{
        let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: section))
        let headerX: CGFloat = edgeInsetsOfOverall().left + edgeInsetsInSection(section).left + edgeInsetsForSupplementaryViewInSection(section, supplementaryViewOfKind: UICollectionElementKindSectionHeader).left
        let headerY: CGFloat = CGFloat(contentHeight) + edgeInsetsInSection(section).top + edgeInsetsForSupplementaryViewInSection(section, supplementaryViewOfKind: UICollectionElementKindSectionHeader).top
        var headerWidth: CGFloat = 0
        if let collectionViewWidth = collectionView?.frame.size.width{
            headerWidth = collectionViewWidth - edgeInsetsOfOverall().left - edgeInsetsOfOverall().right - edgeInsetsInSection(section).left - edgeInsetsInSection(section).right - edgeInsetsForSupplementaryViewInSection(section, supplementaryViewOfKind: UICollectionElementKindSectionHeader).left - edgeInsetsForSupplementaryViewInSection(section, supplementaryViewOfKind: UICollectionElementKindSectionHeader).right
            
        }
        let headerHeight: CGFloat = CGFloat(heightForSupplementaryViewInSection(section, supplementaryViewOfKind: UICollectionElementKindSectionHeader))
        headerAttributes.frame = CGRect(x: headerX, y: headerY, width: headerWidth, height: headerHeight)
        contentHeight = Float(headerAttributes.frame.size.height + headerAttributes.frame.origin.y + edgeInsetsForSupplementaryViewInSection(section, supplementaryViewOfKind: UICollectionElementKindSectionHeader).bottom)
        //下一次遍历section时，用上一个section中最大的高度覆盖掉存放每一列高度的数组
        for i in 0..<columnHeightArray.count{
            columnHeightArray[i] = contentHeight
        }
        return headerAttributes
    }
    /// 设置区尾
    fileprivate func setupFooterInSection(_ section: Int) -> UICollectionViewLayoutAttributes{
        let footerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: section))
        let footerX: CGFloat = edgeInsetsOfOverall().left + edgeInsetsInSection(section).left + edgeInsetsForSupplementaryViewInSection(section, supplementaryViewOfKind: UICollectionElementKindSectionFooter).left
        let footerY: CGFloat = CGFloat(contentHeight) + edgeInsetsForSupplementaryViewInSection(section, supplementaryViewOfKind: UICollectionElementKindSectionFooter).top
        var footerWidth: CGFloat = 0
        if let collectionViewWidth = collectionView?.frame.size.width{
            footerWidth = collectionViewWidth - edgeInsetsOfOverall().left - edgeInsetsOfOverall().right - edgeInsetsInSection(section).left - edgeInsetsInSection(section).right - edgeInsetsForSupplementaryViewInSection(section, supplementaryViewOfKind: UICollectionElementKindSectionFooter).left - edgeInsetsForSupplementaryViewInSection(section, supplementaryViewOfKind: UICollectionElementKindSectionFooter).right
        }
        let footerHeight: CGFloat = CGFloat(heightForSupplementaryViewInSection(section, supplementaryViewOfKind: UICollectionElementKindSectionFooter))
        
        footerAttributes.frame = CGRect(x: footerX, y: footerY, width: footerWidth, height: footerHeight)
        contentHeight = Float(footerAttributes.frame.size.height + footerAttributes.frame.origin.y + edgeInsetsInSection(section).bottom + edgeInsetsForSupplementaryViewInSection(section, supplementaryViewOfKind: UICollectionElementKindSectionFooter).bottom)
        
        for i in 0..<columnHeightArray.count{
            columnHeightArray[i] = contentHeight
        }
        return footerAttributes
    }
}
// MARK: - 判断代理简写
extension JJCommonCollectionViewLayout{
    
    /// 每一个分区有多少列
    fileprivate func numberOfColumnsInSection(_ section: Int) -> Int{
        if let number = dataSource?.commonCollectionViewLayout?(self, numberOfColumnsInSection: section){
            return number
        }
        return defaultColumnsOfSection
    }
    /// 整体的内边距
    fileprivate func edgeInsetsOfOverall() -> UIEdgeInsets{
        if let edgeInsets = dataSource?.commonEdgeInsetsOfOverallInCollectionViewLayout?(self){
            return edgeInsets
        }
        return defaultEdgeInsetsOfOverall
        
    }
    /// 每一分区的内边距
    fileprivate func edgeInsetsInSection(_ section: Int) -> UIEdgeInsets{
        if let edgeInsets = dataSource?.commonCollectionViewLayout?(self, edgeInsetsInSection: section){
            return edgeInsets
        }
        return defaultEdgeInsetsOfSection
    }
    /// 每一列的间距
    fileprivate func marginOfColumnInSection(_ section: Int) -> Float{
        if let margin = dataSource?.commonCollectionViewLayout?(self, marginOfColumnInSection: section){
            return margin
        }
        return defaultMarginOfColumn
    }
    /// 每一行的间距
    fileprivate func marginOfRowInSection(_ section: Int) -> Float{
        if let margin = dataSource?.commonCollectionViewLayout?(self, marginOfRowInSection: section){
            return margin
        }
        return defaultMarginOfRow
    }
    /// 区头，区尾的高度
    fileprivate func heightForSupplementaryViewInSection(_ section: Int, supplementaryViewOfKind kind: String) -> Float{
        if let height = dataSource?.commonCollectionViewLayout?(self, heightForSupplementaryViewInSection: section, supplementaryViewOfKind: kind){
            return height;
        }
        return defaultHeightOfHeaderOrFooter
    }
    /// 区头，区尾的内边距
    fileprivate func edgeInsetsForSupplementaryViewInSection(_ section: Int, supplementaryViewOfKind kind: String) -> UIEdgeInsets{
        if let edgeInsets = dataSource?.commonCollectionViewLayout?(self, edgeInsetsForSupplementaryViewInSection: section, supplementaryViewOfKind: kind){
            return edgeInsets
        }
        return defaultEdgeInsetsOfHeaderOrFooter
    }
}





































