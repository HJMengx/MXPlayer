//
//  MXModifyPasswordNavView.swift
//  MXPlayer
//
//  Created by mx on 2017/3/3.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

enum MXModifyType{
    case back
    case save
}

protocol MXModifyPasswordViewDelegate {
    func operation(at : MXModifyPasswordNavView,with : MXModifyType)
}

class MXModifyPasswordNavView: UIView {

    var leftButton : UIButton!
    
    var rightButton : UIButton!
    
    var delegate : MXModifyPasswordViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.init(red: 85 / 255.0, green: 162 / 255.0 , blue: 217 / 255, alpha: 1.0)
        
        self.initSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initSubViews(){
        //设置左右
        let leftButton = UIButton.init(frame: CGRect.init(x: 2, y: 30, width: 30, height: 30))
        
        leftButton.setTitle("< ", for: UIControlState.normal)
        
        leftButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        
        leftButton.addTarget(self, action: #selector(MXModifyPasswordNavView.back), for: UIControlEvents.touchUpInside)
        
        let rightButton = UIButton.init(frame: CGRect.init(x: UIScreen.main.bounds.size.width - 50, y: 30, width: 50, height: 30))
        
        rightButton.titleLabel?.textAlignment = .left
        
        rightButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        
        rightButton.setTitle("保存", for: UIControlState.normal)
        
        rightButton.addTarget(self, action: #selector(MXModifyPasswordNavView.save), for: UIControlEvents.touchUpInside)
        
        self.addSubview(leftButton)
        
        self.addSubview(rightButton)
    }
    
    
    func back(){
        self.endEditing(true)
        if self.delegate != nil {
            self.delegate.operation(at: self, with: .back)
        }
    }
    
    func save(){
        self.endEditing(true)
        if self.delegate != nil {
            self.delegate.operation(at: self, with: .save)
        }
    }
    
}
