//
//  SectionInfo.swift
//  表格动画手势示例
//
//  Created by yang on 16/2/19.
//  Copyright © 2016年 yang. All rights reserved.
//

import Foundation

class SectionInfo: NSObject
{
    var open: Bool!
    var name:String = ""
    var rowsArray:NSArray = NSArray()
    var headerView: SectionHeaderView!
    
}