//
//  MXPlayTopView.swift
//  MXPlayer
//
//  Created by mx on 2017/2/4.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

//操作类型
enum MXPlayViewOperationType {
    case back
}

protocol MXPlayTopViewDelegate {
    func operation(with : MXPlayTopView,type : MXPlayViewOperationType)
}

class MXPlayTopView: UIView {
    
    var backButton : UIButton!
    
    var titleLable : UILabel!
    
    var delegate : MXPlayTopViewDelegate!
    
    override init(frame : CGRect){
        super.init(frame: frame)
        //设置背景颜色
        self.backgroundColor = UIColor.lightGray
        
        self.alpha = 0.5
        //设置
        self.initSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func initSubViews(){
        //设置返回按钮
        self.backButton = UIButton()
        
        self.addSubview(self.backButton)
        
        self.backButton.addTarget(self, action: #selector(MXPlayTopView.backButtonClick), for: UIControlEvents.touchUpInside)
        
        self.backButton.setBackgroundImage(UIImage.init(named: "backIcon"), for: UIControlState.normal)
        
        self.backButton.snp.makeConstraints { (make : ConstraintMaker) in
            make.width.equalTo(20)
            make.left.equalTo(self.snp.left).offset(8)
            make.top.equalTo(self.snp.top).offset(16)
            make.height.equalTo(20)
        }
        
        //标题栏
        self.titleLable = UILabel()
        
        self.titleLable.textColor = UIColor.black
        
        self.titleLable.textAlignment = .center
        
        self.addSubview(self.titleLable)
        
        self.titleLable.snp.makeConstraints { (make : ConstraintMaker) in
            make.left.equalTo(self.backButton.snp.right).offset(4)
            
            make.right.equalTo(self.snp.right)
            
            make.top.equalTo(self.snp.top).offset(16)
            
            make.height.equalTo(20)
        }
    }
    
    func backButtonClick(){
        //通知代理
        guard self.delegate != nil else {
            return
        }
        self.delegate.operation(with: self, type: .back)
    }
}
