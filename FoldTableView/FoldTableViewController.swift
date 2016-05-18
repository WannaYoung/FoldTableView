//
//  FoldTableViewController.swift
//  FoldTableView
//
//  Created by yang on 16/2/19.
//  Copyright © 2016年 yang. All rights reserved.
//

import UIKit

class FoldTableViewController: UITableViewController ,SectionHeaderViewDelegate{
    
    var sourceArray:NSArray = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("source", ofType: "plist")!)!
    
    var sectionInfoArray:NSMutableArray! = NSMutableArray()
    var opensectionindex:Int!
    var sectionHeaderView:SectionHeaderView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
     
        self.initSubViews()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func initSubViews()
    {
        if self.sectionInfoArray == nil || self.sectionInfoArray.count != self.numberOfSectionsInTableView(self.tableView)
        {
            // 分节信息数组在viewWillUnload方法中将被销毁，因此在这里设置Header的默认高度是可行的。如果您想要保留分节信息等内容，可以在指定初始化器当中设置初始值。
            
            self.opensectionindex = NSNotFound
            
            let sectionHeaderNib: UINib = UINib(nibName: "SectionHeaderView", bundle: nil)
            
            self.tableView.registerNib(sectionHeaderNib, forHeaderFooterViewReuseIdentifier: "header")
            
            //对于每个场次来说，需要为每个单元格设立一个一致的、包含默认高度的SectionInfo对象。
            let infoArray = NSMutableArray()
            
            for i in 0 ..< sourceArray.count
            {
                let rowsArray:NSArray = sourceArray[i]["rows"] as! NSArray
                
                let sectionInfo = SectionInfo()
                sectionInfo.rowsArray = rowsArray
                sectionInfo.open = false
                sectionInfo.name = sourceArray[i]["section"] as! String
                infoArray.addObject(sectionInfo)
            }
            self.sectionInfoArray  = infoArray
            
        }
    }
    
    // MARK: TableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 4
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // 这个方法返回对应的section有多少个元素，也就是多少行
        let sectionInfo: SectionInfo = self.sectionInfoArray[section] as! SectionInfo
        let numStoriesInSection = sectionInfo.rowsArray.count
        let sectionOpen = sectionInfo.open!
        
        return sectionOpen ? numStoriesInSection : 0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let detailArray:NSArray = sourceArray[indexPath.section]["rows"] as! NSArray
        
        return self.getCellHeightWithText((detailArray[indexPath.row] as? String)!)
        
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 40
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.001
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("fold")!
        
        let detailArray:NSArray = sourceArray[indexPath.section]["rows"] as! NSArray
        
        let content:UILabel = cell.viewWithTag(10) as! UILabel
        
        content.text = detailArray[indexPath.row] as? String
        
        self.configContentFont(content)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // 返回指定的 section header 的view，如果没有，这个函数可以不返回view
        let sectionHeaderView: SectionHeaderView = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! SectionHeaderView
        let sectionInfo: SectionInfo = self.sectionInfoArray[section] as! SectionInfo
        sectionInfo.headerView = sectionHeaderView
        
        sectionHeaderView.titleLabel.text = sectionInfo.name
        sectionHeaderView.section = section
        sectionHeaderView.delegate = self
        
        return sectionHeaderView
    }
    
    // MARK: SectionHeaderViewDelegate
    
    func sectionHeaderView(sectionHeaderView: SectionHeaderView, sectionOpened: Int) {
        
        let sectionInfo: SectionInfo = self.sectionInfoArray[sectionOpened] as! SectionInfo
        
        sectionInfo.open = true
        
        //创建一个包含单元格索引路径的数组来实现插入单元格的操作：这些路径对应当前节的每个单元格
        
        let countOfRowsToInsert = sectionInfo.rowsArray.count
        var indexPathsToInsert = [NSIndexPath]()
        
        for i in 0 ..< countOfRowsToInsert
        {
            indexPathsToInsert.append(NSIndexPath(forRow: i, inSection: sectionOpened))
        }
        
        // 创建一个包含单元格索引路径的数组来实现删除单元格的操作：这些路径对应之前打开的节的单元格
        
        var indexPathsToDelete = [NSIndexPath]()
        
        let previousOpenSectionIndex = self.opensectionindex
        if previousOpenSectionIndex != NSNotFound {
            
            let previousOpenSection: SectionInfo = self.sectionInfoArray[previousOpenSectionIndex] as! SectionInfo
            previousOpenSection.open = false
            previousOpenSection.headerView.toggleOpenWithUserAction(false)
            let countOfRowsToDelete = previousOpenSection.rowsArray.count
            for i in 0 ..< countOfRowsToDelete
            {
                indexPathsToDelete.append(NSIndexPath(forRow: i, inSection: previousOpenSectionIndex))
            }
        }
        
        // 设计动画，以便让表格的打开和关闭拥有一个流畅（很屌）的效果
        var insertAnimation: UITableViewRowAnimation
        var deleteAnimation: UITableViewRowAnimation
        if previousOpenSectionIndex == NSNotFound || sectionOpened < previousOpenSectionIndex {
            insertAnimation = UITableViewRowAnimation.Top
            deleteAnimation = UITableViewRowAnimation.Top
        }else{
            insertAnimation = UITableViewRowAnimation.Bottom
            deleteAnimation = UITableViewRowAnimation.Top
        }
        
        // 应用单元格的更新
        self.tableView.beginUpdates()
        self.tableView.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: deleteAnimation)
        self.tableView.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: insertAnimation)
        
        self.opensectionindex = sectionOpened
        
        self.tableView.endUpdates()
    }
    
    func sectionHeaderView(sectionHeaderView: SectionHeaderView, sectionClosed: Int) {
        
        // 在表格关闭的时候，创建一个包含单元格索引路径的数组，接下来从表格中删除这些行
        let sectionInfo: SectionInfo = self.sectionInfoArray[sectionClosed] as! SectionInfo
        
        sectionInfo.open = false
        
        let countOfRowsToDelete = self.tableView.numberOfRowsInSection(sectionClosed)
        
        if countOfRowsToDelete > 0
        {
            var indexPathsToDelete = [NSIndexPath]()
            
            for i in 0 ..< countOfRowsToDelete
            {
                indexPathsToDelete.append(NSIndexPath(forRow: i, inSection: sectionClosed))
            }
            
            self.tableView.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: UITableViewRowAnimation.Top)
        }
        self.opensectionindex = NSNotFound
    }
    
    func getCellHeightWithText(content:NSString) -> CGFloat
    {
        let paragraphStyle:NSMutableParagraphStyle  = NSMutableParagraphStyle()
        
        paragraphStyle.lineSpacing = 5.0
        
        let options = unsafeBitCast(NSStringDrawingOptions.UsesLineFragmentOrigin.rawValue |
            NSStringDrawingOptions.UsesFontLeading.rawValue,
            NSStringDrawingOptions.self)
        let boundingRect = content.boundingRectWithSize(CGSizeMake(UIScreen.mainScreen().bounds.size.width-30, 0), options: options, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(14),NSParagraphStyleAttributeName:paragraphStyle], context: nil)
        
        return boundingRect.size.height+11
        
    }
    
    func configContentFont(content:UILabel)
    {
        let attributedString:NSMutableAttributedString  = NSMutableAttributedString(string: content.text!)
        
        let paragraphStyle:NSMutableParagraphStyle  = NSMutableParagraphStyle()
        
        paragraphStyle.lineSpacing = 5.0
        
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, (content.text?.characters.count)!))
        
        content.attributedText = attributedString
        
    }
}
