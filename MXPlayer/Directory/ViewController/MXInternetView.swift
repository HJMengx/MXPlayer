//
//  MXInternetView.swift
//  MXPlayer
//
//  Created by mx on 2017/2/3.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

protocol MXInternetViewDelegate {
    func goto(url : URL)
}

class MXInternetView: UIView {

    var internetInputView : UITextField!
    
    var closeButton : UIButton!
    
    var cancelButton : UIButton!
    
    fileprivate var inputViewConstrait : Constraint!
    
    var delegate : MXInternetViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initSubViews()
        
        //注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(MXInternetView.keyBoardAppear), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MXInternetView.keyBoardDisappear), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    fileprivate func initSubViews(){
        
        self.internetInputView = UITextField()
        
        //编辑的时候才出现
        self.internetInputView.rightViewMode = .whileEditing
        
        self.addSubview(self.internetInputView)
        
        self.internetInputView.delegate = self
        
        self.internetInputView.snp.makeConstraints { (make : ConstraintMaker) in
            
            self.inputViewConstrait =  make.right.equalToSuperview().offset(-4).constraint
            
            make.left.equalToSuperview().offset(4)
            
            make.top.equalToSuperview().offset(2)
            
            make.bottom.equalToSuperview().offset(-2)
        }
        
        //设置CloseButton
        self.closeButton = UIButton()
        
        self.closeButton.setBackgroundImage(UIImage.init(named: ""), for: UIControlState.normal)
        
        self.internetInputView.rightView = self.closeButton
        
        self.closeButton.addTarget(self, action: #selector(MXInternetView.closeButtonClicked), for: UIControlEvents.touchUpInside)
        
        //设置CancelButton
        self.cancelButton = UIButton()
        
        self.addSubview(self.cancelButton)
        
        self.cancelButton.setTitle("取消", for: UIControlState.normal)
        
        self.cancelButton.snp.makeConstraints { (make : ConstraintMaker) in
            make.left.equalTo(self.internetInputView.snp.right).offset(4)
            make.width.equalTo(40)
            make.height.equalTo(self.internetInputView.snp.height)
            make.top.equalToSuperview().offset(2)
        }
    }
    
    //事件交互
    func closeButtonClicked(){
        //清空输入
        self.internetInputView.text = ""
    }
    
    func cancelButtonClicked(){
        //注销键盘
        self.internetInputView.resignFirstResponder()
    }
    
    fileprivate func inputViewAnimation(editing : Bool){
        if editing {
            //取消编辑模式
            //改变约束
            self.inputViewConstrait = self.inputViewConstrait.update(offset: -48)
            
            self.inputViewConstrait.activateIfNeeded(updatingExisting: true)
            //执行动画
            self.animation()
        }else{
            //开始编辑模式
            self.inputViewConstrait = self.inputViewConstrait.update(offset: -4)
            
            self.inputViewConstrait.activateIfNeeded(updatingExisting: true)
            //执行动画
            self.animation()
        }
    }
    
    fileprivate func animation(){
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            
            self.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    //键盘事件
    func keyBoardAppear(){
        //input start / cancelButton show
        self.inputViewAnimation(editing: false)
    }
    
    func keyBoardDisappear(){
        //input end / 整个屏幕
        self.inputViewAnimation(editing: true)
    }
}

extension MXInternetView : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.returnKeyType = .go
        //结束键盘
        textField.resignFirstResponder()
        //通知代理去执行搜索
        if let url = textField.text {
            if self.delegate != nil {
                self.delegate.goto(url: URL.init(string: url)!)
            }
        }
        
        return true
    }
}
