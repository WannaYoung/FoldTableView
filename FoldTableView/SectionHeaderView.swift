//
//  SectionHeaderView.swift
//  表格动画手势示例
//
//  Created by yang on 16/2/19.
//  Copyright © 2016年 yang. All rights reserved.
//

import UIKit

// 该协议将被分节表头的委托实现； 当分节表被打开关闭时，分节表头将通知发送给委托
protocol SectionHeaderViewDelegate: class, NSObjectProtocol{
    
    func sectionHeaderView(_ sectionHeaderView: SectionHeaderView, sectionOpened: Int)
    func sectionHeaderView(_ sectionHeaderView: SectionHeaderView, sectionClosed: Int)
}

class SectionHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var disclosureButton: UIButton!
    
    var delegate: SectionHeaderViewDelegate!
    
    var section: Int!
    
    override func awakeFromNib() {
        
        // 设置disclosure 按钮的图片（被打开）
        self.disclosureButton.setImage(UIImage(named: "DownAccessory"), for: UIControlState.selected)
        
        // 建立点击手势识别
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SectionHeaderView.toggleOpen(_:)))
        
        self.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func toggleOpen(_ sender: UITapGestureRecognizer)
    {
        self.toggleOpenWithUserAction(true)
    }
    
    func toggleOpenWithUserAction(_ userAction: Bool)
    {
        
        // 切换disclosure按钮的状态（开启/关闭）
        self.disclosureButton.isSelected = !self.disclosureButton.isSelected
        
        // 如果确信是用户进行的操作，将给委托传递相应的消息
        if userAction
        {
            if self.disclosureButton.isSelected
            {
                if self.delegate.responds(to: Selector(("sectionHeaderView:sectionOpened:")))
                {
                    self.delegate.sectionHeaderView(self, sectionOpened: self.section)
                }
            }
            else
            {
                if self.delegate.responds(to: Selector(("sectionHeaderView:sectionClosed:")))
                {
                    self.delegate.sectionHeaderView(self, sectionClosed: self.section)
                }
            }
        }
    }
}
