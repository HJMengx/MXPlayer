//
//  MXSecurityPasswordView.swift
//  MXPlayer
//
//  Created by mx on 2017/3/2.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

enum MXSecurityViewOperationType {
    case commit
    case cancel
    case modify
}

protocol MXSecuryViewDelegate {
    func operation(at : MXSecurityPasswordView,with : MXSecurityViewOperationType)
}

class MXSecurityPasswordView: UIView {
    
    var isSetting : Bool = true
    
    var titleLabel : UILabel!
    
    var passwordField : UITextField!
    
    var submitPasswordField : UITextField!
    
    var commitButton : UIButton!
    
    var cancelButton : UIButton!
    
    var modifyPasswordButton : UIButton!
    
    var delegate : MXSecuryViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: CGRect())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initSubViews(){
        //titleLabel
        self.titleLabel = UILabel()
        
        self.titleLabel.text = "私人空间"
        
        self.titleLabel.textColor = UIColor.white
        
        self.addSubview(self.titleLabel)
        
        self.titleLabel.textAlignment = .center
        
        self.titleLabel.snp.makeConstraints { (make : ConstraintMaker) in
            make.width.equalToSuperview()
            make.left.equalToSuperview().offset(2)
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(30)
        }
        
        //password
        self.passwordField = UITextField()
        
        self.addSubview(self.passwordField)
        
        self.passwordField.layer.borderColor = UIColor.white.cgColor
        
        self.passwordField.layer.borderWidth = 2
        
        self.passwordField.layer.cornerRadius = 5
        
        self.passwordField.placeholder = "请输入口令"
        
        self.passwordField.delegate = self
        
        self.passwordField.isSecureTextEntry = true
        
        self.fieldSetting(textField: self.passwordField)
        
        self.passwordField.snp.makeConstraints { (make : ConstraintMaker) in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            make.height.equalTo(36)
        }
        
        //submitPassword
        if self.isSetting {
            self.submitPasswordField = UITextField()
            
            self.addSubview(self.submitPasswordField)
            
            self.submitPasswordField.layer.borderColor = UIColor.white.cgColor
            
            self.submitPasswordField.layer.borderWidth = 2
            
            self.submitPasswordField.layer.cornerRadius = 5
            
            self.submitPasswordField.delegate = self
            
            self.submitPasswordField.placeholder = "请再次输入口令"
            
            self.submitPasswordField.isSecureTextEntry = true
            
            self.fieldSetting(textField: self.submitPasswordField)
            
            self.submitPasswordField.snp.makeConstraints { (make : ConstraintMaker) in
                make.top.equalTo(self.passwordField.snp.bottom).offset(5)
                make.height.equalTo(36)
                make.left.equalToSuperview().offset(5)
                make.right.equalToSuperview().offset(-5)
            }
            
        }

        //commitButton
        self.commitButton = UIButton()
        
        self.addSubview(self.commitButton)
        
        self.commitButton.setTitle( "确认", for: UIControlState.normal)
        
        self.commitButton.titleLabel?.textAlignment = .center
        
        self.commitButton.addTarget(self, action: #selector(MXSecurityPasswordView.commitPassword), for: UIControlEvents.touchUpInside)
        
        self.commitButton.snp.makeConstraints { (make : ConstraintMaker) in
            make.bottom.equalToSuperview().offset(-5)
            
            if self.isSetting {
                make.top.equalTo(self.submitPasswordField.snp.bottom).offset(5)
            }else{
                make.top.equalTo(self.passwordField.snp.bottom).offset(8)
            }
            make.left.equalToSuperview().offset(5)
           
            make.width.equalToSuperview().dividedBy(2)
        }
        
        //cancelButton
        if self.isSetting {
            
            self.cancelButton = UIButton()
            
            self.addSubview(self.cancelButton)
            
            self.cancelButton.setTitle("取消", for: UIControlState.normal)
            
            self.cancelButton.titleLabel?.textAlignment = .center
            
            
            self.cancelButton.addTarget(self, action: #selector(MXSecurityPasswordView.cancelPassword), for: UIControlEvents.touchUpInside)
            
            self.cancelButton.snp.makeConstraints { (make : ConstraintMaker) in
                
                make.bottom.equalToSuperview().offset(-5)
                
                make.top.equalTo(self.submitPasswordField.snp.bottom).offset(8)
                
                make.right.equalToSuperview().offset(-5)
                
                make.width.equalToSuperview().dividedBy(2)
            }
        }
        
        //modifyPasswordButton
        if !self.isSetting {
            self.modifyPasswordButton = UIButton()
            
            self.addSubview(self.modifyPasswordButton)
            
            self.modifyPasswordButton.titleLabel?.textAlignment = .center
            
            self.modifyPasswordButton.setTitle("修改密码", for: UIControlState.normal)
            
            self.modifyPasswordButton.addTarget(self, action: #selector(MXSecurityPasswordView.modifyPassword), for: UIControlEvents.touchUpInside)
            
            self.modifyPasswordButton.snp.makeConstraints { (make : ConstraintMaker) in
                make.bottom.equalToSuperview().offset(-5)
                
                make.top.equalTo(self.passwordField.snp.bottom).offset(8)
                
                make.right.equalToSuperview().offset(-5)
                
                make.width.equalToSuperview().dividedBy(2)
            }
        }

    }
    //MARK: fieldSetting
    private func fieldSetting(textField : UITextField){
        textField.leftViewMode = .always
        
        let passwordImageView = UIImageView.init(frame: CGRect.init(x: 3, y: 0, width: 30, height: 30))
        
        passwordImageView.image = UIImage.init(named: "password2")
        
        textField.leftView = passwordImageView
    }
}

//MARK:delegate 
extension MXSecurityPasswordView : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.returnKeyType = .next
        
        if self.isSetting {
            if textField.isEqual(self.passwordField) {
                self.passwordField.resignFirstResponder()
                self.submitPasswordField.becomeFirstResponder()
            }else{
                self.submitPasswordField.resignFirstResponder()
            }
        }else{
            
            self.passwordField.resignFirstResponder()
        }
        
        return true
    }
}

//MARK: Action
extension MXSecurityPasswordView {
    
    func commitPassword(){
        self.endEditing(true)
        if self.delegate != nil {
            self.delegate.operation(at: self, with: .commit)
        }
    }
    
    func cancelPassword(){
        self.endEditing(true)
        if self.delegate != nil {
            self.delegate.operation(at: self, with: .cancel)
        }
    }
    
    func modifyPassword(){
        self.endEditing(true)
        if self.delegate != nil {
            self.delegate.operation(at: self, with: .modify)
        }
    }
}
